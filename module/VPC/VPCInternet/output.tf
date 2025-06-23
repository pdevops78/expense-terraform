output  "vpc"{
    value = aws_vpc.vpc.id
}

# output "frontend"{
#     value = aws_subnet_frontend_subnets.*.id
# }
#
# output "backend"{
#     value = aws_subnet_backend_subnets.*.id
# }

output "db"{
    value = aws_subnet_db_subnets.*.id
}

output "public"{
    value = aws_subnet_public_subnets.*.id
}