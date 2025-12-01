# ALB Module for EC2 Instances

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Application Load Balancer for EC2
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-ec2-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-alb"
    }
  )
}

# Target Group for "Hello from Instance" (Instance-based for EC2)
resource "aws_lb_target_group" "instance" {
  name        = substr("${var.project_name}-${var.environment}-ec2-inst-tg", 0, 32)
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance" # EC2 instances use instance-based target groups

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
      Name = "${var.project_name}-${var.environment}-ec2-instance-tg"
    }
  )
}

# Target Group for "Namaste from Container" (Docker) - Instance-based for EC2
resource "aws_lb_target_group" "docker" {
  name        = substr("${var.project_name}-${var.environment}-ec2-dock-tg", 0, 32)
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance" # EC2 instances use instance-based target groups

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    path                = "/docker"
    matcher             = "200"
    protocol            = "HTTP"
  }

  deregistration_delay = 30

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-docker-tg"
    }
  )
}

# Register EC2 instances to target groups
resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.instance.arn
  target_id        = var.ec2_instance_1_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.instance.arn
  target_id        = var.ec2_instance_2_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "docker_1" {
  target_group_arn = aws_lb_target_group.docker.arn
  target_id        = var.ec2_instance_1_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "docker_2" {
  target_group_arn = aws_lb_target_group.docker.arn
  target_id        = var.ec2_instance_2_id
  port             = 80
}

# HTTP Listener - Forward to instance target group (HTTP only for now)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  # Forward to instance target group (HTTP only - SSL will be added later)
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.instance.arn
      }
    }
  }
}

# HTTP Listener Rule for "ec2-alb-instance" hostname
resource "aws_lb_listener_rule" "instance" {
  count = var.instance_hostname != "" && !endswith(var.instance_hostname, ".") ? 1 : 0
  
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance.arn
  }

  condition {
    host_header {
      values = [trim(var.instance_hostname, ".")]
    }
  }
}

# HTTP Listener Rule for "ec2-alb-docker" hostname
resource "aws_lb_listener_rule" "docker" {
  count = var.docker_hostname != "" && !endswith(var.docker_hostname, ".") ? 1 : 0
  
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.docker.arn
  }

  condition {
    host_header {
      values = [trim(var.docker_hostname, ".")]
    }
  }
}

# HTTP Listener Rule for /docker path (works without domain)
resource "aws_lb_listener_rule" "docker_path" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.docker.arn
  }

  condition {
    path_pattern {
      values = ["/docker*"]
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
    target_group_arn = aws_lb_target_group.instance.arn
  }
}

# HTTPS Listener Rule for "ec2-alb-instance" hostname
resource "aws_lb_listener_rule" "instance_https" {
  count = var.certificate_arn != "" && var.instance_hostname != "" && !endswith(var.instance_hostname, ".") ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance.arn
  }

  condition {
    host_header {
      values = [trim(var.instance_hostname, ".")]
    }
  }
}

# HTTPS Listener Rule for "ec2-alb-docker" hostname
resource "aws_lb_listener_rule" "docker_https" {
  count = var.certificate_arn != "" && var.docker_hostname != "" && !endswith(var.docker_hostname, ".") ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.docker.arn
  }

  condition {
    host_header {
      values = [trim(var.docker_hostname, ".")]
    }
  }
}

