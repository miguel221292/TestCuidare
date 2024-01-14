locals {
  aws_region       = var.region
  environment_name = var.enviroment
  tags = {
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
    key = "key/terraform.ecs.tfstate"
  }
}

provider "aws" {
  region  = local.aws_region
  profile = var.aws_profile
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
    config = {
      bucket = var.bucket
      key = "key/terraform.vpc.tfstate"
      region = var.region
      profile = var.aws_profile
    }
}


data "terraform_remote_state" "ec2" {
  backend = "s3"
    config = {
      bucket = var.bucket
      key = "key/terraform.ec2.tfstate"
      region = var.region
      profile = var.aws_profile
    }
}

data "terraform_remote_state" "asg" {
  backend = "s3"
    config = {
      bucket = var.bucket
      key = "key/terraform.asg.tfstate"
      region = var.region
      profile = var.aws_profile
    }
}


resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = var.ecs_capacity_name

  auto_scaling_group_provider {
    auto_scaling_group_arn = data.terraform_remote_state.asg.outputs.asg_arn

    managed_scaling {
      maximum_scaling_step_size = var.ecs_max_scaling_size
      minimum_scaling_step_size = var.ecs_min_scaling_size
      status                    = "ENABLED"
      target_capacity           = var.ecs_target_capacity
    }
  }

}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.my_ecs_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family             = var.task_definition_name
  network_mode       = "bridge"
  execution_role_arn = "arn:aws:iam::403811705992:role/ecsTaskExecutionRole"
  cpu                = var.cpu
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = var.container_protocol
        }
      ]
      secrets = [
        {
          valueFrom = var.secrets_arn
          name      = var.secret_name
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name                  = var.svc_name
  cluster               = aws_ecs_cluster.my_ecs_cluster.id
  task_definition       = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count         = 1
  launch_type           = var.container_launch_type
  force_new_deployment  = true

  load_balancer {
    target_group_arn = data.terraform_remote_state.ec2.outputs.tg_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.my_ecs_cluster.id
}
