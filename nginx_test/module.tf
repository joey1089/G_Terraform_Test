# These code are working fine after test - it deployes single ec2 instances with nginx hosted page
# this data block gets info for resources from terrafoorm
data "aws_ami" "aws_ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -------Create Resources with ami-id for us-east-1
resource "aws_instance" "aws_ubuntu" {
  instance_type   = "t2.micro"
  ami             = "ami-06878d265978313ca"
  subnet_id       = aws_subnet.subnet_east1a.id
  security_groups = [aws_security_group.myown_sg.id]
  key_name        = var.key_name
  user_data       = file("userdata.sh")
}


#Create Custom VPC
resource "aws_vpc" "myvpc_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc_vpc"
  }
}
# create subnet for each AZ's
resource "aws_subnet" "subnet_east1a" {
  vpc_id                  = aws_vpc.myvpc_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-us-east-1a"
  }
}
#Create internet gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc_vpc.id
  tags = {
    Name = "igw"
  }
}

#Create a Route Table and add router with igw and allow all
resource "aws_route_table" "igw_public_rt" {
  vpc_id = aws_vpc.myvpc_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Route Table"
  }
}

#Create Route Table explicit assoication  with the public subnet
resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_subnet.subnet_east1a.id
  route_table_id = aws_route_table.igw_public_rt.id
}

# Security group
resource "aws_security_group" "myown_sg" {
  name        = "myown_sg"
  description = "allow ssh on 22 & http on port 80"
  vpc_id      = aws_vpc.myvpc_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# OUTPUT
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.aws_ubuntu.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.aws_ubuntu.public_ip
}
