output "FE_asg_id" {
  description = "Front End Auto Scaling Group Id"
  value = aws_autoscaling_group.FE_asg.id
}