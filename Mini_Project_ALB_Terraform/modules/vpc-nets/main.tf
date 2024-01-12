# Create a vpc
resource "aws_vpc" "test_vpc" {
  cidr_block = var.vpc_cidr_block
}

data "aws_availability_zones" "availability_zones" {}

# create subnets to house each ec2 instance
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets_cidr)
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = var.public_subnets_cidr[count.index]
  availability_zone = data.aws_availability_zones.availability_zones.names[count.index]
  map_public_ip_on_launch = true
}

# Create an internet gateway to route traffic to the internet
resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id

   tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create a route table 
resource "aws_route_table" "test_route_table" {
  vpc_id =  aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }

  tags = {
    Name = "${var.project_name}-route-table"
  }
}

# Now, Lets associate all the subnets with this route table
resource "aws_route_table_association" "test_rt_assoc" {
  count = length(var.public_subnets_cidr)
  route_table_id = aws_route_table.test_route_table.id
  subnet_id = aws_subnet.public_subnets[count.index].id
}


