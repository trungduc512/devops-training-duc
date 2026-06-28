variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
}

variable "my_ip" {
  description = "Your personal IP address to allow SSH access (e.g., 203.113.15.1/32)"
  type        = string
}


# variable "s3_backend_bucket" {
#   description = "Name of the S3 bucket for Terraform state storage"
#   type        = string
# }

# variable "dynamodb_table" {
#   description = "Name of the DynamoDB table for Terraform state locking"
#   type        = string
# }