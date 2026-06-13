terraform {
  required_version = "~1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}


# --- création utilisateur ---

resource "aws_iam_user" "dev" {
  name = "dev1"
  # permissions_boundary = peut être utiliser pour set les permission ? à investiguer
  force_destroy = true
  tags = {
    tag-key = "dev"
  }
}
###################
resource "aws_iam_user" "java-dev" {
  name          = "dev-java"
  force_destroy = true

  tags = {
    tag-key = "java"
  }
}

resource "aws_iam_access_key" "dev" {
  user = aws_iam_user.dev.name
  #pgp_key se renseigner peut être utilisé pour certification security ? 
}

output "secret" {
  value = aws_iam_access_key.dev.encrypted_secret
}

# --- policies --- 2 méthodes d'attributions pour l'apprentissage

resource "aws_iam_user_policy_attachment" "attach_dev1" {
  user       = aws_iam_user.dev.name
  policy_arn = aws_iam_policy.S3-ro-global.arn
}

###################
data "aws_iam_policy_document" "S3_ro_json" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "s3:Get*",
    "s3:List*"]

    resources = [
      "arn:aws:s3:::*",
      "arn:aws:s3:::*/*",
    ]
  }
}

resource "aws_iam_policy" "S3-ro-global" {
  name        = "read-only-s3"
  description = "Restrict one user to read only and list s3 bucket"
  policy      = data.aws_iam_policy_document.S3_ro_json.json
}

###################
resource "aws_iam_policy" "s3_read_special_bucket" {
  name        = "read-s3-spec"
  description = "Allow one user to read only this one bucket"
  policy      = data.aws_iam_policy_document.s3_specific.json
}

data "aws_iam_policy_document" "s3_specific" {
  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]

    resources = [
      "arn:s3:::/test/this-bucket"
    ]
  }
}

# --- Groupes ---

resource "aws_iam_group" "developers-java" {
  name = "developers"
}

resource "aws_iam_user_group_membership" "dev_java" {
  user = aws_iam_user.java-dev.name

  groups = [
    aws_iam_group.developers-java.name
  ]
}

resource "aws_iam_group_policy_attachment" "developer_javas3_ro" {
  group      = aws_iam_group.developers-java.name
  policy_arn = aws_iam_policy.S3-ro-global.arn
}

###################
resource "aws_iam_group" "test" {
  name = "test-group"
}

resource "aws_iam_user_group_membership" "test_member" {
  user = aws_iam_user.dev.name

  groups = [
    aws_iam_group.test.name
  ]
}

resource "aws_iam_group_policy_attachment" "test_spec_s3" {
  group      = aws_iam_group.test.name
  policy_arn = aws_iam_policy.s3_read_special_bucket.arn
}

# --- Rôle et service policy application ---

resource "aws_iam_role" "list_role" {
  name        = "ec2-list-role"
  description = "allow one service to list ec2 instances"

  assume_role_policy = data.aws_iam_policy_document.assume-list-role.json
}


data "aws_iam_policy_document" "assume-list-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "list-ec2" {
  statement {
    sid       = "5"
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "list_ec2_policy" {
  name        = "policy-test"
  description = "Allow one to describe ec2"
  policy      = data.aws_iam_policy_document.list-ec2.json
}

resource "aws_iam_role_policy_attachment" "attach_list_role" {
  role       = aws_iam_role.list_role.name
  policy_arn = aws_iam_policy.list_ec2_policy.arn
}
