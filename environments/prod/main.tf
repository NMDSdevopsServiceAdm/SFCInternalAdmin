provider "aws" {
  # access_key = "ACCESS_KEY_HERE"
  # secret_key = "SECRET_KEY_HERE"
  region     = "${var.region}"
  profile    = "prod-terraform"
  version    = "~> 2.8"
}

module "my-vpc" {
  region = "${var.region}"
  key_pair_name = "sfc-admin-prod"
  source = "../../modules/vpc"
  vpc_name = "internalAdmin"
  env = "${var.env}"
  num_of_avs = 1
  private_key_location = "${file("${path.module}/priv.key")}"
}

module "strapi-demo" {
  region = "${var.region}"
  key_pair_name = "sfc-admin-prod"
  vpc_name = "internalAdmin"
  source = "../../modules/strapi"
  env = "${var.env}"
  private_key_location = "${file("${path.module}/priv.key")}"
  aws_vpc = "${module.my-vpc.aws_vpc}"
  aws_igw = "${module.my-vpc.aws_igw}"
  aws_ec2_basic_profile = "${module.my-vpc.aws_ec2_basic_profile}"
  subnet = "${element(module.my-vpc.public_subnets.*.id, 0)}"
  instance_size = "t3a.medium"
}