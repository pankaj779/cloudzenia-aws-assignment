# RDS Module - MySQL Database

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# DB Subnet Group (private subnets)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-subnet-group"
    }
  )
}

# RDS MySQL Instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-mysql"

  # Engine configuration
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro" # Free tier eligible

  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  # Database configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false # In private subnet

  # Backup configuration
  # Note: Free tier allows max 1 day retention, but assignment requires 7 days
  # If not on free tier, change this to 7
  backup_retention_period = 1 # Free tier limit (assignment requires 7, but free tier max is 1)
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  # Additional settings
  skip_final_snapshot       = true # For easier cleanup
  deletion_protection       = false
  multi_az                  = false # Single AZ to save costs
  auto_minor_version_upgrade = true

  # Monitoring
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-mysql"
    }
  )
}

