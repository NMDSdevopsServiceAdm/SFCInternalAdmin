output "aws_ec2_basic_profile" {
  value = aws_iam_instance_profile.ec2_basic_profile
}

output "aws_igw" {
  value = aws_internet_gateway.igw
}

output "aws_vpc" {
  value = aws_vpc.this_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "private_subsets" {
  value = aws_subnet.private_subnets
}