# Main instance 

resource "aws_instance" "main" {
  instance_type        = var.ami
  ami                  = var.ami
  availability_zone    = var.az
  placement_group_id   = aws_placement_group.cluster.id
  hibernation          = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  # security_groups = utile de le repasser ici alors qu'il est déjà associer à mes ENI 
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOF


  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    encrypted   = true
  }

  cpu_options {
    core_count       = var.core_count
    threads_per_core = var.threads_per_core
  }


  tags = {
    Name = "HelloWorld"
  }
}


# vpc

resource "aws_vpc" "my_vpc" {
  cidr_block        = "172.16.0.0/16"
  ipv6_cidr_block   = "::/44"
  ipv6_ipam_pool_id = var.ipv6_ipam_pool_id
}

# Network

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = var.az
}

resource "aws_subnet" "secondary_sub" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.secondary_cidr
}

resource "aws_network_interface" "main_eni" {
  subnet_id               = aws_subnet.my_subnet.id
  private_ip_list_enabled = true
  private_ip_list         = ["172.16.10.100", "172.16.10.200"]
  security_groups         = [aws_security_group.allow_rnd.id]
  attachment {
    instance     = aws_instance.main.id
    device_index = 1
  }
}

resource "aws_network_interface" "second_eni" {
  subnet_id               = aws_subnet.my_subnet.id
  private_ip_list_enabled = true
  private_ip_list         = ["172.16.10.300", "172.16.10.400"]
  security_groups         = [aws_security_group.allow_ssh_only_sg.id]
  attachment {
    instance     = aws_instance.main.id
    device_index = 1
  }
}

# elastic ip

resource "aws_eip" "elastic_ip_one" {
  region                    = var.az
  network_interface         = aws_network_interface.main_eni.id #Obligé de lier un EIP à un ENI ?
  associate_with_private_ip = "172.16.10.100"
}

# security groups

resource "aws_security_group" "allow_rnd" {
  name        = "allow_rnd"
  description = "Allow rnd ports inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id
  tags = {
    Name = "allow_rnd"
  }
}


# allow FTP control & data
resource "aws_vpc_security_group_ingress_rule" "allow_ftp_control_ipv4" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  from_port         = 21
  ip_protocol       = "tcp"
  to_port           = 21
}

resource "aws_vpc_security_group_ingress_rule" "allow__ftp_control_ipv6" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv6         = aws_vpc.my_vpc.ipv6_cidr_block
  from_port         = 21
  ip_protocol       = "tcp"
  to_port           = 21
}

resource "aws_vpc_security_group_ingress_rule" "allow_ftp_data_ipv4" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  from_port         = 20
  ip_protocol       = "tcp"
  to_port           = 20
}

resource "aws_vpc_security_group_ingress_rule" "allow_ftp_data_ipv6" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv6         = aws_vpc.my_vpc.ipv6_cidr_block
  from_port         = 20
  ip_protocol       = "tcp"
  to_port           = 20
}

# allow http & https

resource "aws_vpc_security_group_ingress_rule" "allow_http_data_ipv4" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_data_ipv6" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv6         = aws_vpc.my_vpc.ipv6_cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_data_ipv4" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_data_ipv6" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv6         = aws_vpc.my_vpc.ipv6_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# allow SSH 

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_data_ipv4" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_data_ipv6" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv6         = aws_vpc.my_vpc.ipv6_cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# General Traffic (v4, v6)
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}


resource "aws_placement_group" "cluster" {
  name     = "cluster-pg"
  strategy = "cluster"
}

# 2nd security group allow SSh only


resource "aws_security_group" "allow_ssh_only_sg" {
  name        = "allow_rnd"
  description = "Allow rnd ports inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "allow_ss_only"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_snd_data_ipv4" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_snd_data_ipv6" {
  security_group_id = aws_security_group.allow_rnd.id
  cidr_ipv6         = aws_vpc.my_vpc.ipv6_cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

## IAM role

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    sid     = "1"
    effect  = "Allow"
    actions = ["sts:assumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "test-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_instance_profile" "ec2_profile" { # à quoi sert les instances profile ? Revoir 
  name = "ec2-instance-profil"
  role = aws_iam_role.ec2_role.name
}


data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = ["s3:Describe*",
      "s3:List*",
    "s3:Get*"]
    resources = [
      "arn:aws:s3:::*",
      "arn:aws:s3:::*/*"
    ]
  }
}

resource "aws_iam_policy" "s3-RO" {
  name        = "read_only_s3"
  description = "Allow RO write on s3 bucket"
  policy      = data.aws_iam_policy_document.assume_role_policy.json
}


resource "aws_iam_role_policy_attachment" "attach_role" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3-RO.arn
}
