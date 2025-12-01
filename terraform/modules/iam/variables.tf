# IAM Module Variables

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that ECS tasks can access"
  type        = list(string)
  default     = []
}

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

