variable "ecs_cluster_name" {
  default = "my-ecs-cluster"
}

variable "aws_profile" {
  description = "Profile set up as an Env Variable using TF_VAR_"
  type        = string
  default     = ""
}

variable "bucket" {
  description = "Bucket where tfstate are store"
  type        = string
  default     = "crowdar-tfstate-test"
}

variable "region" {
  description = "Region where is deploy"
  type        = string
  default     = "us-east-2"
}

variable "enviroment"{
  description = "Enviroment define"
  type = string
  default = "sandbox"
}

variable "ecs_capacity_name" {
  description = "Capacity Provider's Name"
  type        = string
  default     = "docker-getting-started"
}

variable "ecs_max_scaling_size" {
  description = "Max capacity scaling size"
  type        = number
  default     =  1000
}

variable "ecs_min_scaling_size" {
  description = "Min capacity scaling size"
  type        = number
  default     =  1
}

variable "ecs_target_capacity" {
  description = "Target capacity"
  type        = number
  default     = 1
}

variable "container_name" {
  description = "Containers' Name"
  type        = string
  default     = "docker"  
}

variable "container_launch_type" {
  description = "Where to deploy our containers"
  type        = string
  default     = "EC2"
}

variable "svc_name" {
  description = ""
  type        = string
  default     = "docker-service"
}
