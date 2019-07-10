data "aws_ami" "strapi_ami" {
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

resource "aws_iam_role" "ec2-strapi" {
  name = "${var.env}_${var.vpc_name}_ec2_strapi_role"
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
output "vpc_ec2_strapi_role_name" {
  value = "${aws_iam_role.ec2-strapi.name}"
}

resource "aws_iam_instance_profile" "ec2_strapi_profile" {
  name = "${var.env}_${var.vpc_name}_ec2_strapi_profile"
  role = "${aws_iam_role.ec2-strapi.name}"
}

resource "aws_security_group" "sg_strapi" {
    name = "sg_${var.env}_${var.vpc_name}_strapi"
    description = "Allows SSH/HTTP inbound from Internet"
    vpc_id = "${var.aws_vpc}"

    # allow SSH inbound from anywhere (IP4/IP6)
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 1337
        to_port = 1337
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 3001
        to_port = 3001
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow all traffic outbound
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
        Name = "sg_${var.env}_${var.vpc_name}_strapi"
        Company = "SfC"
        Application = "InternalAdmin"
        Role = "strapi"
    }
}

resource "aws_security_group" "sg_strapi_prod" {
    name = "sg_${var.env}_${var.vpc_name}_strapi_prod"
    description = "Allows SSH/HTTP inbound from Internet"
    vpc_id = "${var.aws_vpc}"

    # allow SSH inbound from anywhere (IP4/IP6)
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # target production ports
    # required for initial testing - but also letsencrypt
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow all traffic outbound
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
        Name = "sg_${var.env}_${var.vpc_name}_strapi"
        Company = "SfC"
        Application = "InternalAdmin"
        Role = "strapi"
    }
}

resource "aws_instance" "strapi" {
  ami           = "${data.aws_ami.strapi_ami.id}"
  instance_type = "${var.instance_size}"
  source_dest_check = true
  count = "1"
  subnet_id = "${var.subnet}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2_strapi_profile.name}"
  vpc_security_group_ids = [
    "${var.env == "production" ? aws_security_group.sg_strapi_prod.id : aws_security_group.sg_strapi.id}"
  ]
  key_name = "${var.key_pair_name}"
  depends_on = ["aws_security_group.sg_strapi"]
  
  tags = {
    Name = "${var.env}_${var.vpc_name}_strapi_${count.index}"
    Company = "SfC"
    Application = "InternalAdmin"
    Role = "strapi"
  }

  connection {
    user = "ec2-user"
    private_key = "${var.private_key_location}"
  }
}
