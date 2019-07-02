data "aws_ami" "keystone_ami" {
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

resource "aws_security_group" "sg_keystonejs" {
    name = "sg_${var.env}_${var.vpc_name}_keystonejs"
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
        from_port = 3000
        to_port = 3000
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
        Name = "sg_${var.env}_${var.vpc_name}_keystonejs"
        Company = "SfC"
        Application = "InternalAdmin"
        Role = "keystonejs"
    }
}

resource "aws_instance" "keystonejs" {
  ami           = "${data.aws_ami.keystone_ami.id}"
  instance_type = "t2.micro"
  source_dest_check = true
  count = "1"
  subnet_id = "${var.subnet}"
  iam_instance_profile = "${var.aws_ec2_basic_profile.name}"
  vpc_security_group_ids = [
    "${aws_security_group.sg_keystonejs.id}"
  ]
  key_name = "${var.key_pair_name}"
  depends_on = ["aws_security_group.sg_keystonejs"]
  
  tags = {
    Name = "${var.env}_${var.vpc_name}_keystonejs_${count.index}"
    Company = "SfC"
    Application = "InternalAdmin"
    Role = "keystonejs"
  }

  connection {
    user = "ec2-user"
    private_key = "${var.private_key_location}"
  }
}
