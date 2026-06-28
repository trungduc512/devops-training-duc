# Mini Lab 2: AWS VPC & EC2 with Terraform

Dự án này sử dụng Terraform để tự động hóa việc khởi tạo 1 VPC, 2 Public Subnets, Security Group và 1 EC2 instance chạy Nginx trên AWS.

## 🚀 Hướng dẫn sử dụng

**Bước 1: Cấu hình biến**
Tạo file `terraform.tfvars` (nếu chưa có) và cập nhật IP của bạn:
```hcl
aws_region = "ap-southeast-1"
my_ip      = "YOUR_IP_ADDRESS_HERE/32" 
```
*(Tìm IP của bạn tại: [ifconfig.me](https://ifconfig.me))*

**Bước 2: Khởi tạo và kiểm tra**
```bash
terraform init
terraform plan
```

**Bước 3: Triển khai**
```bash
terraform apply -auto-approve
```
Sau khi chạy xong, Terraform sẽ in ra \`website_url\`. Chờ khoảng 1-2 phút cho Nginx khởi động, sau đó truy cập URL đó để thấy dòng chữ "hello from...".

**Bước 4: Dọn dẹp (Tránh mất tiền)**
```bash
terraform destroy -auto-approve
```

## ⚠️ Lưu ý bảo mật
Hãy đảm bảo bạn đã tạo file `.gitignore` và thêm dòng sau vào để tránh commit lộ IP:
```text
*.tfvars
.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
```