# Using data resource to obtain the ami id of the OS to install
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical's AWS account ID for Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

  resource "aws_security_group" "server-sg" {
  name = "server-sg"
  description = "Security Group"
  vpc_id = var.vpc_id

# Ingress rule for SSH traffic
  ingress {
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
# Ingress rule for http
  ingress {
    from_port    = 80
    to_port      = 80
    protocol     = "icmp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
  # Ingress rule for http
  ingress {
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
# Allow all traffic to go out
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # All traffic
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic to any destination
  }

tags = {
   Name = "${var.environment}-Sg"
}

}

# Now lets create two instances to reside each in eacch of the subnets
resource "aws_instance" "dev-server" {
  count = 2
  ami = data.aws_ami.latest_ubuntu.id
  instance_type = var.instance_type
  key_name = var.key_pair_name
  subnet_id = var.subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  user_data = <<-EOF
#!/bin/bash

# Update the package lists
sudo apt-get update -y

# Install Ansible
sudo apt-get install ansible -y

# Install Docker
sudo apt-get install docker.io -y

# Start and enable the Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add the user to the docker group to run Docker without sudo
sudo usermod -aG docker ubuntu
EOF

tags = {
   Name = "${var.environment}-Server${count.index +1}"
}

}
