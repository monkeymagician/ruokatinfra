variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "651109015678"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "ruokat"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "192.168.10.0/24"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "192.168.10.0/25"
}

variable "lambda_layer_arn" {
  description = "Pillow Lambda Layer ARN"
  type        = string
  default     = "arn:aws:lambda:ap-northeast-2:770693421928:layer:Klayers-p312-Pillow:4"
}

variable "admin_email" {
  description = "Admin email for SNS subscription"
  type        = string
}
