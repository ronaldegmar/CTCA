output "prod-priv-1a-ip" {
  value = aws_instance.prod-priv-1a.*.private_ip
}

output "prod-priv-1b-ip" {
  value = aws_instance.prod-priv-1b.private_ip
}

output "prod-priv-1c-ip" {
  value = aws_instance.prod-priv-1c.private_ip
}