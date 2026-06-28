# Kiến thức Core Terraform & Quản lý State

## 1. State file là gì? Vì sao không được commit lên Git?
* **State file (`terraform.tfstate`)** là file lưu trữ toàn bộ trạng thái hiện tại của cơ sở hạ tầng do Terraform quản lý. Nó đóng vai trò là "Single Source of Truth" để Terraform ánh xạ các cấu hình trong code (`.tf`) với các tài nguyên thực tế trên Cloud.
* **Vì sao KHÔNG ĐƯỢC commit lên Git?**
    * **Lộ thông tin bảo mật (Security Risks):** State file lưu trữ mọi thông tin dưới dạng *plain text*, bao gồm cả các dữ liệu nhạy cảm như mật khẩu database, bí mật khởi tạo, private key, hoặc token access.
    * **Xung đột trạng thái (Race Conditions & Conflict):** Nếu nhiều người cùng commit state file lên Git, việc merge code rất dễ gây hoen ố (corrupt) file state, dẫn đến hạ tầng bị sai lệch hoặc mất kiểm soát.

---

## 2. So sánh: terraform plan vs terraform apply vs terraform refresh

| Lệnh | Mục đích chính | Tác động lên Hạ tầng | Tác động lên State File |
| :--- | :--- | :--- | :--- |
| **`terraform refresh`** | Đồng bộ hóa state file với thực tế. | Không thay đổi gì trên Cloud. | Cập nhật lại state file nếu có thay đổi thủ công trên Cloud. *(Lưu ý: Từ bản v0.15+, lệnh này được chạy tự động ngầm trong plan/apply)*. |
| **`terraform plan`** | Xem trước các thay đổi sẽ diễn ra (Dry-run). | Không thay đổi gì trên Cloud. | Đọc state file hiện tại để so sánh, không ghi đè dữ liệu mới. |
| **`terraform apply`** | Thực thi cấu hình để tạo/sửa/xóa tài nguyên. | Thay đổi trực tiếp hạ tầng trên Cloud. | Ghi đè và cập nhật trạng thái mới nhất vào state file sau khi triển khai thành công. |

---

## 3. Tại sao nên dùng Remote Backend (S3 + DynamoDB State Locking)?
Khi làm việc nhóm (Teamwork), việc lưu state file ở Local là bất khả thi. Kết hợp **AWS S3** và **DynamoDB** là giải pháp chuẩn Standard nhờ các lý do:

* **S3 (Centralized Storage):** Lưu trữ state file tập trung ở một nơi an toàn, hỗ trợ *Versioning* (khôi phục lại phiên bản cũ nếu state bị lỗi) và mã hóa (Encryption).
* **DynamoDB (State Locking):** Khi một thành viên đang chạy `terraform apply`, Terraform sẽ tạo một "lock ID" trên DynamoDB để khóa file state lại. Người khác sẽ không thể can thiệp hay chạy apply song song cho đến khi tiến trình đầu tiên hoàn tất. Điều này tránh tuyệt đối tình trạng ghi đè hoặc làm hỏng state.

---

## 4. So sánh: Module Local vs Module Registry

### Local Module
* **Định nghĩa:** Là các module do bạn tự viết và lưu ngay trong cùng một source code (ví dụ: `source = "./modules/vpc"`).
* **Ưu điểm:** Chỉnh sửa nhanh, test trực tiếp tiện lợi, phù hợp cho cấu hình đặc thù của dự án nội bộ.
* **Nhược điểm:** Khó tái sử dụng qua nhiều repository (dự án) khác nhau.

### Registry Module
* **Định nghĩa:** Là các module được publish lên một trung tâm lưu trữ (Terraform Registry công khai hoặc Private Registry của doanh nghiệp).
* **Ưu điểm:** Hỗ trợ quản lý theo **version** rõ ràng (ví dụ: `version = "5.0.0"`), dễ dàng chia sẻ cho nhiều team/dự án, code chuẩn hóa cao.
* **Nhược điểm:** Mỗi lần module gốc cập nhật, bạn phải chạy `terraform init -upgrade` để lấy bản mới, tốn thời gian đóng gói và release hơn.

---

## 5. count vs for_each — Khi nào dùng cái nào?



### `count`
* **Cơ chế:** Dựa trên một số nguyên (index từ `0, 1, 2...`).
* **Khi nào dùng:** Dùng khi muốn tạo hàng loạt các tài nguyên **hoàn toàn giống hệt nhau** (Ví dụ: Tạo 3 EC2 instance dự phòng).
* **Điểm yếu:** Nếu bạn xóa một phần tử ở giữa danh sách, Terraform sẽ bị dịch chuyển index của các phần tử phía sau, dẫn đến việc xóa và tạo lại (re-create) các tài nguyên không mong muốn.

### `for_each`
* **Cơ chế:** Dựa trên một danh sách dạng Map hoặc Set (Key-Value hoặc chuỗi định danh).
* **Khi nào dùng:** Dùng khi các tài nguyên có sự **khác biệt về thuộc tính** (Ví dụ: Tạo 3 subnet với các CIDR block và tên khác nhau).
* **Ưu điểm:** An toàn hơn `count`. Nếu bạn xóa 1 phần tử trong map, Terraform chỉ xóa đúng tài nguyên đó, không ảnh hưởng đến các tài nguyên còn lại.

---

## 6. Drift là gì? Cách phát hiện & xử lý?

### Drift là gì?
**Drift (Hạ tầng bị lệch lạc)** là hiện tượng xảy ra khi trạng thái thực tế của hạ tầng trên Cloud không còn khớp với những gì được khai báo trong code Terraform và State file nữa. Nguyên nhân phổ biến nhất là do có ai đó đã lên giao diện Web (AWS Console) sửa đổi thủ công, hoặc đổi bằng CLI bên ngoài.

### Cách phát hiện
Chạy lệnh:
```bash
terraform plan
```


Terraform sẽ tự động so sánh code -> state file -> tài nguyên thực tế. Nếu phát hiện có sự sai lệch (Drift), nó sẽ liệt kê chi tiết những thuộc tính nào đang bị thay đổi.

Cách xử lý
Có 2 hướng giải quyết tùy vào mục đích:

Nếu muốn giữ lại thay đổi thủ công: Cập nhật lại code .tf cho đúng với thực tế ngoài Cloud, sau đó chạy terraform apply để đồng bộ lại State.

Nếu muốn hủy bỏ thay đổi thủ công (Đưa về chuẩn cũ): Giữ nguyên code, chạy trực tiếp terraform apply. Terraform sẽ tự động ghi đè hoặc cấu hình lại tài nguyên trên Cloud về đúng trạng thái được khai báo trong code ban đầu.