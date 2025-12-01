# Network Module Variables

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (prod, staging, etc.)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
}

