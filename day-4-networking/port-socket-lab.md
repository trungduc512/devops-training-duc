# Port & Socket Lab Notes

Tài liệu hướng dẫn phân biệt các câu lệnh kiểm tra Socket hệ thống (`ss`) và giải thích chi tiết các trạng thái kết nối TCP (Socket States).

---

## 1. Phân biệt các lệnh `ss` (Socket Statistics)

Lệnh `ss` được sử dụng để kiểm tra thông tin thống kê về các socket trong hệ thống Linux, thay thế cho lệnh `netstat` cũ. 

Ý nghĩa của các tùy chọn (Flags):
* `-t` (TCP): Hiển thị các socket TCP.
* `-u` (UDP): Hiển thị các socket UDP.
* `-l` (Listening): Chỉ hiển thị các socket đang ở trạng thái chờ kết nối (Listening).
* `-n` (Numeric): Hiển thị số cổng và địa chỉ IP dưới dạng số (không phân giải thành tên miền/dịch vụ như `http`, `ssh`).
* `-a` (All): Hiển thị tất cả các socket (cả đang lắng nghe và đang kết nối).
* `-p` (Processes): Hiển thị thông tin tiến trình (PID và tên tiến trình) đang sử dụng socket đó.

### Bảng so sánh nhanh 3 lệnh:

| Câu lệnh | Loại Socket | Trạng thái hiển thị | Phân giải tên | Thông tin Tiến trình (PID) |
| :--- | :--- | :--- | :--- | :--- |
| **`ss -tln`** | Chỉ **TCP** | Chỉ **LISTEN** | Không (Dạng số) | Không |
| **`ss -uln`** | Chỉ **UDP** | Chỉ **LISTEN** (Mở cổng) | Không (Dạng số) | Không |
| **`ss -anp`** | **Cả TCP & UDP** | **TẤT CẢ** (LISTEN, ESTABLISHED,...) | Không (Dạng số) | **Có** (Cần quyền `sudo`) |

---

## 2. Giải thích các trạng thái Socket (TCP States)

Các trạng thái dưới đây thể hiện vòng đời của một kết nối TCP từ lúc thiết lập, truyền dữ liệu cho đến khi ngắt kết nối hoàn toàn.


###  LISTEN
* **Ý nghĩa:** Trạng thái "đang đợi cửa". Socket của phía Server đã được mở và sẵn sàng tiếp nhận các yêu cầu thiết lập kết nối (gói tin `SYN`) gửi đến từ phía Client.
* **Ngữ cảnh:** Xuất hiện khi bạn khởi chạy một dịch vụ mạng (ví dụ: Nginx, MySQL, Node.js app) trên Server.

###  ESTABLISHED
* **Ý nghĩa:** Kết nối đã thiết lập thành công. Quá trình bắt tay 3 bước (TCP 3-way handshake) đã hoàn tất.
* **Ngữ cảnh:** Hai bên Client và Server đang trong trạng thái "thông tuyến", có thể truyền và nhận dữ liệu qua lại với nhau một cách an toàn.

###  TIME_WAIT
* **Ý nghĩa:** Chờ đóng hoàn toàn kết nối từ phía chủ động. Trạng thái này xảy ra ở phía **bên chủ động gửi yêu cầu ngắt kết nối trước** (thường là Client, nhưng đôi khi cũng là Server). Sau khi gửi gói tin ACK cuối cùng, socket sẽ giữ trạng thái `TIME_WAIT` trong một khoảng thời gian bằng 2 * MSL (Maximum Segment Lifetime - thường từ 1 đến 2 phút).
* **Mục đích:**
    * Đảm bảo gói tin ACK cuối cùng đã tới được đích (nếu bị mất, bên kia sẽ gửi lại FIN và trạng thái này giúp nhận diện để gửi lại ACK).
    * Ngăn chặn các gói tin cũ còn "lạc lạc" trên Internet làm nhiễu hoặc lỗi dữ liệu của một kết nối mới trùng Port/IP được tạo ngay sau đó.

###  CLOSE_WAIT
* **Ý nghĩa:** Chờ ứng dụng đóng kết nối từ phía bị động. Trạng thái này xảy ra ở phía **bên nhận được yêu cầu ngắt kết nối (FIN) từ bên kia**. Hệ điều hành đã tự động phản hồi lại bằng gói tin ACK, nhưng socket phải đứng đợi ở trạng thái `CLOSE_WAIT` cho đến khi ứng dụng tầng Application (như code Python, Java, Nginx...) thực hiện lệnh đóng socket một cách tường minh (`close()`).
* **Cảnh báo hệ thống:** Nếu hệ thống của bạn có quá nhiều socket kẹt ở trạng thái `CLOSE_WAIT`, đây là dấu hiệu của **Bug trong mã nguồn ứng dụng** (Application bị rò rỉ kết nối - Connection Leak), ứng dụng quên không gọi hàm close kết nối sau khi đối tác đã chủ động ngắt lời.