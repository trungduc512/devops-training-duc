# 1. Tạo S3 Bucket để lưu trữ file trạng thái (State File)
resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.s3_backend_bucket # Tên bucket phải là duy nhất trên toàn cầu
  force_destroy = false # Ngăn chặn vô tình xóa bucket chứa dữ liệu quan trọng
}

# 2. Kích hoạt Versioning cho S3 Bucket để có thể khôi phục lại các bản state cũ
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Kích hoạt mã hóa phía máy chủ (Server-Side Encryption) cho S3 Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Chặn quyền truy cập công khai (Public Access) để bảo mật tuyệt đối file state
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 5. Tạo bảng DynamoDB để quản lý khóa trạng thái (State Locking), tránh xung đột khi nhiều người cùng chạy áp dụng
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table # Tên bảng DynamoDB
  billing_mode = "PAY_PER_REQUEST"       # Chế độ tính phí theo mức sử dụng, tối ưu chi phí
  hash_key     = "LockID"                # Bắt buộc phải là "LockID" để Terraform hoạt động

  attribute {
    name = "LockID"
    type = "S" # Kiểu dữ liệu Chuỗi (String)
  }
}