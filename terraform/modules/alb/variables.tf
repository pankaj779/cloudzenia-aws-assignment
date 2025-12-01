# ALB Module Variables

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (leave empty to create ALB without HTTPS first)"
  type        = string
  default     = ""
}

variable "wordpress_hostname" {
  description = "Hostname for WordPress (e.g., wordpress.example.com)"
  type        = string
}

variable "microservice_hostname" {
  description = "Hostname for Microservice (e.g., microservice.example.com)"
  type        = string
}

