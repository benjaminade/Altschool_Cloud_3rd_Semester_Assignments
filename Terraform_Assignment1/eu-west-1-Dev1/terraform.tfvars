  environment = "development1"
  vpc_cidr = "10.11.0.0/16"
  subnet_cidr = ["10.11.0.0/24","10.11.1.0/24"]
  key_pair_name="dev1-key-pair"
  private-key-filename="dev1-key-pair.pem"
  instance_type = "t2.micro"
  map_public_ip_on_launch_true_false = true
  