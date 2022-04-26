#https://medium.com/swlh/creating-an-instance-in-a-newly-designed-vpc-using-terraform-440a220d3886
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}


resource "aws_vpc" "vpcprod" {
    cidr_block = "11.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    
    tags = {
        Name = "prod-vpc"
    }
}

resource "aws_subnet" "prod-subnet" {
  vpc_id = aws_vpc.vpcprod.id
  availability_zone = "us-west-2a"
  cidr_block = "11.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpcprod.id

  tags = {
    Name = "prod-gw"
  }
}

resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.vpcprod.gw.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw
  }
}


resource "aws_security_group" "sg_ssh" {
  name = "sg_allows_ssh"
  vpc_id = aws_vpc.vpcprod.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# resource "aws_instance" "webapp" {
#   ami = "ami-074251216af698218"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "Instance"
#   }

# }



