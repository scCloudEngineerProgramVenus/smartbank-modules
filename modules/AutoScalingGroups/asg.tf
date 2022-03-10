module "FE_instance_sg" {
  source      = "./SecurityGroups"
  description = "Venus FE Instance Security Group"
  sg_name     = "Venus FE instance test"
  vpc_id      = var.vpc_id
  from_port   = 80
  to_port     = 80
  alb_sg_id   = var.alb_sg_id
}

module "BE_instance_sg" {
  source      = "./SecurityGroups"
  description = "Venus BE Instance Security Group"
  sg_name     = "Venus BE instance test"
  vpc_id      = var.vpc_id
  from_port   = 8080
  to_port     = 8080
  alb_sg_id   = var.alb_sg_id
}

module "launch_template_FE" {
  source              = "./LaunchTemplate"
  name                = "Venus-FE-template-test"
  description         = "Venus FE template"
  user_data_file_name = "FEuserData.sh"
  sg_id               = module.FE_instance_sg.id
  tag                 = "Venus FE"
  alb_dns             = var.alb_dns
  image_id            = "ami-041d49677629acc40"
  db_dns              = var.db_dns
  //  key_name            = "bobby-tokyo"
}

module "launch_template_BE" {
  source              = "./LaunchTemplate"
  name                = "Venus-BE-template-test"
  description         = "Venus BE template"
  user_data_file_name = "BEuserData.sh"
  sg_id               = module.BE_instance_sg.id
  tag                 = "Venus BE"
  alb_dns             = var.alb_dns
  image_id            = "ami-041d49677629acc40"
  db_dns              = var.db_dns
  //  key_name            = "bobby-tokyo"
}

resource "aws_autoscaling_group" "FE_asg" {
  name = "Venus-FE-ASG-test"
  launch_template {
    id = module.launch_template_FE.id
  }
  vpc_zone_identifier = var.subnets
  target_group_arns = [
    "${var.FE_target_group_arn}"
  ]
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "EC2"
  health_check_grace_period = 300
  tag {
    key                 = "Name"
    value               = "Venus FE-test"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "FE_Venus_scaling_policy" {
  autoscaling_group_name = aws_autoscaling_group.FE_asg.name
  name                   = "Venus-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

resource "aws_autoscaling_group" "BE_asg" {
  name = "Venus-BE-ASG-test"
  launch_template {
    id = module.launch_template_BE.id
  }
  vpc_zone_identifier = var.subnets
  target_group_arns = [
    "${var.BE_target_group_arn}"
  ]
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "EC2"
  health_check_grace_period = 300
  tag {
    key                 = "Name"
    value               = "Venus BE-test"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "BE_Venus_scaling_policy" {
  autoscaling_group_name = aws_autoscaling_group.BE_asg.name
  name                   = "Venus-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}
