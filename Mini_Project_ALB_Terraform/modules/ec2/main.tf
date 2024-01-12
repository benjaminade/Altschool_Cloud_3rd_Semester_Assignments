# Create a key pair to be used by the ec2 to ssh
resource "aws_key_pair" "testkey" {
  key_name   = var.key-pair-name
  public_key = tls_private_key.rsa.public_key_openssh
}

# Create a private key
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Put the private key in a local file
resource "local_file" "testkey_private" {
  content  = tls_private_key.rsa.private_key_pem
  filename = var.private-key-filename
}

# Use data resource to retrieve the region-specific ami for our ec2s
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID for Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Creating the security group for oue ec2s and the alb
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Security Group"
  vpc_id      = var.test_vpc_id

  # Ingress rule for SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Ingress rule for http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   # Ingress rule for http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Allow all traffic to go out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # All traffic
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic to any destination
  }

  tags = {
    Name = "${var.project_name}-Sg"
  }

}

# Now lets create instances to reside in each of the subnets
resource "aws_instance" "public-server" {
  count                  = length(var.public_subnets_cidr)
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key-pair-name
  depends_on             = [ aws_key_pair.testkey ]
  subnet_id              = var.subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.alb-sg.id]

  tags = {
    Name = "${var.project_name}-Server${count.index + 1}"
  }

}

# The public ips of our ec2s are save in this local file with the heading of WEB_SERVERS
resource "local_file" "save_public_ips_to_inventory" {
  content = <<-EOT
    [WEB_SERVERS]
    ${join("\n", aws_instance.public-server.*.public_ip)}
  EOT
  filename = "host-inventory.ini"
}

# Now lets create a Control Host with which we run Ansible
resource "aws_instance" "control-server" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key-pair-name
  depends_on             = [aws_instance.public-server]
  subnet_id              = var.subnet_id[0]
  vpc_security_group_ids = [aws_security_group.alb-sg.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install ansible -y
              EOF

  # Provisioner block to copy files from the local machine to the EC2 instance
  # We copy the ssh key .pem to the control host
    provisioner "file" {
    source      = "./altschool-alb.pem"
    destination = "/tmp/altschool-alb.pem"  # Change the destination path as needed
  }
  # Here , we copy the host-inventory file to the control host
    provisioner "file" {
    source      = "./host-inventory.ini"
    destination = "/tmp/host-inventory.ini"  # Change the destination path as needed
  }
  # Here, we copy the already written asible playbook to the control host
    provisioner "file" {
    source      = "./deploy_apache1.yml"
    destination = "/tmp/deploy_apache1.yml"  # Change the destination path as needed
  }

  # Here, we copy the already written custom html doc to the control host
    provisioner "file" {
    source      = "./custom_page.html.j2"
    destination = "/tmp/custom_page.html.j2"  # Change the destination path as needed
    }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private-key-filename)
  }

  # Remote-exec provisioner block to run commands on the control hot EC2 instance
    provisioner "remote-exec" {
    inline = [
      "mv /tmp/altschool-alb.pem /home/ubuntu/",
      "mv /tmp/host-inventory.ini /home/ubuntu/",
      "mv /tmp/deploy_apache1.yml /home/ubuntu/",
      "mv /tmp/custom_page.html.j2 /home/ubuntu/",
      "chmod 400 /home/ubuntu/altschool-alb.pem",
    ]
  }
  
  tags = {
    Name = "Control_Server"
  }

}

