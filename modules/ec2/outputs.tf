output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_public_ips" {
  description = "List of public IPs"
  value       = aws_instance.web[*].public_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.web.id
}
