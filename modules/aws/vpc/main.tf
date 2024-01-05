locals {
  aws_region = var.region
  environment_name = var.enviroment
  profile = var.aws_profile
  tags = {
    ops_env = "${local.environment_name}"
    ops_managed_by  = "terraform"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.37.0"
    }
  }
  backend "s3" {
    key = "key/terraform.vpc.tfstate"
  }
}

provider "aws" {
  region = local.aws_region
  profile = local.profile
}

resource "aws_vpc" "vpc_ecs" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    ops_env             = "${local.environment_name}"
    ops_managed_by      = "terraform"
    Name                = "ECS VPC"
  }
}

resource "aws_subnet" "public_subnets" {
  count               = length(var.public_subnet_cidrs)
  vpc_id              = aws_vpc.vpc_ecs.id
  cidr_block          = element(var.public_subnet_cidrs, count.index)
  availability_zone   = element(var.azs, count.index)
  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count               = length(var.private_subnet_cidrs)
  vpc_id              = aws_vpc.vpc_ecs.id
  cidr_block          = element(var.private_subnet_cidrs, count.index)
  availability_zone   = element(var.azs, count.index)
  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "public_internet_gateway" {
  vpc_id = aws_vpc.vpc_ecs.id

  tags = {
    Name = "ECS Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
 vpc_id = aws_vpc.vpc_ecs.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.public_internet_gateway.id
 }
 
 tags = {
   Name = "Public Route Table"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count          = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.public_rt.id
}



resource "aws_nat_gateway" "private_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = element(aws_subnet.private_subnets[*].id, 0)
  depends_on    = [aws_internet_gateway.public_internet_gateway]
}

resource "aws_route_table" "private_rt" {
 vpc_id = aws_vpc.vpc_ecs.id
 tags = {
   Name = "Private Route Table"
 }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private_rt.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private_nat_gateway.id
}

resource "aws_route_table_association" "private_subnet_asso" {
 count          = length(var.private_subnet_cidrs)
 subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
 route_table_id = aws_route_table.private_rt.id
}

resource "aws_eip" "my_eip" {
  domain = "vpc"
}

resource "aws_security_group" "ecs_security_group" {
  vpc_id = aws_vpc.vpc_ecs.id

  name        = "ECS Security Group"
  description = "Allow inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allowed_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allowed_ip]
  }
}

