# Notes CI/CD Basics

## 1. Phân biệt CI / CD / Continuous Deployment

**CI (Continuous Integration - Tích hợp liên tục)**: Quá trình tự động hóa việc gom code của các developer về branch chính (main/master). Mỗi khi code push lên, hệ thống tự động chạy Lint, Test (Unit/Integration) và Build thử để phát hiện lỗi sớm nhất có thể.

**CD (Continuous Delivery - Giao hàng liên tục)**: Tiếp nối sau CI. Code sau khi pass tất cả các test sẽ tự động tạo artifact (Docker image, file zip...) và deploy lên môi trường staging/pre-production. Tuy nhiên, việc deploy lên môi trường Production cần có sự phê duyệt thủ công (Manual Approval) (bấm nút bấm).

**Continuous Deployment (Triển khai liên tục)**: Cấp độ tự động hóa cao nhất. Không có sự can thiệp của con người. Mọi commit pass pipeline CI/CD sẽ tự động push thẳng lên Production một cách tự động.

## 2. DORA 4 key metrics là gì? Ý nghĩa từng metric

DORA (DevOps Research and Assessment) đưa ra 4 chỉ số vàng để đo lường hiệu suất của một đội ngũ kỹ thuật:

- **Deployment Frequency (Tần suất triển khai)**: Đội ngũ deploy code lên production định kỳ bao lâu một lần (hằng ngày, hằng tuần...). Ý nghĩa: Đo lường tính linh hoạt và tốc độ phản hồi tính năng.
- **Lead Time for Changes (Thời gian thực hiện thay đổi)**: Thời gian từ khi commit code được push lên đến khi nó chạy trên production. Ý nghĩa: Đo lường tốc độ của pipeline và quy trình kiểm thử.
- **Change Failure Rate (Tỷ lệ thay đổi thất bại)**: Tỷ lệ phần trăm các lần deploy lên production gây ra lỗi (phải rollback, hotfix). Ý nghĩa: Đo lường chất lượng và độ ổn định của hệ thống.
- **Time to Restore Service (Thời gian phục hồi dịch vụ)**: Khi production gặp sự cố (incident), mất bao lâu để hệ thống hoạt động bình thường trở lại. Ý nghĩa: Đo lường năng lực xử lý sự cố và tính sẵn sàng.

## 3. Ưu điểm của Pipeline as Code so với cấu hình UI

- **Version Control**: Cấu hình pipeline (YAML) nằm ngay trong repo. Mọi thay đổi cấu hình đều được lưu log, có thể track qua git commit, review qua Pull Request và dễ dàng rollback.
- **Tính tái sử dụng (Reusability)**: Dễ dàng copy/paste hoặc tạo template áp dụng cho hàng chục project khác nhau mà không cần click tay trên giao diện web.
- **Độc lập với nền tảng**: Định dạng code (như YAML) giúp cấu hình tường minh, dễ hiểu cho toàn bộ team thay vì phụ thuộc vào việc mò mẫm giao diện UI của từng tool.

## 4. Khi nào dùng `runs-on: self-hosted` vs `ubuntu-latest`

**`ubuntu-latest` (Cloud-hosted do GitHub quản lý)**

- **Khi nào dùng**: Dự án vừa và nhỏ, không yêu cầu cấu hình phần cứng đặc biệt, không có dữ liệu quá nhạy cảm.
- **Ưu điểm**: Tiện lợi, không tốn công bảo trì hạ tầng, luôn sạch sẽ (fresh environment) sau mỗi job.

**`runs-on: self-hosted` (Runner tự cài trên hạ tầng của mình)**

- **Khi nào dùng**: Cần truy cập vào mạng nội bộ (Internal VPC), cần phần cứng mạnh (nhiều CPU/RAM/GPU), cần cache dung lượng lớn để build nhanh hơn, hoặc do quy định bảo mật nghiêm ngặt không được đẩy source code ra ngoài.
- **Ưu điểm**: Tiết kiệm chi phí nếu build liên tục với tần suất cực cao, toàn quyền kiểm soát môi trường build.