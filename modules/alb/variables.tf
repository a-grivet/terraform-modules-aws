# ============================================================================
# ALB MODULE VARIABLES - variables.tf
# ============================================================================
# This file defines input variables for the Application Load Balancer module.
# Variables control ALB configuration, target groups, health checks, and monitoring.
# ============================================================================

# ============================================================================
# REQUIRED VARIABLES - Must Be Provided
# ============================================================================
# These variables have no default value and must be set when using this module

variable "vpc_id" {
  description = "ID of the VPC where the ALB will be deployed"
  type        = string
  # The VPC where backend instances and target groups exist
}

variable "app_id" {
  # 3rd segment of the organization naming convention: <prefix>-[np]-<app_id>-<env>-[label]
  description = "Application identifier (AppId) as registered in the your application catalog."
  type        = string
}

variable "environment" {
  # 4th segment of the organization naming convention. Drives the np segment automatically.
  description = "Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod)."
  type        = string

  validation {
    condition     = contains(["c", "t", "d", "s", "p"], var.environment)
    error_message = "environment must be one of: c (poc), t (test/sandbox), d (dev), s (stage), p (prod)."
  }
}

variable "label" {
  # Optional 5th segment of the organization naming convention.
  description = "Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a')."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs where ALB will be deployed (minimum 2 for HA)"
  type        = list(string)

  # Input validation: ensure high availability with multiple subnets
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnets are required for ALB high availability."
  }
  # ALB requires subnets in at least 2 different Availability Zones
  # This ensures service remains available if one AZ fails
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the ALB"
  type        = list(string)

  # Input validation: ensure at least one security group is provided
  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security group ID must be provided."
  }
  # Security groups act as virtual firewalls controlling ALB traffic
}

# ============================================================================
# ALB CONFIGURATION - Core Load Balancer Settings
# ============================================================================

variable "internal" {
  description = "Whether the load balancer is internal (true) or internet-facing (false)"
  type        = bool
  default     = false
  # false = internet-facing (public, accepts traffic from internet)
  # true = internal (private, only accepts traffic from within VPC)
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB (recommended for production)"
  type        = bool
  default     = false
  # When enabled, prevents accidental deletion via console or API
  # Must be explicitly disabled before deletion
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
  # true = Distribute traffic evenly across all targets in all AZs
  # false = Distribute traffic only within each AZ independently
  # Recommended: true (better load distribution)
}

variable "enable_http2" {
  description = "Enable HTTP/2 protocol"
  type        = bool
  default     = true
  # HTTP/2 benefits:
  # - Multiplexing: multiple requests over single connection
  # - Header compression: reduces overhead
  # - Server push: proactive content delivery
  # Recommended: true for modern applications
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid HTTP header fields (security best practice)"
  type        = bool
  default     = true
  # Protects against:
  # - Header injection attacks
  # - Malformed requests
  # Recommended: true for security
}

variable "idle_timeout" {
  description = "Time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60

  # Input validation: ensure timeout is within AWS limits
  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "Idle timeout must be between 1 and 4000 seconds."
  }
  # Idle timeout explained:
  # - How long ALB keeps connection open without data transfer
  # - Default 60s works for most applications
  # - Increase for: long-polling, WebSockets, streaming
}

# ============================================================================
# TARGET GROUP CONFIGURATION - Backend Instance Management
# ============================================================================

variable "target_group_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80

  # Input validation: ensure valid port number
  validation {
    condition     = var.target_group_port > 0 && var.target_group_port <= 65535
    error_message = "Port must be between 1 and 65535."
  }
  # Common ports:
  # - 80: HTTP
  # - 443: HTTPS
  # - 8080: Alternative HTTP
}

variable "target_group_protocol" {
  description = "Protocol to use for routing traffic to targets (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"

  # Input validation: restrict to supported protocols
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_group_protocol)
    error_message = "Protocol must be either HTTP or HTTPS."
  }
  # HTTP: ALB forwards unencrypted traffic to backends (common)
  # HTTPS: ALB forwards encrypted traffic to backends (end-to-end encryption)
}

