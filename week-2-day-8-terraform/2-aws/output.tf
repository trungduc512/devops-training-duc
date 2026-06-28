output "instance_id" {
  description = "ID của EC2 instance vừa được tạo"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Địa chỉ Elastic IP tĩnh của EC2"
  value       = aws_eip.web_eip.public_ip
}

output "website_url" {
  description = "Link truy cập web Nginx"
  value       = "http://${aws_eip.web_eip.public_ip}"
}

output "ssh_command" {
  description = "Lệnh mẫu để kết nối SSH"
  value       = "ssh ec2-user@${aws_eip.web_eip.public_ip}"
}

# output "s3_bucket_name" {
#   description = "Tên bucket S3 để lưu trữ trạng thái Terraform"
#   value       = var.s3_backend_bucket
# }

# output "dynamodb_table_name" {
#   description = "Tên bảng DynamoDB để khóa trạng thái Terraform"
#   value       = var.dynamodb_table
# }