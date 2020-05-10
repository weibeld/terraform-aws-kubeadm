output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the created VPC."
}

output "subnet_id" {
  value       = aws_subnet.main.id
  description = "ID of the created subnet."
}
