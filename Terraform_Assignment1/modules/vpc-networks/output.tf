output "vpc_id" {
  value = aws_vpc.project-vpc.id
}

output "subnet_id" {
  value = aws_subnet.project-subnet[*].id
}

output "key_pair_id" {
  value = aws_key_pair.testkey.id
}