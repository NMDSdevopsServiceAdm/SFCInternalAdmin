# nodebeats
Creates an EC2 instance for a demo installation of KeystoneJS CMS using an Atlas instance of MongoDB.

# Inputs
* `region` - the region in which the VPC is created
* `vpc_name` - the name of the VPC; defauls to "internalAdmin".
* `env` - the name of the environment, which is used to identify VPC CIDR block range, availability zones and subnets, and is used to name with format ".*[env]_[region.*"
* `key_pair_name` - the name of the SSH key pair, used when instantiating the bastion server
* `private_key_location` - the location of the private key PEM file associated with the key_pair_name, used when instantiating the bastion server

# Limitations
* Manual app install

# References
* https://keystonejs.netlify.com