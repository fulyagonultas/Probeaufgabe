terraform {
  cloud {
    organization = "companyname"
    workspaces {
      name = "Probeaufgabe"
    }
  }

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
  region  = var.my_region
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    name   = "VPC for ECS"
    source = "Terraform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW for ECS"
  }
}

resource "aws_route" "route" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_security_group" "sg" {
  name   = "My SG"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol    = -1
    self        = true
    from_port   = 0
    to_port     = 0
    description = "Port 0"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Port 80"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}