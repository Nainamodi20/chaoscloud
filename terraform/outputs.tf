output "vpc_id" {
  description = "CHAOSCLOUD VPC ID"
  value       = aws_vpc.chaoscloud.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1b.id
  ]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1b.id
  ]
}

output "internet_gateway_id" {
  description = "CHAOSCLOUD Internet Gateway ID"
  value       = aws_internet_gateway.chaoscloud.id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.private.id
}

output "application_security_group_id" {
  description = "Application security group ID"
  value       = aws_security_group.application.id
}

output "monitoring_security_group_id" {
  description = "Monitoring security group ID"
  value       = aws_security_group.monitoring.id
}