resource "aws_vpc" "this_vpc" {
    cidr_block = "${lookup(var.cidr, var.env)}"
    assign_generated_ipv6_cidr_block = false
    enable_dns_hostnames = true
    tags = {
        Name = "${var.vpc_name}_${var.env}_vpc"
        Env = "${var.env}"
        Company = "SfC"
        Application = "InternalAdmin"
    }
}

resource "aws_subnet" "public_subnets" {
    count = "${var.num_of_avs}"
    availability_zone = "${var.region}${element(var.av_zones, count.index)}"
    cidr_block = "${lookup(var.subnets, "${var.env}_${element(var.av_zones, count.index)}_public")}"
    map_public_ip_on_launch = true
    vpc_id = "${aws_vpc.this_vpc.id}"
    tags = {
        Name = "${var.vpc_name}_${var.env}_public_${var.region}${element(var.av_zones, count.index)}"
        Env = "${var.env}"
        Company = "SfC"
        Application = "InternalAdmin"
    }
}

resource "aws_subnet" "private_subnets" {
    count = "${var.num_of_avs}"
    availability_zone = "${var.region}${element(var.av_zones, count.index)}"
    cidr_block = "${lookup(var.subnets, "${var.env}_${element(var.av_zones, count.index)}_private")}"
    map_public_ip_on_launch = false
    vpc_id = "${aws_vpc.this_vpc.id}"
    tags = {
        Name = "${var.vpc_name}_${var.env}_private_${var.region}${element(var.av_zones, count.index)}"
        Env = "${var.env}"
        Company = "SfC"
        Application = "InternalAdmin"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.this_vpc.id}"
    tags = {
        Name = "${var.vpc_name}_igw"
        Env = "${var.env}"
        Company = "SfC"
        Application = "InternalAdmin"
    }   
}

# public routing table - note, subnets can share the same routing table
resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.this_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "${var.vpc_name}_route_public"
    Env = "${var.env}"
    Company = "SfC"
    Application = "InternalAdmin"
  }
}

resource "aws_route_table_association" "public_subnet_routes" {
  count = "${var.num_of_avs}"
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route.id}"
}

# puts a bastion server in each of the public subnets
#  allowing SSH (security group) from Internet to the bastion only.


resource "aws_iam_role" "ec2-basic" {
  name = "${var.env}_${var.vpc_name}_ec2_basic_role"
  path = "/"
  tags = {
    Env = "${var.env}"
    Company = "SfC"
    Application = "InternalAdmin"
  }

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
output "vpc_ec2_basic_role_name" {
  value = "${aws_iam_role.ec2-basic.name}"
}

resource "aws_iam_instance_profile" "ec2_basic_profile" {
  name = "${var.env}_${var.vpc_name}_ec2_basic_profile"
  role = "${aws_iam_role.ec2-basic.name}"
}

data "aws_ami" "bastion_ami" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "bastion-ssh-proxy" {
    name = "sg_${var.env}_${var.vpc_name}_ssh_proxy"
    description = "Allows SSH inbound from Internet; to be used for SSH bastions only"
    vpc_id = "${aws_vpc.this_vpc.id}"

    # allow SSH inbound from anywhere (IP4/IP6)
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow SSH outbound to VPC only
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${lookup(var.cidr, var.env)}"]
    }

    tags = {
        Name = "sg_${var.env}_${var.vpc_name}_ssh_proxy"
        Company = "SfC"
        Application = "InternalAdmin"
        Role = "bastion"
    }
}

resource "aws_instance" "bastions" {
  ami           = "${data.aws_ami.bastion_ami.id}"
  instance_type = "t2.micro"
  source_dest_check = true
  count = "${var.num_of_avs}"
  subnet_id = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2_basic_profile.name}"
  vpc_security_group_ids = [
    "${aws_security_group.bastion-ssh-proxy.id}"
  ]
  key_name = "${var.key_pair_name}"
  depends_on = ["aws_internet_gateway.igw", "aws_security_group.bastion-ssh-proxy"]
  
  tags = {
    Name = "${var.env}_${var.vpc_name}_bastion_${count.index}"
    Company = "SfC"
    Application = "InternalAdmin"
    Role = "bastion"
  }

  connection {
    user = "ec2-user"
    private_key = "${var.private_key_location}"
  }
}
