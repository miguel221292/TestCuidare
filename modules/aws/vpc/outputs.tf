output "vpc_id" {
    value = aws_vpc.vpc_ecs.id
}

output "security_group_id" {
    value = aws_security_group.ecs_security_group.id
}



output "subnet_public_id_a" {
    value = element(aws_subnet.public_subnets[*].id, 0)
}

output "subnet_public_id_b" {
    value = element(aws_subnet.public_subnets[*].id, 1)
}

output "subnet_id_a" {
    value = element(aws_subnet.private_subnets[*].id, 0)
}
output "subnet_id_b" {
    value = element(aws_subnet.private_subnets[*].id, 1)
}