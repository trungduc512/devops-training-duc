terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Sử dụng phiên bản 5.x mới nhất
    }
  }
}