# Internal VPC
Create a reference VPC for hosting the internal admin services, having a public and a private subnet, with a bastion server deployed into the public subnet allowing all SSH to it.

# Inputs
* `region` - the region in which the VPC is created
* `vpc_name` - the name of the VPC; defauls to "internalAdmin".
* `env` - the name of the environment, which is used to identify VPC CIDR block range, availability zones and subnets, and is used to name with format ".*[env]_[region.*"
* `number_of_avs` - whether to create 1, 2 or 3 Availability Zones
* `key_pair_name` - the name of the SSH key pair, used when instantiating the bastion server
* `private_key_location` - the location of the private key PEM file associated with the key_pair_name, used when instantiating the bastion server

# Limitations
* No NAT Gateway - to allow outbound internet from private subnets
* No Network ACL - to restrict traffic to/from given source (CIDR range)
