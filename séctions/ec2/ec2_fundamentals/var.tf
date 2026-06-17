variable "instance_type" {
  description = "select instance type for ec2 instance"
  type        = string
}

variable "instance_name" {
  description = "choose ec2 instance name"
  type        = string
}

variable "ec2_az" {
  description = "choose ec2 AZ"
  type        = string
}
