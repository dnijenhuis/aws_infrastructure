# This file contains the descriptions and characteristics of the variables in the terraform.tfvars file.

variable "aws_access_key" {
  description = "AWS access key"
  type = string
  sensitive   = true  
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type = string
  sensitive   = true  
}

variable "ami_ids" {
  description = "AMI IDs for each region"
  type = map(string)
}

variable "instance_type" {
  description = "The type of instance to use"
  type = string
}

variable "key_names" {
  description = "Key names for each region"
  type = map(string)
}

variable "user_data_script" {
  description = "Script for the web servers"
  type        = string
}

variable "certificate_arn_us_east_1" {
  description = "ARN of the SSL certificate for us-east-1"
  type = string
}

variable "certificate_arn_eu_central_1" {
  description = "ARN of the SSL certificate for eu-central-1"
  type = string
}

variable "client_certificate_arn_root" {
  description = "needed for VPN: ARN of the certificate imported in AWS, created by openSSL"
  type = string
}

variable "arn_lb_us_east_1" {
  description = "ARN of the ALB"
  type = string
}

variable "arn_lb_eu_central_1" {
  description = "ARN of the ALB"
  type = string
}

