# ============================================================================
# APPLICATION LOAD BALANCER MODULE - main.tf
# ============================================================================
# This module creates a complete Application Load Balancer (ALB) setup for distributing
# HTTP/HTTPS traffic across multiple backend ec2 instances.
#
# What this module does:
# - Creates an internet-facing ALB in public subnets
# - Sets up a Target Group to manage backend ec2 instances
# - Configures HTTP listener (port 80) with automatic redirect to HTTPS
# - Configures HTTPS listener (port 443) with SSL/TLS certificate
# - Implements health checks to monitor backend instance health
# - Provides optional access logs, session stickiness, and CloudWatch alarms
#
# How traffic flows:
# 1. User requests -> ALB (port 80 or 443)
# 2. HTTP (80) -> Redirected to HTTPS (443)
# 3. HTTPS (443) -> Terminates SSL, forwards to Target Group
# 4. Target Group -> Routes to healthy backend instances
# 5. Health checks continuously verify instance availability
# ============================================================================

# ============================================================================
# APPLICATION LOAD BALANCER - Main Load Balancer Resource
# ============================================================================

resource "aws_lb" "this" {
  name               = local.alb_name
  internal           = var.internal           # false = internet-facing (public), true = internal (private VPC only)
  load_balancer_type = "application"          # "application" = Layer 7 (HTTP/HTTPS), "network" = Layer 4 (TCP/UDP)
  security_groups    = var.security_group_ids # Firewall rules controlling inbound/outbound traffic
  subnets            = var.subnet_ids         # Public subnets where ALB is deployed (minimum 2 for high availability)

  # Deletion protection prevents accidental deletion of the load balancer
  # Enable in production to avoid catastrophic mistakes
  enable_deletion_protection = var.enable_deletion_protection

  # Cross-zone load balancing distributes traffic evenly across all availability zones
  # Without this, traffic is only balanced within each AZ independently
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  # HTTP/2 support enables faster page loads through multiplexing and header compression
  enable_http2 = var.enable_http2

  # Drop invalid header fields as a security best practice
  # Prevents potential header injection attacks
  drop_invalid_header_fields = var.drop_invalid_header_fields

  # Idle timeout: how long to keep connections open when no data is being transferred
  # Default 60 seconds; increase for long-polling or WebSocket applications
  idle_timeout = var.idle_timeout

  # Access logs configuration (optional)
  # Logs all requests to an S3 bucket for auditing and troubleshooting
  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : [] # Create block only if enabled
    content {
      bucket  = var.access_logs_bucket # S3 bucket name
      prefix  = var.access_logs_prefix # Folder path within bucket (e.g., "alb-logs/")
      enabled = true
    }
  }

  # Tags for resource organization and cost tracking
  tags = merge(
    var.tags,
    {
      Name        = local.alb_name
      Environment = var.environment
    }
  )
}

# ============================================================================
# TARGET GROUP - Manages Backend Instances
# ============================================================================
# Target Group defines where the ALB forwards traffic and how to check instance health

# Primary target group for Auto Scaling Group instances
resource "aws_lb_target_group" "primary" {
  name     = local.tg_name
  port     = var.target_group_port     # Port where backend instances listen (usually 80 or 443)
  protocol = var.target_group_protocol # HTTP or HTTPS
  vpc_id   = var.vpc_id                # VPC where target instances are located

  target_type = var.target_type

  # Deregistration delay (connection draining)
  deregistration_delay = var.deregistration_delay

  # Health check configuration
  # ALB continuously sends health check requests to verify instance availability
  health_check {
    enabled             = var.health_check_enabled
    healthy_threshold   = var.health_check_healthy_threshold   # Consecutive successes needed to mark healthy
    unhealthy_threshold = var.health_check_unhealthy_threshold # Consecutive failures needed to mark unhealthy
    timeout             = var.health_check_timeout             # Time to wait for response (seconds)
    interval            = var.health_check_interval            # Time between health checks (seconds)
    path                = var.health_check_path                # URL path to check (e.g., "/health")
    protocol            = var.health_check_protocol            # HTTP or HTTPS
    matcher             = var.health_check_matcher             # Expected HTTP status code (e.g., "200" or "200-299")
  }

  # Stickiness configuration (session affinity) - optional
  # Ensures requests from the same client go to the same backend instance
  dynamic "stickiness" {
    for_each = var.enable_stickiness ? [1] : [] # Create block only if enabled
    content {
      type            = var.stickiness_type            # "lb_cookie" (ALB-generated) or "app_cookie" (application-generated)
      cookie_duration = var.stickiness_cookie_duration # How long session lasts (seconds)
      enabled         = true
    }
  }

  # When to use stickiness:
  # - Stateful applications that store session data in memory
  # - NOT recommended for stateless applications (adds unnecessary overhead)

  # Tags for organization
  tags = merge(
    var.tags,
    {
      Name        = local.tg_name
      Environment = var.environment
    }
  )

  # Lifecycle management
  # Create new target group before destroying old one (zero downtime during updates)
  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# HTTP LISTENER (Port 80) - Redirect All HTTP Traffic to HTTPS
# ============================================================================
# This listener handles all HTTP requests and redirects them to HTTPS for security

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80" # Standard HTTP port
  protocol          = "HTTP"

  # Default action: redirect all HTTP requests to HTTPS
  default_action {
    type = "redirect"

    redirect {
      port        = "443" # Redirect to HTTPS port
      protocol    = "HTTPS"
      status_code = "HTTP_301" # 301 = Permanent redirect
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${local.alb_name}-http-listener"
      Environment = var.environment
    }
  )
}

