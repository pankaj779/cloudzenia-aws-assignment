# ECS Service Module Variables

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "service_name" {
  description = "Name of the service (wordpress or microservice)"
  type        = string
}

variable "cluster_id" {
  description = "ECS Cluster ID"
  type        = string
}

variable "container_name" {
  description = "Container name"
  type        = string
}

variable "container_image" {
  description = "Container image (Docker image URL)"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "cpu" {
  description = "CPU units (256, 512, 1024, etc.)"
  type        = number
}

variable "memory" {
  description = "Memory in MB (512, 1024, 2048, etc.)"
  type        = number
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN (for Secrets Manager access)"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables (map)"
  type        = map(string)
  default     = {}
}

variable "secrets_from_secrets_manager" {
  description = "Secrets from Secrets Manager (list of objects with name and valueFrom)"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 4
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70.0
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80.0
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

