output "id" {
  description = "Venus Launch Template Id"
  value       = aws_launch_template.Venus_launch_template.id
}
/*
output "db_dns" {
  description = "DB DNS"
  value       = aws_db_instance.new.endpoint
}
*/