# ALB Module - Application Load Balancer

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb"
    }
  )
}

# Target Group for WordPress
resource "aws_lb_target_group" "wordpress" {
  name        = "${substr(var.project_name, 0, 10)}-${var.environment}-wp-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Required for ECS Fargate with awsvpc network mode

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    protocol            = "HTTP"
  }

  deregistration_delay = 30

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-wordpress-tg"
    }
  )
}

# Target Group for Microservice
resource "aws_lb_target_group" "microservice" {
  name        = "${substr(var.project_name, 0, 10)}-${var.environment}-ms-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Required for ECS Fargate with awsvpc network mode

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    protocol            = "HTTP"
  }

  deregistration_delay = 30

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-microservice-tg"
    }
  )
}

# HTTP Listener - Always forward to WordPress (ensures target groups are attached)
# We'll update to redirect when certificate is ready
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  # Always forward to WordPress for now (ensures target group is attached)
  # When certificate is ready, manually update this to redirect to HTTPS
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.wordpress.arn
      }
    }
  }
}

# HTTPS Listener (only create if certificate ARN is provided)
resource "aws_lb_listener" "https" {
  count = var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}

# HTTP Listener Rule for WordPress (works without certificate)
# Only create if hostname is provided and doesn't have trailing dot
resource "aws_lb_listener_rule" "wordpress_http" {
  count = var.wordpress_hostname != "" && !endswith(var.wordpress_hostname, ".") ? 1 : 0
  
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }

  condition {
    host_header {
      values = [trim(var.wordpress_hostname, ".")]
    }
  }
}

# HTTP Listener Rule for Microservice
# Always create with path condition to ensure target group is attached
# Add hostname condition if valid
resource "aws_lb_listener_rule" "microservice_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.microservice.arn
  }

  # Path condition to ensure target group is always attached
  condition {
    path_pattern {
      values = ["/microservice*"]
    }
  }

  # Add hostname condition if valid (both conditions = AND logic)
  dynamic "condition" {
    for_each = var.microservice_hostname != "" && !endswith(var.microservice_hostname, ".") ? [1] : []
    content {
      host_header {
        values = [trim(var.microservice_hostname, ".")]
      }
    }
  }
}

# HTTPS Listener Rule for WordPress (only if certificate exists and hostname is valid)
resource "aws_lb_listener_rule" "wordpress_https" {
  count = var.certificate_arn != "" && var.wordpress_hostname != "" && !endswith(var.wordpress_hostname, ".") ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }

  condition {
    host_header {
      values = [trim(var.wordpress_hostname, ".")]
    }
  }
}

# HTTPS Listener Rule for Microservice (only if certificate exists and hostname is valid)
resource "aws_lb_listener_rule" "microservice_https" {
  count = var.certificate_arn != "" && var.microservice_hostname != "" && !endswith(var.microservice_hostname, ".") ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.microservice.arn
  }

  condition {
    host_header {
      values = [trim(var.microservice_hostname, ".")]
    }
  }
}

