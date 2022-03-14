variable "name" {}

variable "description" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "image_id" {
  default = "ami-033b95fb8079dc481"
}

variable "endpoint" {}

variable "sg_id" {}

variable "user_data_file_name" {}

variable "iam_role" {}

/*
variable "key_name" {
  default = "Venus"
}
*/
variable "tag" {}