variable "target_type" {
  description = "Type of target (instance, ip, or lambda)"
  type        = string
  default     = "instance"

  # Input validation: restrict to supported target types
  validation {
    condition     = contains(["instance", "ip", "lambda"], var.target_type)
    error_message = "Target type must be one of: instance, ip, lambda."
  }
  # Target types explained:
  # - "instance": EC2 instances (Auto Scaling Groups)
  # - "ip": IP addresses (ECS containers, on-premises servers)
  # - "lambda": AWS Lambda functions (serverless)
}

variable "deregistration_delay" {
  description = "Time in seconds to wait for in-flight requests to complete before deregistering a target"
  type        = number
  default     = 300

  # Input validation: ensure delay is within AWS limits
  validation {
    condition     = var.deregistration_delay >= 0 && var.deregistration_delay <= 3600
    error_message = "Deregistration delay must be between 0 and 3600 seconds."
  }
  # Deregistration delay (connection draining) explained:
  # - When removing an instance, ALB waits this long for active requests to complete
  # - Prevents abrupt connection termination during deployments
  # - 300s (5 minutes) = good default
  # - Reduce in dev (30-60s) for faster deployments
}

# ============================================================================
# HEALTH CHECK CONFIGURATION - Monitor Backend Instance Health
# ============================================================================
# Health checks determine if backend instances are available to receive traffic

variable "health_check_enabled" {
  description = "Enable health checks"
  type        = bool
  default     = true
  # Should always be true (health checks are critical for high availability)
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health check successes required before considering a target healthy"
  type        = number
  default     = 3

  # Input validation: ensure threshold is within AWS limits
  validation {
    condition     = var.health_check_healthy_threshold >= 2 && var.health_check_healthy_threshold <= 10
    error_message = "Healthy threshold must be between 2 and 10."
  }
  # 3 = conservative (instance must pass 3 checks before receiving traffic)
  # 2 = faster recovery (instance receives traffic sooner)
  # Higher values = more confidence in instance health
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering a target unhealthy"
  type        = number
  default     = 3

  # Input validation: ensure threshold is within AWS limits
  validation {
    condition     = var.health_check_unhealthy_threshold >= 2 && var.health_check_unhealthy_threshold <= 10
    error_message = "Unhealthy threshold must be between 2 and 10."
  }
  # 3 = tolerant (allows temporary failures)
  # 2 = faster detection (removes unhealthy instances quickly)
  # Lower values = faster failover, but may be too sensitive
}

variable "health_check_timeout" {
  description = "Time in seconds to wait for a health check response"
  type        = number
  default     = 5

  # Input validation: ensure timeout is within AWS limits
  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "Health check timeout must be between 2 and 120 seconds."
  }
  # If instance doesn't respond within this time, health check fails
  # Must be less than health_check_interval
}

variable "health_check_interval" {
  description = "Time in seconds between health checks"
  type        = number
  default     = 30

  # Input validation: ensure interval is within AWS limits
  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds."
  }
  # How often ALB sends health check requests
  # 30s = good balance (not too frequent, not too slow)
  # Lower values = faster detection but more load on instances
}

variable "health_check_path" {
  description = "Path for health check requests"
  type        = string
  default     = "/health"
  # The URL path ALB requests to check instance health
  # Your application must implement this endpoint
  # Example responses:
  # - /health -> 200 OK (instance is healthy)
  # - /health -> 503 Service Unavailable (instance is unhealthy)
}

variable "health_check_protocol" {
  description = "Protocol for health checks (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"

  # Input validation: restrict to supported protocols
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.health_check_protocol)
    error_message = "Health check protocol must be either HTTP or HTTPS."
  }
  # Should match target_group_protocol for simplicity
}

variable "health_check_matcher" {
  description = "HTTP status codes to use when checking for a successful response from a target"
  type        = string
  default     = "200"
  # Examples:
  # - "200" = Only HTTP 200 OK is considered healthy
  # - "200-299" = Any 2xx status code is healthy
  # - "200,202" = HTTP 200 or 202 is healthy
}

# ============================================================================
# STICKINESS CONFIGURATION - Session Affinity
# ============================================================================
# Stickiness routes requests from the same client to the same backend instance

variable "enable_stickiness" {
  description = "Enable session stickiness (session affinity)"
  type        = bool
  default     = false
  # When to enable:
  # - Stateful applications
  # When to disable:
  # - Stateless applications (better load distribution)
}

