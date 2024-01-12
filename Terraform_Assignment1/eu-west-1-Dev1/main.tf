
module "vpc" {
  source               = "../modules/vpc-networks"
  vpc_cidr             = var.vpc_cidr
  subnet_cidr          = var.subnet_cidr
  key_pair_name        = var.key_pair_name
  private-key-filename = var.private-key-filename
  environment          = var.environment
  map_public_ip_on_launch_true_false = var.map_public_ip_on_launch_true_false

  
}

module "ec2" {
  source = "../modules/ec2-instance"
  instance_type         = var.instance_type
  key_pair_name         = module.vpc.key_pair_id
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.subnet_id
  private-key-filename  = var.private-key-filename
  environment           = var.environment
  
}