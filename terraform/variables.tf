variable "aws_region" {
  description = "AWS region for CHAOSCLOUD infrastructure"
  type        = string
  default     = "ap-south-1"
}

variable "admin_cidr" {
  description = "Public IP address allowed to access administration services"
  type        = string
}