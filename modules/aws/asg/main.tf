locals {
  aws_region       = var.region
  environment_name = "sandbox"
  tags             = {
    ops_env              = "${local.environment_name}"
    ops_managed_by       = "terraform"
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
    key = "key/terraform.asg.tfstate"
  }
}

provider "aws" {
  region = local.aws_region
  profile = var.aws_profile
}

data terraform_remote_state "vpc"{  
    backend = "s3"
    config = {
      bucket = var.bucket
      key = "key/terraform.vpc.tfstate"
      region = var.region
      profile = var.aws_profile
    }
}


data terraform_remote_state "ec2"{  
    backend = "s3"
    config = {
      bucket = var.bucket
      key = "key/terraform.ec2.tfstate"
      region = var.region
      profile = var.aws_profile
    }
}

resource "aws_autoscaling_group" "ecs_asg" {
 vpc_zone_identifier = [data.terraform_remote_state.vpc.outputs.subnet_public_id_a]
 desired_capacity    = 1
 max_size            = 1
 min_size            = 1

 launch_template {
   id      = data.terraform_remote_state.ec2.outputs.ecs_lt_id
   version = "$Latest"
 }

 tag {
   key                 = "AmazonECSManaged"
   value               = true
   propagate_at_launch = true
 }
}