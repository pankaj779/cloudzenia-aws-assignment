# RDS Module Outputs

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "endpoint" {
  description = "RDS endpoint (hostname:port)"
  value       = aws_db_instance.main.endpoint
}

output "address" {
  description = "RDS address (hostname only)"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "RDS port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

