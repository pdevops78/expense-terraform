output "vpc_id"{
value = aws_vpc.vpc.id
}
output "public"{
value = aws_subnet.public_subnets.*.id
}
output "frontend"{
value = aws_subnet.frontend_subnets.*.id
}
output "db"{
value = aws_subnet.db_subnets.*.id
}