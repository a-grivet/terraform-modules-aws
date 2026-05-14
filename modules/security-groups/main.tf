# ============================================================================
# SECURITY GROUPS MODULE - main.tf
# ============================================================================
# This module creates security groups for a 3-tier application architecture:
# 1. ALB Security Group: Controls internet -> load balancer traffic
# 2. Application Security Group: Controls ALB -> app tier traffic
# 3. Database Security Group: Controls app tier -> database traffic
# 4. Redis Security Group (optional): Controls app tier -> cache traffic
#
# Traffic flow:
# Internet -> ALB (80/443) -> App Tier (custom port) -> Database / Redis
# ============================================================================

# ============================================================================
# LOCAL VALUES
# ============================================================================
# Locals centralize naming and tags so every resource follows the same
# conventions without duplicating the logic on each resource block.

# ============================================================================
# ALB SECURITY GROUP
# ============================================================================
# The ALB is the only public entry point. It accepts internet traffic and then
# forwards requests only to the application tier.

resource "aws_security_group" "alb" {
  name_prefix = "${local.name_prefix}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-alb-sg"
      Tier = "load-balancer"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ALB Ingress: HTTP from internet
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = var.allowed_cidr_blocks[0] # Default: 0.0.0.0/0

  description = "Allow HTTP from internet"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-alb-http-ingress" }
  )
}

# ALB Ingress: HTTPS from internet (optional)
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  count = var.enable_https ? 1 : 0

  security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = var.allowed_cidr_blocks[0]

  description = "Allow HTTPS from internet"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-alb-https-ingress" }
  )
}

# ALB Egress: To application tier
resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id = aws_security_group.alb.id

  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.app.id

  # Using a security group reference instead of a CIDR keeps the rule aligned
  # with autoscaling workloads where instance IPs can change at any time.
  description = "Allow traffic to application tier"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-alb-to-app-egress" }
  )
}

# ============================================================================
# APPLICATION SECURITY GROUP
# ============================================================================
# The application tier receives traffic only from the ALB, then talks to the
# database, optional cache, and selected internet endpoints for package/API use.

resource "aws_security_group" "app" {
  name_prefix = "${local.name_prefix}-app-"
  description = "Security group for application tier"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-app-sg"
      Tier = "application"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# App Ingress: From ALB
resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id = aws_security_group.app.id

  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.alb.id

  description = "Allow traffic from ALB"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-app-from-alb-ingress" }
  )
}

# App Ingress: SSH from bastion (optional)
resource "aws_vpc_security_group_ingress_rule" "app_ssh_from_bastion" {
  count = var.enable_ssh_bastion ? 1 : 0

  security_group_id = aws_security_group.app.id

  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = var.bastion_security_group_id

  # Useful mainly for EC2/ASG-based application tiers.
  description = "Allow SSH from bastion"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-app-ssh-from-bastion-ingress" }
  )
}

# App Egress: To database
resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id = aws_security_group.app.id

  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.db.id

  description = "Allow connection to database"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-app-to-db-egress" }
  )
}

# App Egress: To Redis (optional)
resource "aws_vpc_security_group_egress_rule" "app_to_redis" {
  count = var.enable_redis ? 1 : 0

  security_group_id = aws_security_group.app.id

  ip_protocol                  = "tcp"
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  referenced_security_group_id = aws_security_group.redis[0].id

  description = "Allow connection to Redis"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-app-to-redis-egress" }
  )
}

# App Egress: HTTPS to internet
resource "aws_vpc_security_group_egress_rule" "app_to_internet_https" {
  security_group_id = aws_security_group.app.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"

  # Typical uses:
  # - Package updates
  # - Calls to external APIs
  # - Access to managed AWS service endpoints
  description = "Allow HTTPS to internet"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-app-to-internet-https-egress" }
  )
}

# App Egress: HTTP to internet
resource "aws_vpc_security_group_egress_rule" "app_to_internet_http" {
  security_group_id = aws_security_group.app.id

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"

  # Still useful for package repositories or legacy HTTP-only endpoints.
  description = "Allow HTTP to internet"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-app-to-internet-http-egress" }
  )
}

# ============================================================================
# DATABASE SECURITY GROUP
# ============================================================================
# The database is private by design: only the application tier, and optionally
# a bastion host for troubleshooting, can reach it.

resource "aws_security_group" "db" {
  name_prefix = "${local.name_prefix}-db-"
  description = "Security group for database"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-db-sg"
      Tier = "database"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# DB Ingress: From application tier
resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id = aws_security_group.db.id

  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.app.id

  description = "Allow connection from application tier"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-db-from-app-ingress" }
  )
}

# DB Ingress: From bastion (optional)
resource "aws_vpc_security_group_ingress_rule" "db_from_bastion" {
  count = var.enable_db_bastion_access ? 1 : 0

  security_group_id = aws_security_group.db.id

  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = var.bastion_security_group_id

  # Keep disabled by default: this is meant for exceptional admin/troubleshooting
  # access, not day-to-day application traffic.
  description = "Allow connection from bastion for troubleshooting"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-db-from-bastion-ingress" }
  )
}

# ============================================================================
# REDIS SECURITY GROUP (OPTIONAL)
# ============================================================================
# Redis is only needed for architectures with a dedicated cache tier, so the
# whole security group is created only when enable_redis is true.

resource "aws_security_group" "redis" {
  count = var.enable_redis ? 1 : 0

  name_prefix = "${local.name_prefix}-redis-"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-redis-sg"
      Tier = "cache"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Redis Ingress: From application tier
resource "aws_vpc_security_group_ingress_rule" "redis_from_app" {
  count = var.enable_redis ? 1 : 0

  security_group_id = aws_security_group.redis[0].id

  ip_protocol                  = "tcp"
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  referenced_security_group_id = aws_security_group.app.id

  description = "Allow Redis connection from application tier"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-redis-from-app-ingress" }
  )
}

# Redis Egress: Allow all outbound (for replication between nodes)
resource "aws_vpc_security_group_egress_rule" "redis_egress_all" {
  count = var.enable_redis ? 1 : 0

  security_group_id = aws_security_group.redis[0].id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  # ElastiCache clusters may need east-west communication between nodes,
  # replication partners, or managed control-plane interactions.
  description = "Allow all outbound traffic for node replication"

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-redis-egress-all" }
  )
}
