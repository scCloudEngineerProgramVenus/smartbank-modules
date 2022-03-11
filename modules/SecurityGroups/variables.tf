variable "sg_name" {
  description = "Define Security Group Name"
}

variable "vpc_id" {
  type = string
}

variable "description" {
  type    = string
  default = "Venus Security Group"
}

variable "from_port" {
}

variable "to_port" {
}

variable "from_sg_id" {
}
