### Config ###

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

### Launch Template

resource "aws_launch_template" "test-template" {
  name          = "my-test-template"
  description   = "my first launch templte"
  ebs_optimized = true

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
      volume_type = var.vol_type
    }
  }
  cpu_options {
    core_count       = 4
    threads_per_core = 2
  }

  image_id = var.image_id

  monitoring {
    enabled = true
  }

  hibernation_options {
    configured = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.real_inst_prof.name
  }

  security_group_names = [aws_security_group.allow_tls.name]

}

### IAM ROLE ###

data "aws_iam_policy_document" "instance-profile-doc" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main-role" {
  name               = "ec2-app-role"
  assume_role_policy = data.aws_iam_policy_document.instance-profile-doc.json
}

resource "aws_iam_role_policy_attachment" "name" {
  role       = aws_iam_role.main-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "real_inst_prof" {
  name = "ec2-app-prof"
  role = aws_iam_role.main-role.name
}


### VPC ###

resource "aws_vpc" "main_vpc" {
  cidr_block = var.cidr_block_vpc_one
}

### Network ###

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_int_gw.id
  }
}

resource "aws_internet_gateway" "main_int_gw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_subnet" "subnet_one" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az_subnet_one
}

resource "aws_subnet" "subnet_two" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az_subnet_two
}

resource "aws_route_table_association" "assoc_first" {
  subnet_id      = aws_subnet.subnet_one.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "assoc_snd" {
  subnet_id      = aws_subnet.subnet_two.id
  route_table_id = aws_route_table.main_route_table.id
}

### SECURITY GROUP ###

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.cidr_block_vpc_one
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # All ports
}
