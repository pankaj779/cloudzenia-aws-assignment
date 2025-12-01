# ALB Module Outputs

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "wordpress_tg_arn" {
  description = "ARN of WordPress target group"
  value       = aws_lb_target_group.wordpress.arn
}

output "microservice_tg_arn" {
  description = "ARN of Microservice target group"
  value       = aws_lb_target_group.microservice.arn
}

output "https_listener_arn" {
  description = "ARN of HTTPS listener"
  value       = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : ""
}

