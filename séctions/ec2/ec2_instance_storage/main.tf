# --- PROVIDERS ---
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

resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "sub_1" {
  vpc_id            = aws_vpc.vpc_1.id
  availability_zone = "eu-west-3"
  cidr_block        = "10.0.0.0/16"
}

resource "aws_subnet" "sub_2" {
  vpc_id            = aws_vpc.vpc_1.id
  availability_zone = "eu-west-2"
  cidr_block        = "10.0.0.0/16"
}

# --- INSTANCE SECTION ---

resource "aws_instance" "main_ec2" {
  instance_type = var.instance_type
  region        = "eu-west-3"
  ami           = "ami-00034b0b6e2e5a27e" #Ami AWS par défaut
  user_data     = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-efs-utils
              mkdir -p /efs
              echo " $imaginer une var ici pour le mount:/ /efs efs _netdev,tls 0 0" >> /etc/fstab
              mount -a -t efs defaults,_netdev
              EOF
}

resource "aws_instance" "second_ec2" {
  instance_type = var.instance_type
  region        = "eu-west-2"
  ami           = aws_ami_from_instance.test_ami_copy.id
  user_data     = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-efs-utils
              mkdir -p /efs
              echo "$imaginer une var ici pour le mount:/ /efs efs _netdev,tls 0 0" >> /etc/fstab
              mount -a -t efs defaults,_netdev
              EOF
}

# --- EBS SECTION ---

resource "aws_ebs_volume" "root_vol" {
  availability_zone = "eu-west-3"
  size              = 2
  encrypted         = true
  kms_key_id        = aws_kms_key.main_kms_key.id
  type              = "gp2"
  tags = {
    Name = "Main_ec2_ebs_root"
  }
}


resource "aws_ebs_volume" "data_vol" {
  availability_zone = "eu-west-3"
  size              = 2
  encrypted         = true
  kms_key_id        = aws_kms_key.main_kms_key.id
  type              = "io2  "
  tags = {
    Name = "Main_ec2_ebs_data"
  }
}

resource "aws_volume_attachment" "attach_ebs_root" {
  device_name = "/"
  volume_id   = aws_ebs_volume.root_vol.id
  instance_id = aws_instance.main_ec2.id

}

resource "aws_volume_attachment" "attach_ebs_data" {
  device_name = "/data"
  volume_id   = aws_ebs_volume.data_vol.id
  instance_id = aws_instance.main_ec2.id
}


resource "aws_kms_key" "main_kms_key" {
  description             = "An example symmetric encryption KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 20
}

# --- SNAPSHOT SECTION ---

resource "aws_ebs_snapshot" "data_snap" {
  volume_id = aws_ebs_volume.data_vol.id
}

# create new volumes from snapshot 

resource "aws_ebs_volume" "from_snap_ebs" { # Pas besoin d'encryption car le snapshot vient d'un EBS déjà encrypté
  availability_zone = "eu-west-1"
  snapshot_id       = aws_ebs_snapshot.data_snap.id
  size              = 20
  type              = "gp3"
}

resource "aws_volume_attachment" "attach_from_snap" {
  device_name = "/data"
  volume_id   = aws_ebs_volume.from_snap_ebs.id
  instance_id = aws_instance.second_ec2.id
}

# --- AMI SECTION ---

resource "aws_ami_from_instance" "test_ami_copy" {
  name               = "ami-copy-test"
  source_instance_id = aws_instance.main_ec2.id
  region             = "eu-west-2"
}

# --- EFS SECTION ---

resource "aws_efs_file_system" "my_first_efs" {
  creation_token = "main-efs"
  lifecycle_policy {
    transition_to_ia                    = "AFTER_30_DAYS"
    transition_to_archive               = "AFTER_90_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
}

resource "aws_efs_mount_target" "test_mount" {
  file_system_id  = aws_efs_file_system.my_first_efs.id
  subnet_id       = aws_subnet.sub_1.id
  security_groups = [aws_vpc.vpc_1.id]
}

resource "aws_efs_mount_target" "test_mount_2" {
  file_system_id  = aws_efs_file_system.my_first_efs.id
  subnet_id       = aws_subnet.sub_2.id
  security_groups = [aws_vpc.vpc_1.id]
}

# --- SECURITY GROUP SECTION ---

resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Allow EFS access"
  vpc_id      = aws_vpc.vpc_1.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
