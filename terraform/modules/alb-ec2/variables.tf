# ALB Module for EC2 Variables

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

variable "ec2_instance_1_id" {
  description = "EC2 Instance 1 ID"
  type        = string
}

variable "ec2_instance_2_id" {
  description = "EC2 Instance 2 ID"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (leave empty to create ALB without HTTPS first)"
  type        = string
  default     = ""
}

variable "instance_hostname" {
  description = "Hostname for instance route (e.g., ec2-alb-instance.example.com)"
  type        = string
  default     = ""
}

variable "docker_hostname" {
  description = "Hostname for docker route (e.g., ec2-alb-docker.example.com)"
  type        = string
  default     = ""
}

