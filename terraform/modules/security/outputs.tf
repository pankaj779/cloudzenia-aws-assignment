# Security Module Outputs

output "alb_sg_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb.id
}

output "ecs_service_sg_id" {
  description = "Security group ID for ECS services"
  value       = aws_security_group.ecs_service.id
}

output "rds_sg_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

output "ec2_sg_id" {
  description = "Security group ID for EC2 instances"
  value       = aws_security_group.ec2.id
}

