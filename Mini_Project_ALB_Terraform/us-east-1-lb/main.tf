# Call on module to create the vpc and its network components
module "vpc" {
  source = "../modules/vpc-nets"
  public_subnets_cidr = var.public_subnets_cidr
  vpc_cidr_block = var.vpc_cidr_block
  project_name = var.project_name

}

# Call on the module to create the ec2 instances
module "ec2" {
  source = "../modules/ec2"
  public_subnets_cidr = var.public_subnets_cidr
  instance_type = var.instance_type
  subnet_id = module.vpc.public_subnet_ids
  test_vpc_id = module.vpc.test_vpc_id
  project_name = var.project_name
  key-pair-name = var.key-pair-name
  private-key-filename = var.private-key-filename

}

#Call the module to create alb
module "alb" {
  source = "../modules/alb"
  project_name = var.project_name
  security_group = module.ec2.aws_security_group
  test_vpc_id = module.vpc.test_vpc_id
  public_subnet_cidr = var.public_subnets_cidr
  subnet_id = module.vpc.public_subnet_ids
  instance_ids = module.ec2.instance_ids
  domain_name = var.domain_name
  record_name1 = var.record_name1
  
  
}

output "ec2_public_ip" {
  value = module.ec2.ec2_public_ip
}

output "ec2_private_ips" {
  value = module.ec2.ec2_private_ips
}

output "lb_dns_name" {
  value = module.alb.lb_dns_name
}

output "instance_ids" {
  value = module.ec2.instance_ids
}


# After you,ve done terraform apply, wait for terraform to complete provisioning, then,
# ssh into the control host and run the ansible playbook as stated below:

# ansible-playbook -i host-inventory.ini --key-file=./altschool-alb.pem deploy_apache1.yml