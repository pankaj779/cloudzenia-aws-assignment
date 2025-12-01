# Stage 1: Networking Infrastructure
locals {
  # Using 2 AZs for 2 public and 2 private subnets
  azs = ["ap-south-1a", "ap-south-1b"]
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  azs          = local.azs
}

# Stage 2: Security Groups
module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
}

# Stage 5: RDS MySQL Database (created before secrets to avoid circular dependency)
module "rds" {
  source = "./modules/rds"

  project_name     = var.project_name
  environment      = var.environment
  subnet_ids       = module.network.private_subnet_ids
  security_group_id = module.security.rds_sg_id
  db_name          = "wordpress"
  db_username      = var.db_username
  db_password      = var.db_password
}

# Stage 4: Secrets Manager (uses RDS endpoint)
module "secrets" {
  source = "./modules/secrets"

  project_name = var.project_name
  environment  = var.environment
  db_username  = var.db_username
  db_password  = var.db_password
  db_name      = "wordpress"
  rds_endpoint = module.rds.address # RDS endpoint from above
}

# Stage 3: IAM Roles (uses secrets ARN)
module "iam" {
  source = "./modules/iam"

  project_name        = var.project_name
  environment         = var.environment
  secrets_manager_arns = [module.secrets.secret_arn]
  
  # Stage 13: GitHub Actions
  github_actions_enabled     = var.github_actions_enabled
  github_repository_subject  = var.github_repository_subject
}

# Stage 6: ECS Cluster
module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  project_name = var.project_name
  environment  = var.environment
}

# Stage 8: ALB for ECS Services
module "alb_ecs" {
  source = "./modules/alb"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.network.vpc_id
  public_subnet_ids   = module.network.public_subnet_ids
  security_group_id   = module.security.alb_sg_id
  certificate_arn     = var.ecs_certificate_arn
  wordpress_hostname  = "wordpress.${var.domain_name}"
  microservice_hostname = "microservice.${var.domain_name}"
}

# Stage 9: ECR Repository for Microservice
module "ecr_microservice" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

# Stage 7: ECS Service - WordPress
module "ecs_service_wordpress" {
  source = "./modules/ecs-service"

  project_name     = var.project_name
  environment      = var.environment
  service_name     = "wordpress"
  cluster_id       = module.ecs_cluster.id
  container_name   = "wordpress"
  container_image  = "public.ecr.aws/docker/library/wordpress:6.4"
  container_port   = 80
  cpu              = 512
  memory           = 1024
  desired_count    = 1
  subnet_ids       = module.network.private_subnet_ids
  security_group_ids = [module.security.ecs_service_sg_id]
  target_group_arn  = module.alb_ecs.wordpress_tg_arn
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn     = module.iam.ecs_task_role_arn
  aws_region        = var.aws_region

  environment_variables = {
    WORDPRESS_DB_HOST = module.rds.address
    WORDPRESS_DB_NAME = "wordpress"
  }

  secrets_from_secrets_manager = [
    {
      name      = "WORDPRESS_DB_USER"
      valueFrom = "${module.secrets.secret_arn}:username::"
    },
    {
      name      = "WORDPRESS_DB_PASSWORD"
      valueFrom = "${module.secrets.secret_arn}:password::"
    }
  ]

  enable_auto_scaling = true
  min_capacity        = 1
  max_capacity        = 4
  cpu_target_value    = 70.0
  memory_target_value = 80.0
}

# Stage 7: ECS Service - Microservice
module "ecs_service_microservice" {
  source = "./modules/ecs-service"

  project_name     = var.project_name
  environment      = var.environment
  service_name     = "microservice"
  cluster_id       = module.ecs_cluster.id
  container_name   = "microservice"
  container_image  = "${module.ecr_microservice.repository_url}:latest"
  container_port   = 3000
  cpu              = 256
  memory           = 512
  desired_count    = 1
  subnet_ids       = module.network.private_subnet_ids
  security_group_ids = [module.security.ecs_service_sg_id]
  target_group_arn  = module.alb_ecs.microservice_tg_arn
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn     = module.iam.ecs_task_role_arn
  aws_region        = var.aws_region

  enable_auto_scaling = true
  min_capacity        = 1
  max_capacity        = 4
  cpu_target_value    = 70.0
  memory_target_value = 80.0
}

# Stage 12: CloudWatch Log Group for EC2 NGINX logs
resource "aws_cloudwatch_log_group" "ec2_nginx" {
  name              = "/ec2/${var.project_name}-${var.environment}-nginx"
  retention_in_days = 7

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Name        = "${var.project_name}-${var.environment}-nginx-logs"
  }
}

# Stage 10: EC2 Stack
module "ec2_stack" {
  source = "./modules/ec2-stack"

  project_name            = var.project_name
  environment             = var.environment
  private_subnet_ids       = module.network.private_subnet_ids
  security_group_id       = module.security.ec2_sg_id
  instance_profile_name   = module.iam.ec2_instance_profile_name
  cloudwatch_log_group_name = aws_cloudwatch_log_group.ec2_nginx.name
}

# Stage 11: ALB for EC2 Instances
module "alb_ec2" {
  source = "./modules/alb-ec2"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.network.vpc_id
  public_subnet_ids   = module.network.public_subnet_ids
  security_group_id   = module.security.alb_sg_id
  ec2_instance_1_id   = module.ec2_stack.ec2_instance_1_id
  ec2_instance_2_id   = module.ec2_stack.ec2_instance_2_id
  certificate_arn     = var.ec2_certificate_arn
  instance_hostname   = "ec2-alb-instance.${var.domain_name}"
  docker_hostname     = "ec2-alb-docker.${var.domain_name}"
}
