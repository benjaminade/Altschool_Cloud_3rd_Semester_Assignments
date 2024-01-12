output "ec2_public_ip" {
  value = aws_instance.public-server[*].public_ip
}

output "aws_security_group" {
  value = aws_security_group.alb-sg.id
}

output "instance_ids" {
  value = aws_instance.public-server[*].id
}

output "ec2_private_ips" {
  value = aws_instance.public-server[*].private_ip
}