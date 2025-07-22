terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

#create Internet gateway
resource "aws_internet_gateway" "main-internet-gw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "main-internet-gw"
  }
}

#create a subnet

resource "aws_subnet" "main-subnet-1" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "main-subnet-1"
  }
}

#create route table
resource "aws_route_table" "main-route-table" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-internet-gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id             = aws_internet_gateway.main-internet-gw.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Associate the route table with the subnet

resource "aws_route_table_association" "subnet-1" {
  subnet_id      = aws_subnet.main-subnet-1.id
  route_table_id = aws_route_table.main-route-table.id
}


# Create a security group

resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
  ingress {
    description = "SHH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks  = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_web_traffic"
  }
}

#create a netwrok interface with an ip in the subnet 
resource "aws_network_interface" "main-network-itf" {
  subnet_id       = aws_subnet.main-subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web_traffic.id]
}


#assign an elastic IP to the network interface
resource "aws_eip" "one" {
  domain   = "vpc"
  network_interface         = aws_network_interface.main-network-itf.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.main-internet-gw]
}

#create an ubuntu server EC2 instance

resource "aws_instance" "ubuntu-server" {
  ami           = "ami-05f991c49d264708f"
  instance_type = "t2.micro"
  availability_zone = "us-west-2a"
  key_name = "terrafrom-ec2-access-key-pair"

  network_interface {
    network_interface_id = aws_network_interface.main-network-itf.id
    device_index         = 0
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > /var/www/html/index.html
              sudo apt-get update
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
            EOF

  tags = {
    Name = "HelloWorld"
  }
}