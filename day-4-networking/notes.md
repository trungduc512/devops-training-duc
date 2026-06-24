

# Networking Primer Notes

## 1. So sánh OSI 7 lớp vs TCP/IP 4 lớp

| Đặc điểm | Mô hình OSI (7 lớp) | Mô hình TCP/IP (4 lớp) |
| --- | --- | --- |
| **Tính chất** | Mang tính lý thuyết, chuẩn hóa thiết kế mạng. | Mang tính thực tế, là nền tảng của Internet hiện tại. |
| **Các lớp** | 7. Application<br>6. Presentation<br>5. Session<br>4. Transport<br>3. Network<br>2. Data Link<br>1. Physical | 4. Application (gộp 5, 6, 7 của OSI)<br>3. Transport (tương đương lớp 4 OSI)<br>2. Internet (tương đương lớp 3 OSI)<br>1. Network Access (gộp 1, 2 của OSI) |

---

## 2. TCP 3-Way Handshake & Flags

### ASCII Diagram

```text
Client                               Server
  |                                    |
  |------- SYN (seq=x) --------------->|  (1) Khởi tạo kết nối
  |                                    |
  |<------ SYN-ACK (seq=y, ack=x+1) ---|  (2) Xác nhận & Phản hồi
  |                                    |
  |------- ACK (ack=y+1) ------------->|  (3) Hoàn tất thiết lập
  |                                    |
```

### Giải thích các cờ TCP

- SYN (Synchronize): Dùng để khởi tạo kết nối và đồng bộ số thứ tự (sequence number) giữa client và server.
- ACK (Acknowledge): Dùng để xác nhận đã nhận dữ liệu hoặc xác nhận một cờ/segment trước đó.
- FIN (Finish): Dùng để đóng kết nối một cách bình thường, báo rằng bên gửi không còn dữ liệu nào nữa.
- RST (Reset): Dùng để hủy kết nối ngay lập tức khi có lỗi, kết nối không hợp lệ hoặc cổng không lắng nghe.

## 3. Khi nào chọn UDP thay vì TCP?

Chọn UDP khi ứng dụng ưu tiên tốc độ cao, độ trễ thấp và chấp nhận mất một lượng nhỏ dữ liệu (không cần bắt tay, không cần kiểm tra gói tin lỗi hay gửi lại).

Ví dụ thực tế:

- Livestream Video/Audio: Mất vài khung hình không sao, nhưng nếu trễ (delay) do chờ gửi lại dữ liệu sẽ gây giật lag.
- Gaming Online: Vị trí nhân vật cần cập nhật liên tục theo thời gian thực.
- DNS Query: Cần phản hồi IP cực nhanh, nếu lỗi chỉ cần gửi lại request mới.
- VoIP (Call Zoom, Discord): Ưu tiên tiếng nói mượt mà theo thời gian thực hơn là hoàn hảo từng byte dữ liệu.

## 4. Tra cứu số lượng IP theo CIDR Block

Công thức tổng quát: Tổng số IP = 2^(32 - N). Số IP khả dụng cho Host = Tổng số IP - 2 (trừ IP mạng và IP Broadcast).

- /24: Tổng 256 IP (khả dụng: 254 Host)
- /16: Tổng 65,536 IP (khả dụng: 65,534 Host)
- /22: Tổng 1,024 IP (khả dụng: 1,022 Host)

## 5. Tại sao lại có dải Private IP?

Dải Private IP (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) được sinh ra vì:

- Tiết kiệm địa chỉ IPv4: Giúp giải quyết cuộc khủng hoảng cạn kiệt IP public toàn cầu. Các mạng nội bộ khác nhau có thể trùng dải Private IP mà không xung đột.
- Bảo mật: Các IP này không thể định tuyến trực tiếp trên Internet công cộng, giúp ẩn thiết bị nội bộ khỏi các cuộc tấn công từ bên ngoài.

## 6. NAT là gì? Phân biệt SNAT và DNAT

NAT (Network Address Translation) là kỹ thuật thay đổi thông tin địa chỉ IP trong header của gói tin khi đi qua một thiết bị định tuyến (Router/Firewall), thường dùng để chuyển đổi giữa IP Private và IP Public.

### SNAT (Source NAT - Thay đổi IP Nguồn)

- Cơ chế: Thay đổi IP của máy gửi (Private) thành IP của Router (Public) trước khi ra Internet.
- Ứng dụng: Dùng khi các máy trong mạng nội bộ muốn đi ra mạng Internet bên ngoài.

### DNAT (Destination NAT - Thay đổi IP Đích)

- Cơ chế: Thay đổi IP đích của gói tin từ bên ngoài gửi vào (Public IP của Router) thành IP của một máy cụ thể trong mạng nội bộ (Private IP).
- Ứng dụng: Dùng để public một dịch vụ nội bộ (như Web Server, Database) ra Internet (thường gọi là Port Forwarding).

## 7. Phân biệt Forward Proxy và Reverse Proxy

### Forward Proxy (Đại diện cho Client)

- Nằm gần phía Client. Đứng ra thay mặt Client để gửi request lên Internet.
- Mục đích: Ẩn danh tính Client, vượt tường lửa (vào các web bị chặn), kiểm soát và bộ lọc nội dung truy cập của nhân viên trong công ty.

### Reverse Proxy (Đại diện cho Server)

- Nằm gần phía Server. Tiếp nhận tất cả request từ Internet gửi đến, sau đó phân phối cho các server thật (Backend) ở phía sau xử lý.
- Mục đích: Ẩn giấu cấu trúc mạng nội bộ, cân bằng tải (Load Balancing), mã hóa SSL (SSL Termination), và lưu bộ nhớ đệm (Caching) để giảm tải cho Server.