# EC2 Stack Module Variables

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs (need at least 2)"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for EC2 instances"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for NGINX logs"
  type        = string
}

