variable "image_id" {
  description = "select image-id for launch template"
  type        = string
  default     = "test-amo"
}

variable "vol_type" {
  description = "chooso vol type for ebs launch templta"
  type        = string
  default     = "gp2"
}

variable "cidr_block_vpc_one" {
  description = "select cidr block for main vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "region_vpc_first" {
  description = "desired region for vpc"
  type        = string
  nullable    = false
}

variable "az_subnet_one" {
  type = string
}

variable "az_subnet_two" {
  type = string
}

