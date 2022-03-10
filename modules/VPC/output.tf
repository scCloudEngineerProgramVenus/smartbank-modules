output "id" {
    value = aws_vpc.main.id
}

output "public_subnets_id" {
    value = module.public_subnets
}

output "private_subnets_id" {
    value = module.private_subnets
}

output "db_subnets_id" {
    value = module.db_subnets
}