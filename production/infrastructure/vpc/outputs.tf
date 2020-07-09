output "redis-subnet" {
  value = aws_subnet.Redis.id
}

output "rds-subnet" {
  value = aws_subnet.rds.id
}