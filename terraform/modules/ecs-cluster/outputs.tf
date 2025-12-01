# ECS Cluster Module Outputs

output "id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

