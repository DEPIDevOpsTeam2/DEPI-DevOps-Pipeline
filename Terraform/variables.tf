variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_instance_type" {
  description = "AWS ec2 type"
  type        = string
}

variable "aws_ec2_ami" {
  description = "AWS ec2 ami"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "key_pair_name" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "db_name" {
  description = "The port no."
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

