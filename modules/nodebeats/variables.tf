// inherited from main
variable "env" {}
variable "region" {}
variable "vpc_name" { }
variable "key_pair_name" {}
variable "private_key_location" {}
variable "subnet" {}

// inherited from vpc module
variable "aws_vpc" {}
variable "aws_ec2_basic_profile" {}
variable "aws_igw" {}
