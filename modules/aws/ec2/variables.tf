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

variable "launch_template_name" {
  description = "Name for the Lauch Template"
  type = string
  default = "ecs-launch-template"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type = string 
  default = "t2.micro"
}

variable "image" {
  description = "Image use to deply EC2 instance compatible with ECS"
  type = string
  default = "ami-09c0b8e7f21923ac0"
}

variable "volume_size" {
  description = "Amount of space available in your disk when created"
  type        = number
  default     = 30  
}

variable "volume_type" {
  description = "The type of EBS volume"
  type        = string
  default     = "gp2" 
}

variable "health_check" {
  description = "Health Check of the app expose by the load balancer"
  type        = string
  default     = "/"
}

variable "ecs_tg_name" {
  description = "Name for the Target Group"
  type        = string
  default     = "ecs-target-group" 
}

variable "ecs_tg_port" {
  description = "Port for the Target Group"
  type        = number
  default     = 3000
}

variable "ecs_tg_protocol" {
  description = "Protocol for the Target Group"
  type        = string
  default     = "HTTP"
}

variable "ecs_lt_port" {
  description = "Port for the Listener"
  type        = number
  default     = 3000
}

variable "ecs_lt_protocol" {
  description = "Protocol for the Listener"
  type        = string
  default     = "HTTP"
}

variable "ecs_lb_name" {
  description = "Name for the Load Balancer"
  type = string
  default = "ecs-load-balancer"
}