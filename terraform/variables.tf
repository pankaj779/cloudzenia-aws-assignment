# Stage 1: Basic Variables
variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "cloudzenia-hands-on"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

# Stage 4: Secrets Manager Variables
variable "db_username" {
  description = "Database username for WordPress"
  type        = string
  default     = "wp_admin"
}

variable "db_password" {
  description = "Database password for WordPress (REQUIRED: 8-41 chars, uppercase, lowercase, number, special char, no /, \", ', \\, @, spaces)"
  type        = string
  sensitive   = true
}

# Stage 8: ALB Variables
variable "domain_name" {
  description = "Root domain name (e.g., aws-cloudzenia.mooo.com)"
  type        = string
  default     = ""
}

variable "ecs_certificate_arn" {
  description = "ACM certificate ARN for ECS ALB (ap-south-1)"
  type        = string
  default     = ""
}

variable "ec2_certificate_arn" {
  description = "ACM certificate ARN for EC2 ALB (ap-south-1)"
  type        = string
  default     = ""
}

# Stage 13: GitHub Actions Variables
variable "github_actions_enabled" {
  description = "Enable GitHub Actions IAM role creation"
  type        = bool
  default     = false
}

variable "github_repository_subject" {
  description = "GitHub repository subject for OIDC (e.g., 'repo:username/repo-name:*')"
  type        = string
  default     = ""
}
