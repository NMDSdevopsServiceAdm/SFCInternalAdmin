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

# the production environment requires a Route 53 hosting zone; the zone is automatically created when an AWS domain name is registered
# the hosted zone is publiv (not private) because it is managing a public DNS space
data "aws_route53_zone" "asc-hosted-zone" {
  name = "${var.asc_domain_name}."
  private_zone = false
}

data "aws_instance" "strapi_ec2" {
  instance_id = "${module.strapi-demo.strapi_ec2_id}"
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.asc-hosted-zone.zone_id}"
  name    = "www.${data.aws_route53_zone.asc-hosted-zone.name}"
  type    = "A"
  ttl     = "300"
  records = ["${data.aws_instance.strapi_ec2.public_ip}"]
}

resource "aws_route53_record" "root" {
  zone_id = "${data.aws_route53_zone.asc-hosted-zone.zone_id}"
  name    = "${data.aws_route53_zone.asc-hosted-zone.name}"
  type    = "A"
  ttl     = "300"
  records = ["${data.aws_instance.strapi_ec2.public_ip}"]
}