# ============================================================================
# HTTPS LISTENER (Port 443)
# ============================================================================
# This listener handles encrypted HTTPS traffic and forwards it to backend instances

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443" # Standard HTTPS port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy      # SSL/TLS security policy
  certificate_arn   = var.certificate_arn # ARN of SSL/TLS certificate from ACM module

  # Default action: forward traffic to target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary.arn
  }

  # Traffic flow:
  # 1. Client -> ALB (encrypted HTTPS)
  # 2. ALB terminates SSL (decrypts traffic)
  # 3. ALB -> Backend instances

  tags = merge(
    var.tags,
    {
      Name        = "${local.alb_name}-https-listener"
      Environment = var.environment
    }
  )
}

# ============================================================================
# LISTENER RULES - Custom Routing Logic (Optional)
# ============================================================================
# Listener rules enable advanced routing based on URL path, hostname, headers, etc.

# Example: Path-based routing rule
# Route requests to different target groups based on URL path
resource "aws_lb_listener_rule" "path_based" {
  count = length(var.path_based_routing_rules) > 0 ? length(var.path_based_routing_rules) : 0

  listener_arn = var.certificate_arn != "" ? aws_lb_listener.https.arn : aws_lb_listener.http.arn
  priority     = var.path_based_routing_rules[count.index].priority # Lower number = higher priority

  # Priority explained:
  # - Rules are evaluated in priority order (1, 2, 3, ...)
  # - First matching rule is executed
  # - If no rules match, default action is used

  # Action: forward matching requests to target group
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary.arn
  }

  # Condition: match requests with specific URL paths
  condition {
    path_pattern {
      values = var.path_based_routing_rules[count.index].path_patterns
      # Example: ["/api/*", "/v1/*"] routes /api/users and /v1/products
    }
  }

  # Use cases for path-based routing:
  # - /api/* -> API backend target group
  # - /static/* -> Static content servers
  # - /admin/* -> Admin application servers

  tags = merge(
    var.tags,
    {
      Name        = "${local.alb_name}-rule-${count.index}"
      Environment = var.environment
    }
  )
}

# ============================================================================
# CLOUDWATCH ALARMS - Monitoring and Alerting
# ============================================================================
# CloudWatch alarms monitor ALB metrics and send notifications when thresholds are breached

# Alarm for unhealthy targets
# Triggers when backend instances fail health checks
resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.alb_name}-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"               # Alert when value > threshold
  evaluation_periods  = "2"                                  # Number of consecutive periods before alerting
  metric_name         = "UnHealthyHostCount"                 # AWS metric for unhealthy target count
  namespace           = "AWS/ApplicationELB"                 # AWS service namespace
  period              = "300"                                # Evaluation period: 300 seconds = 5 minutes
  statistic           = "Average"                            # Use average value during period
  threshold           = var.unhealthy_target_alarm_threshold # Alert if unhealthy count > this value
  alarm_description   = "This metric monitors unhealthy targets in the target group"
  treat_missing_data  = "notBreaching" # Don't alarm if no data is available

  # Why this matters:
  # - Unhealthy targets can't serve traffic
  # - If all targets are unhealthy, service is down
  # - Early detection prevents complete outages

  # Identify which resources to monitor
  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix # Shortened ARN for CloudWatch
    TargetGroup  = aws_lb_target_group.primary.arn_suffix
  }

  # Send notifications to SNS topic
  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : [] # Alert when alarm triggers
  ok_actions    = var.sns_topic_arn != "" ? [var.sns_topic_arn] : [] # Alert when alarm resolves

  tags = merge(
    var.tags,
    {
      Name        = "${local.alb_name}-unhealthy-alarm"
      Environment = var.environment
    }
  )
}

# Alarm for high response time
# Triggers when backend instances respond slowly
resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.alb_name}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime" # Time for target to respond (seconds)
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = var.response_time_alarm_threshold # Alert if response time > this value (seconds)
  alarm_description   = "This metric monitors target response time"
  treat_missing_data  = "notBreaching"

  # Slow response times indicate:
  # - Backend performance issues
  # - Database bottlenecks
  # - Insufficient resources (CPU, memory)
  # - Network latency

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }

  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions    = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  tags = merge(
    var.tags,
    {
      Name        = "${local.alb_name}-response-time-alarm"
      Environment = var.environment
    }
  )
}

# Alarm for 5xx errors
# Triggers when backend instances return server errors
resource "aws_cloudwatch_metric_alarm" "http_5xx_errors" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.alb_name}-http-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count" # Count of 5xx errors from targets
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"                        # Total count during period
  threshold           = var.http_5xx_alarm_threshold # Alert if errors > this count
  alarm_description   = "This metric monitors 5xx errors from targets"
  treat_missing_data  = "notBreaching"

  # HTTP status codes:
  # - 5xx = Server errors (500, 502, 503, 504)
  # - 500: Internal server error
  # - 502: Bad gateway (backend unreachable)
  # - 503: Service unavailable (no healthy targets)
  # - 504: Gateway timeout (backend too slow)

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }

  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions    = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  tags = merge(
    var.tags,
    {
      Name        = "${local.alb_name}-5xx-errors-alarm"
      Environment = var.environment
    }
  )
}
