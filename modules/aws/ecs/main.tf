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
  name = "docker-getting-started"

  auto_scaling_group_provider {
    auto_scaling_group_arn = data.terraform_remote_state.asg.outputs.asg_arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
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
  family             = "my-ecs-task"
  network_mode       = "awsvpc"
  execution_role_arn = "arn:aws:iam::403811705992:role/ecsTaskExecutionRole"
  cpu                = 256
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      name   = "test1"
      image  = "public.ecr.aws/k9h8z0a5/docker-getting-started:latest"
      cpu    = 256
      memory = 512
      healthcheck = {
        command = ["CMD-SHELL", "echo 'healthy' || exit 1"]
      }
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1

  network_configuration {
    subnets         = [data.terraform_remote_state.vpc.outputs.subnet_public_id_a,data.terraform_remote_state.vpc.outputs.subnet_public_id_b]
    security_groups = [data.terraform_remote_state.vpc.outputs.security_group_id]
  }

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = timestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.ec2.outputs.tg_arn
    container_name   = "test1"
    container_port   = 80
  }

}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.my_ecs_cluster.id
}
