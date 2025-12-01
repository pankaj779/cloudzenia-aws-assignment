# Security Groups Module - Least Privilege Rules

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Security Group for ALB (Public-facing)
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # HTTP from internet
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from internet
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb-sg"
    }
  )
}

# Security Group for ECS Services (Private)
resource "aws_security_group" "ecs_service" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Security group for ECS services"
  vpc_id      = var.vpc_id

  # Allow traffic from ALB only
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow outbound to RDS and internet
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-sg"
    }
  )
}

# Security Group for RDS (Private)
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  # MySQL port from ECS services only
  ingress {
    description     = "MySQL from ECS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service.id]
  }

  # No outbound rules needed for RDS

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-sg"
    }
  )
}

# Security Group for EC2 Instances
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  # SSH from internet (required for manual setup: Docker, NGINX, Let's Encrypt)
  ingress {
    description = "SSH from internet (for manual configuration)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP from internet (for direct domain access: ec2-instance1.domain, ec2-docker1.domain)
  # These domains point directly to Elastic IPs, not through ALB
  ingress {
    description = "HTTP from internet (direct domain access)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from internet (for direct domain access with Let's Encrypt)
  ingress {
    description = "HTTPS from internet (direct domain access)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP from ALB (for ALB domains: ec2-alb-instance.domain, ec2-alb-docker.domain)
  ingress {
    description     = "HTTP from ALB (for ALB domain routing)"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow all outbound
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-sg"
    }
  )
}

