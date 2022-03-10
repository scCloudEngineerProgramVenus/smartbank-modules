output "alb_id" {
  description = "Venus ALB Id"
  value       = aws_lb.Venus.id
}

output "FE_target_group_arn" {
  description = "FE target group"
  value       = aws_lb_target_group.alb_tg_FE.arn
}

output "BE_target_group_arn" {
  description = "BE target group"
  value       = aws_lb_target_group.alb_tg_BE.arn
}

output "alb_sg_id" {
  description = "Venus SG Id"
  value       = module.alb_sg.alb_sg_id
}

output "alb_dns" {
  description = "ALB DNS"
  value       = aws_lb.Venus.dns_name
}
