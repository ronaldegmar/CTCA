output "Sg_Private_Web_Servers" {
  value = aws_security_group.Private_Web_Servers.id
}

output "Sg_ElasticCacheRedis" {
  value = aws_security_group.ElasticCacheRedis.id
}

output "Sg_RDS_Servers" {
  value = aws_security_group.RDS_Servers.id
}

output "Sg_ELB" {
  value = aws_security_group.aws_elb.id
}

output "Sg_ALB1" {
  value = aws_security_group.aws_alb1.id
}

output "Sg_ALB2" {
  value = aws_security_group.aws_alb2.id
}