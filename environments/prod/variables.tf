variable "region" {
  default = "eu-west-1"
  description = "The AWS region"
  type = string
}

variable "env" {
    default = "production"
    type = string
}

variable "asc_domain_name" {
  type = string
  default = "asc-support.uk"
}