# ### Generate Ec2 instance ###
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                 = var.instance_name
  create               = false
  ami                  = "ami-0884bba1ac5619645"
  availability_zone    = var.ec2_az
  instance_type        = var.instance_type
  key_name             = aws_key_pair.key-pair.key_name
  monitoring           = true
  subnet_id            = "subnet-eddcdzz4"
  security_group_name  = aws_security_group.allow_tls.name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data            = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOF


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# ### Generate ssh prerequisites ###
resource "tls_private_key" "nb-keypair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key" {
  content  = tls_private_key.nb-keypair.private_key_pem
  filename = "${path.root}/nb-key-pair.pem"
}

resource "aws_key_pair" "key-pair" {
  key_name   = "nb-key-pair"
  public_key = tls_private_key.nb-keypair.private_key_openssh
}


# ### Generate security group ###
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = "vpc-081626a6d37e70dc5"

  tags = {
    Name = "allow_tls"
  }
}

# --- HTTPS ---
resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# --- HTTP ---
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# --- SHH ---
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# --- TRAFFIC ---
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

# ### IAM ROLE ### 
data "aws_iam_policy_document" "assume_role" {
  statement {
    sid = "1"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "test-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profil"
  role = aws_iam_role.role.name
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = ["s3:Describe*",
      "s3:List*",
    "s3:Get*"]
    resources = [
      "arn:aws:s3:::my-first-bucket",
    ]
  }
}

resource "aws_iam_policy" "s3-RO" {
  name        = "read_only_s3"
  description = "Allow RO write on s3 bucket"
  policy      = data.aws_iam_policy_document.assume_role_policy.json
}


resource "aws_iam_role_policy_attachment" "attach_role" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.s3-RO.arn
}
