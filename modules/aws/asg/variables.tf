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

variable "enviroment" {
  description = "Enviroment define"
  type        = string
  default     = "sandbox"
}

variable "max_size" {
  description = "Max amount of EC2 instance deploy by the AutocSalingGroup"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Min amount of EC2 instance deploy by the AutocSalingGroup"
  type        = number
  default     = 1
}

variable "desire_capacity" {
  description = "Number of Amazon EC2 instances that should be running in the group"
  type        = number
  default     = 1
}

variable "asg_name" {
  description = "Name for the Auto Scaling Group"
  type = string
  default = "ecs-capacity-provider"
}