// inherited from main
variable "env" {
}
variable "region" {
}

// local to module
variable "vpc_name" {
    type = string
    default = "internalAdmin"
}

variable "key_pair_name" {   
    type = string
}
variable "private_key_location" {
    type = string
    description = "Full file path to the private key, associated with key_pair_name"
}

variable "num_of_avs" {
    description = "The number of AVs to create"
    default = 1
}

variable "cidr" {
    type = map(string)
    default = {
        dev             = "192.168.0.0/24"
        test            = "192.168.100.0/24"
        acceptance      = "172.16.0.0/16"
        production      = "10.0.0.0/16"
    }
}
variable "subnets" {
    type = map(string)
    default = {
        dev_a_public           = "192.168.0.0/27"
        dev_a_private          = "192.168.0.32/27"
        dev_b_public           = "192.168.0.64/27"
        dev_b_private          = "192.168.0.96/27"
        dev_c_public           = "192.168.0.128/27"
        dev_c_private          = "192.168.0.160/27"
        test_a_public          = "192.168.100.0/27"
        test_a_private         = "192.168.100.32/27"
        test_b_public          = "192.168.100.64/27"
        test_b_private         = "192.168.100.96/27"
        test_c_public          = "192.168.100.128/27"
        test_c_private         = "192.168.100.160/27"
        production_a_public    = "10.0.0.0/24"
        production_a_private   = "10.0.1.0/24"
        production_b_public    = "10.0.100.0/24"
        production_b_private   = "10.0.110.0/24"
        production_c_public    = "10.0.200.0/24"
        production_c_private   = "10.0.210.0/24"
    }
}
variable "av_zones" {
    type = list(string)
    default = [
        "a",
        "b",
        "c"
    ]
}
