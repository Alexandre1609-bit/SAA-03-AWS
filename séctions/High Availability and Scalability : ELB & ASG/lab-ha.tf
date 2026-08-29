# LAB ONLY — not deployed.
# AZs and certificate ARN are placeholders.

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

  user_data = <<-EOS
        #!/bin/bash
        apt-get update
        apt-get install -y nginx
        systemctl start nginx
        systemctl enable nginx
        EOS

  iam_instance_profile {
    name = aws_iam_instance_profile.real_inst_prof.name
  }

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

}

### ALB ###

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "my-alb"
  vpc_id  = aws_vpc.main_vpc.id
  subnets = [aws_subnet.subnet_one.id, aws_subnet.subnet_two.id]

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.cidr_block_vpc_one
    }
  }

  #access_logs = {
  #  bucket = "my-alb-logs"
  #} Optionnel, se renseigner 

  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012" #Certificat à créer, se renseigner afin de le faire dans les prochains lab

      forward = {
        target_group_key = "inst_1"
      }
    }
  }

  target_groups = {
    inst_1 = {

      name_prefix       = "h1"
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance"
      create_attachment = false
      health_check = {
        enabled             = true
        healthy_threshold   = 5
        unhealthy_threshold = 7
        path                = "/"
        port                = 80
        matcher             = "200"
        protocol            = "HTTP"
        interval            = 20

      }
    }
  }



  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}

### ASG ###

resource "aws_autoscaling_group" "main_asg" {
  name                      = "my-first-asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ALB"
  desired_capacity          = 2
  force_delete              = true
  launch_template {
    id      = aws_launch_template.test-template.id
    version = "$Latest"
  }
  target_group_arns = [
    module.alb.target_groups["inst_1"].arn
  ]
  vpc_zone_identifier = [aws_subnet.subnet_one.id, aws_subnet.subnet_two.id]

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

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow HTTP from ALB"
  vpc_id      = aws_vpc.main_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_http" {
  security_group_id            = aws_security_group.ec2_sg.id
  referenced_security_group_id = module.alb.security_group_id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "TCP"
}
