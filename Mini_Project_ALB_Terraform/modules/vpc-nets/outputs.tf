output "test_vpc_id" {
  value = aws_vpc.test_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

