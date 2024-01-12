  environment = "production2"
  vpc_cidr = "10.14.0.0/16"
  subnet_cidr = ["10.14.0.0/24","10.14.1.0/24"]
  key_pair_name="prod2-key-pair"
  private-key-filename="prod2-key-pair.pem"
  instance_type = "t2.micro"
  map_public_ip_on_launch_true_false = true
  