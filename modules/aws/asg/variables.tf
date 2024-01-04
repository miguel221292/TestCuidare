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