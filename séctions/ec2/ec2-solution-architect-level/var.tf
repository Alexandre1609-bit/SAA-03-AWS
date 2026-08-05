variable "ami" {
  description = "choos ami"
  type        = string
  default     = "ami-0521cb2d60cfbb1a6"
}

variable "instance_type" {
  description = "choost instance type"
  type        = string
}

variable "az" {
  description = "choose availability zone"
  type        = string
}

variable "core_count" {
  description = "choose core count for eC2 instance"
  type        = number
}

variable "threads_per_core" {
  description = "choose threads per core for ec2 instance"
  type        = number
}

variable "volume_size" {
  description = "choose volume size for hibernation"
  type        = number
}

variable "volume_type" {
  description = "choose volume type for hibernation"
  type        = string
}


variable "ipv6_ipam_pool_id" {
  description = "choose iapm_pool_id_v6"
  type        = string
}

variable "secondary_cidr" {
  description = "chosse secondary cidr block"
  type        = string
}
