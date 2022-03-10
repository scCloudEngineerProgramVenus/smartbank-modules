variable "name" {}

variable "description" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "image_id" {
  default = "ami-033b95fb8079dc481"
}

variable "alb_dns" {}

variable "db_dns" {}

variable "sg_id" {}

variable "user_data_file_name" {}

variable "key_name" {
  default = "Venus"
}

variable "tag" {}
