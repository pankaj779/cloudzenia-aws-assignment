# IAM Module Outputs

output "ecs_task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

output "ec2_instance_profile_name" {
  description = "Name of EC2 instance profile"
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_instance_profile_arn" {
  description = "ARN of EC2 instance profile"
  value       = aws_iam_instance_profile.ec2.arn
}

output "github_actions_role_arn" {
  description = "ARN of GitHub Actions IAM role (for OIDC)"
  value       = var.github_actions_enabled ? aws_iam_role.github_actions[0].arn : ""
}

