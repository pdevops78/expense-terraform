output "vpc"{
value  = aws_vpc.vpc.id
}
output "frontendServers"{
value = aws_subnet.frontend_subnets.*.id
}
output "backendServers"{
value = aws_subnet.backend_subnets.*.id
}
output "dbServers"{
value = aws_subnet.db_subnets.*.id
}