variable "stickiness_type" {
  description = "Type of stickiness (lb_cookie for ALB-generated cookies, app_cookie for application cookies)"
  type        = string
  default     = "lb_cookie"

  # Input validation: restrict to supported types
  validation {
    condition     = contains(["lb_cookie", "app_cookie"], var.stickiness_type)
    error_message = "Stickiness type must be either lb_cookie or app_cookie."
  }
  # Types explained:
  # - "lb_cookie": ALB generates and manages cookies (simpler)
  # - "app_cookie": Application generates cookies (more control)
}

variable "stickiness_cookie_duration" {
  description = "Time period in seconds during which requests should be routed to the same target"
  type        = number
  default     = 86400

  # 86400s = 24 hours (good for daily sessions)
  # Adjust based on your application's session lifetime

  validation {
    condition     = var.stickiness_cookie_duration >= 1 && var.stickiness_cookie_duration <= 604800
    error_message = "Cookie duration must be between 1 and 604800 seconds (7 days)."
  }
}

# ============================================================================
# SSL/TLS CONFIGURATION - HTTPS Security
# ============================================================================

variable "certificate_arn" {
  description = "ARN of the SSL certificate to attach to the HTTPS listener (leave empty for HTTP only)"
  type        = string
  default     = ""
  # Provide certificate ARN from ACM module to enable HTTPS
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener (only used if certificate_arn is provided)"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
  # SSL policies define:
  # - Minimum TLS version (1.0, 1.1, 1.2, 1.3)
  # - Allowed cipher suites (encryption algorithms)
  # Common policies:
  # - ELBSecurityPolicy-TLS-1-2-2017-01: TLS 1.2+ (recommended, secure)
  # - ELBSecurityPolicy-TLS-1-3-2021-06: TLS 1.3+ (most secure, modern browsers only)
  # - ELBSecurityPolicy-2016-08: TLS 1.0+ (legacy, less secure)
}

# ============================================================================
# ACCESS LOGS CONFIGURATION - Audit and Troubleshooting
# ============================================================================

variable "enable_access_logs" {
  description = "Enable ALB access logs to S3"
  type        = bool
  default     = false
  # Access logs record all requests (useful for auditing and troubleshooting)
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs (required if enable_access_logs is true)"
  type        = string
  default     = ""
  # The S3 bucket must exist and have proper permissions for ALB to write logs
}

variable "access_logs_prefix" {
  description = "S3 bucket prefix for ALB access logs"
  type        = string
  default     = "alb-logs"
  # Folder path within S3 bucket where logs are stored
}

# ============================================================================
# LISTENER RULES CONFIGURATION - Advanced Routing
# ============================================================================

variable "path_based_routing_rules" {
  description = "List of path-based routing rules for the listener"
  type = list(object({
    priority      = number       # Rule priority
    path_patterns = list(string) # URL paths to match (e.g., ["/api/*", "/v1/*"])
  }))
  default = []
  # Example configuration:
  # [
  #   {
  #     priority      = 100
  #     path_patterns = ["/api/*"]
  #   }
  # ]
  # This routes /api/* requests differently (useful for microservices)
}

# ============================================================================
# CLOUDWATCH ALARMS CONFIGURATION - Monitoring and Alerting
# ============================================================================

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for ALB monitoring"
  type        = bool
  default     = true
  # Recommended: true (monitoring is critical for production)
}

variable "unhealthy_target_alarm_threshold" {
  description = "Number of unhealthy targets to trigger alarm"
  type        = number
  default     = 1
  # Alert if at least 1 backend instance is unhealthy
  # Adjust based on your total instance count
}

variable "response_time_alarm_threshold" {
  description = "Response time in seconds to trigger alarm"
  type        = number
  default     = 5
  # Alert if average response time exceeds 5 seconds
  # Adjust based on your application's SLA
}

variable "http_5xx_alarm_threshold" {
  description = "Number of 5xx errors to trigger alarm"
  type        = number
  default     = 10
  # Alert if more than 10 server errors occur in a 5-minute period
  # Adjust based on your traffic volume
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  type        = string
  default     = ""
  # Provide SNS topic ARN to receive email/SMS alerts
  # Empty string = alarms exist but don't send notifications
}

# ============================================================================
# TAGS - Resource Organization and Cost Tracking
# ============================================================================

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
  # Tags are key-value pairs for organizing AWS resources
  # Example: { "CostCenter" = "IT", "Owner" = "TeamA" }
}
