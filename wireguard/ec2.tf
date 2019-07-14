provider "aws" {}

resource "aws_default_vpc" "vpc" {}

resource "aws_security_group" "sg" {
  name        = "sg"
  description = "sg"
  vpc_id      = aws_default_vpc.vpc.id
}

data "http" "myip" {
  url = "http://ifconfig.me"
}

resource "aws_security_group_rule" "ingress_22" {
  type = "ingress"

  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${data.http.myip.body}/32"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "ingress_443" {
  type = "ingress"

  from_port = 443
  to_port   = 443
  protocol  = "udp"

  cidr_blocks       = ["0.0.0.0/32"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "sg_egress" {
  type = "egress"

  from_port = 0
  to_port   = 65535
  protocol  = "-1"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-disco*-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_key_pair" "deployer" {
  key_name   = "gkey"
  public_key = var.ssh_key
}

resource "aws_spot_instance_request" "wireguard" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.nano"
  wait_for_fulfillment = "true"
  spot_type            = "one-time"
  key_name             = "gkey"
  security_groups      = [aws_security_group.sg.name]

  # user_data = data.template_file.user_data.rendered
  user_data = templatefile(
    "${path.module}/init.sh",
    {
      server_private_key = data.local_file.server_private_key.content
      client_public_key  = data.local_file.client_public_key
      peers              = var.peers
    }
  )
  tags = {
    Name = "wireguard"
  }
}
