variable "aws_region" {
  description = "Region for the VPC"
  default = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "192.168.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR for the public subnet"
  default = "192.168.0.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR for the Public subnet"
  default = "192.168.1.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR for the Private-1 subnet"
  default = "192.168.2.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR for the Private-2 subnet"
  default = "192.168.3.0/24"
}



variable "ami" {
  description = "Amazon Linux AMI"
  default = "ami-0e306788ff2473ccb"

}

