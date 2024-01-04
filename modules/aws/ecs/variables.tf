variable "ecs_cluster_name" {
  default = "my-ecs-cluster"
}

#variable "ecs_service1_task_definition" {
#  default = "YourTaskDefinitionArn1"
#}
#
#variable "ecs_service2_task_definition" {
#  default = "YourTaskDefinitionArn2"
#}
#
#variable "ecs_service1_security_group" {
#  default = "YourSecurityGroupId1"
#}
#
#variable "ecs_service2_security_group" {
#  default = "YourSecurityGroupId2"
#}

variable "aws_profile" {
  type        = string
  default     = ""
}

variable "bucket" {
  type        = string
  default     = "crowdar-tfstate-test"
}

variable "region" {
  type        = string
  default     = "us-east-2"
}