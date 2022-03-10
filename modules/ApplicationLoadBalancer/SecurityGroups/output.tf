
output "alb_sg_id" {
  description = "Venus Security Group Id"
  value       = aws_security_group.alb_sg.id
}
