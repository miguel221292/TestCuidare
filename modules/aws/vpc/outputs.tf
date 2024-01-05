output "security_group_id" {
    value = aws_security_group.ecs_security_group.id
}

output "vpc_id" {
  value= module.vpc.vpc_id
}

output "public_subnets" {
    value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_subnet_ec2" {
    value = module.vpc.private_subnets[0]
}
