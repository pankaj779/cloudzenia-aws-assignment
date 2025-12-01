# ECR Module - Container Registry

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ECR Repository for Microservice
resource "aws_ecr_repository" "microservice" {
  name                 = "${var.project_name}-${var.environment}-microservice"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-microservice-ecr"
    }
  )
}

# Lifecycle policy to keep only last 5 images
resource "aws_ecr_lifecycle_policy" "microservice" {
  repository = aws_ecr_repository.microservice.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

