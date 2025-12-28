output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR 블록"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = aws_vpc.main.arn
}

output "public_subnet_ids" {
  description = "Public 서브넷 ID 리스트"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private 서브넷 ID 리스트"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "Public 서브넷 CIDR 리스트"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "Private 서브넷 CIDR 리스트"
  value       = aws_subnet.private[*].cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Private Route Table ID 리스트"
  value       = aws_route_table.private[*].id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = length(aws_nat_gateway.main) > 0 ? aws_nat_gateway.main[0].id : null
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway Public IP"
  value       = length(aws_eip.nat) > 0 ? aws_eip.nat[0].public_ip : null
}