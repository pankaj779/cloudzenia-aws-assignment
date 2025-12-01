# Stage 1: Network Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (for ALB, NAT Gateway)"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (for ECS, RDS, EC2)"
  value       = module.network.private_subnet_ids
}

# Stage 2: Security Group Outputs
output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = module.security.alb_sg_id
}

output "ecs_sg_id" {
  description = "ECS Security Group ID"
  value       = module.security.ecs_service_sg_id
}

output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = module.security.rds_sg_id
}

output "ec2_sg_id" {
  description = "EC2 Security Group ID"
  value       = module.security.ec2_sg_id
}

# Stage 3: IAM Outputs
output "ecs_task_execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  value       = module.iam.ecs_task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ECS Task Role ARN"
  value       = module.iam.ecs_task_role_arn
}

output "ec2_instance_profile_name" {
  description = "EC2 Instance Profile Name"
  value       = module.iam.ec2_instance_profile_name
}

# Stage 4: Secrets Manager Outputs
output "secrets_arn" {
  description = "Secrets Manager ARN for RDS credentials"
  value       = module.secrets.secret_arn
}

# Stage 5: RDS Outputs
output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = module.rds.address
}

output "rds_port" {
  description = "RDS port"
  value       = module.rds.port
}

# Stage 6: ECS Cluster Outputs
output "ecs_cluster_id" {
  description = "ECS Cluster ID"
  value       = module.ecs_cluster.id
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = module.ecs_cluster.name
}

# Stage 8: ALB Outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb_ecs.alb_dns_name
}

output "wordpress_url" {
  description = "WordPress URL"
  value       = "https://wordpress.${var.domain_name}"
}

output "microservice_url" {
  description = "Microservice URL"
  value       = "https://microservice.${var.domain_name}"
}

# Stage 9: ECR Outputs
output "ecr_repository_url" {
  description = "ECR Repository URL for microservice"
  value       = module.ecr_microservice.repository_url
}

# Stage 7: ECS Services Outputs
output "wordpress_service_name" {
  description = "WordPress ECS Service name"
  value       = module.ecs_service_wordpress.service_name
}

output "microservice_service_name" {
  description = "Microservice ECS Service name"
  value       = module.ecs_service_microservice.service_name
}

# Stage 10: EC2 Stack Outputs
output "ec2_instance_1_public_ip" {
  description = "Public IP (Elastic IP) of EC2 Instance 1"
  value       = module.ec2_stack.ec2_instance_1_public_ip
}

output "ec2_instance_2_public_ip" {
  description = "Public IP (Elastic IP) of EC2 Instance 2"
  value       = module.ec2_stack.ec2_instance_2_public_ip
}

output "ec2_elastic_ips" {
  description = "List of EC2 Elastic IPs"
  value       = module.ec2_stack.ec2_elastic_ips
}

# Stage 11: ALB for EC2 Outputs
output "ec2_alb_dns_name" {
  description = "DNS name of EC2 ALB"
  value       = module.alb_ec2.alb_dns_name
}

output "ec2_alb_instance_url" {
  description = "URL for ec2-alb-instance route"
  value       = "https://ec2-alb-instance.${var.domain_name}"
}

output "ec2_alb_docker_url" {
  description = "URL for ec2-alb-docker route"
  value       = "https://ec2-alb-docker.${var.domain_name}"
}

# Stage 13: GitHub Actions Outputs
output "github_actions_role_arn" {
  description = "ARN of GitHub Actions IAM role (for OIDC)"
  value       = var.github_actions_enabled ? module.iam.github_actions_role_arn : ""
}
