resource "aws_launch_template" "Venus_launch_template" {
  name          = var.name
  description   = var.description
  instance_type = var.instance_type
  image_id      = var.image_id
  #key_name      = var.key_name
  /*
  user_data     = base64encode(templatefile("${path.module}./userData/${var.user_data_file_name}", {
    ALB_address = var.alb_dns
    },
    {
      DB_address = var.db_dns
    }
    ))
*/

  user_data = base64encode(templatefile("${path.module}./userData/${var.user_data_file_name}", {
    address = var.endpoint
    }
  ))

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = ["${var.sg_id}"]
  }

  ebs_optimized = false

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.tag
    }
  }
}
