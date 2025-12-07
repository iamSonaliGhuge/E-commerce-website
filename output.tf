output "ec2_public_ip" {
  value = aws_instance.spring_app.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.spring_db.endpoint
}
