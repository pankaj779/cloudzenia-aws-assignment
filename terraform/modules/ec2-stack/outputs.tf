# EC2 Stack Module Outputs

output "ec2_instance_1_id" {
  description = "ID of EC2 Instance 1"
  value       = aws_instance.ec2_1.id
}

output "ec2_instance_1_private_ip" {
  description = "Private IP of EC2 Instance 1"
  value       = aws_instance.ec2_1.private_ip
}

output "ec2_instance_1_public_ip" {
  description = "Public IP (Elastic IP) of EC2 Instance 1"
  value       = aws_eip.ec2_1.public_ip
}

output "ec2_instance_2_id" {
  description = "ID of EC2 Instance 2"
  value       = aws_instance.ec2_2.id
}

output "ec2_instance_2_private_ip" {
  description = "Private IP of EC2 Instance 2"
  value       = aws_instance.ec2_2.private_ip
}

output "ec2_instance_2_public_ip" {
  description = "Public IP (Elastic IP) of EC2 Instance 2"
  value       = aws_eip.ec2_2.public_ip
}

output "ec2_instance_ids" {
  description = "List of EC2 instance IDs"
  value       = [aws_instance.ec2_1.id, aws_instance.ec2_2.id]
}

output "ec2_elastic_ips" {
  description = "List of Elastic IPs"
  value       = [aws_eip.ec2_1.public_ip, aws_eip.ec2_2.public_ip]
}

