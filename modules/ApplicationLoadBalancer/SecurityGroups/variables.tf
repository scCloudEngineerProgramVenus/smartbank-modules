variable "sg_name" {
  description = "Define Security Group Name"
  default     = "Venus "
}

variable "vpc_id" {
  type = string
}

variable "description" {
  type    = string
  default = "Venus Security Group"
}
