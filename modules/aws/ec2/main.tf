locals {
  aws_region       = var.region
  environment_name = "sandbox"
  profile          = var.aws_profile
  tags             = {
    ops_env              = "${local.environment_name}"
    ops_managed_by       = "terraform",
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
    key = "key/terraform.ec2.tfstate"
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
      profile = var.aws_profile
      region = var.region
    }
}

resource "aws_launch_template" "ecs_lt" {
 name_prefix   = "ecs-template"
 image_id      = "ami-09c0b8e7f21923ac0"
 instance_type = "t2.micro"
 key_name               = "ec2ecsglog"
 #vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.security_group_id]

 iam_instance_profile {
   name = "ecsInstanceRole"
 }

 network_interfaces {
    associate_public_ip_address = true
    security_groups = ["${data.terraform_remote_state.vpc.outputs.security_group_id}"]
 }

 block_device_mappings {
   device_name = "/dev/xvda"
   ebs {
     volume_size = 30
     volume_type = "gp2"
   }
 }

 tag_specifications {
   resource_type = "instance"
   tags = {
     Name = "ecs-instance"
   }
 }

 user_data = filebase64("${path.module}/ecs.sh")
}

resource "aws_lb" "ecs_alb" {
 name               = "ecs-alb"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [data.terraform_remote_state.vpc.outputs.security_group_id]
 subnets            = [data.terraform_remote_state.vpc.outputs.subnet_public_id_a, data.terraform_remote_state.vpc.outputs.subnet_public_id_b]

 tags = {
   Name = "ecs-alb"
    Env = "Dev"
    Created = "Terraform"
 }
}


resource "aws_lb_target_group" "ecs_tg" {
 name        = "ecs-target-group"
 port        = 80
 protocol    = "HTTP"
 target_type = "ip"
 vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

 health_check {
   path = "/"
 }
}

resource "aws_lb_listener" "ecs_alb_listener" {
 load_balancer_arn = aws_lb.ecs_alb.arn
 port              = 80
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.ecs_tg.arn
 }
}