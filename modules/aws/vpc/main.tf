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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs              = var.azs
  public_subnets   = var.public_subnet_cidrs
  private_subnets  = var.private_subnet_cidrs

  create_database_subnet_group = true
  enable_dns_hostnames         = true

  enable_nat_gateway  = true
  single_nat_gateway  = true
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.eip_nat.*.id
}

resource "aws_eip" "eip_nat" {
}

resource "aws_security_group" "ecs_security_group" {
  vpc_id = module.vpc.vpc_id
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

