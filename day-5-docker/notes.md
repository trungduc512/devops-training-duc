## 1. Image gồm những lớp gì? Vì sao layer được cache?

### Các layer trong Docker Image

Docker Image được xây dựng dựa trên Union File System (UnionFS) dưới dạng nhiều lớp (layers) xếp chồng lên nhau.

- Mỗi filesystem layer là một lớp read-only (chỉ đọc), lưu trữ các thay đổi của hệ thống tệp so với layer trước đó.
- Khi build image từ Dockerfile, các lệnh làm thay đổi filesystem như `FROM`, `RUN`, `COPY` và `ADD` sẽ tạo ra các filesystem layer mới.
- Một số lệnh như `CMD`, `ENTRYPOINT`, `ENV`, `EXPOSE`, `WORKDIR`... không tạo filesystem layer mà chỉ cập nhật metadata của image.
- Khi chạy một container từ image, Docker thêm một container layer (read-write layer) lên trên tất cả các read-only layers. Mọi thay đổi khi container chạy (tạo file, sửa file, xóa file...) chỉ được ghi vào lớp này, còn các layer của image vẫn giữ nguyên.

### Vì sao layer được cache?

Docker cache từng layer để tăng hiệu quả build.

- Tiết kiệm thời gian build: Docker kiểm tra từng instruction trong Dockerfile. Nếu instruction và các dữ liệu đầu vào (build context) không thay đổi, Docker sẽ reuse layer đã build trước đó thay vì thực thi lại lệnh, giúp quá trình build nhanh hơn đáng kể.
- Tiết kiệm băng thông và dung lượng lưu trữ: Khi push hoặc pull image từ registry (ví dụ Docker Hub), Docker chỉ truyền các layer mới hoặc layer chưa tồn tại ở phía đích, thay vì truyền toàn bộ image.
- Tăng khả năng chia sẻ layer: Nhiều image có thể dùng chung các layer giống nhau (ví dụ cùng base image `ubuntu:24.04`), giúp giảm dung lượng lưu trữ trên máy.

### Best practice để tận dụng cache

Nên sắp xếp Dockerfile sao cho các bước ít thay đổi đặt trước, các bước thay đổi thường xuyên đặt sau.

Ví dụ:

```dockerfile
FROM node:22

COPY package*.json .
RUN npm install

COPY . .
```

Ở ví dụ trên, nếu chỉ thay đổi mã nguồn mà không thay đổi `package.json`, Docker sẽ sử dụng lại layer `RUN npm install` thay vì cài đặt lại toàn bộ dependencies, giúp build nhanh hơn đáng kể.




## 2. Sự khác nhau giữa COPY và ADD

`COPY` chỉ thực hiện một nhiệm vụ: sao chép file hoặc thư mục từ máy host vào bên trong image. Nó đơn giản, tường minh và an toàn.

`ADD` ngoài khả năng sao chép như `COPY` còn có thêm hai tính năng:

- Tự động giải nén các file nén như `.tar` và `.tar.gz`.
- Hỗ trợ tải file trực tiếp từ một URL từ xa.

Tuy nhiên, `ADD` ít được khuyến khích dùng cho sao chép thông thường vì nó có thể gây khó kiểm soát, đặc biệt khi vô tình tải nhầm file độc hại từ Internet.

## 3. CMD và ENTRYPOINT

Để quản lý cách một container khởi chạy, Docker cung cấp hai lệnh cấu hình quan trọng là `ENTRYPOINT` và `CMD`. Hiểu rõ bản chất và cách kết hợp giữa chúng là chìa khóa để xây dựng Docker image chuẩn hóa cho môi trường production.

### Khái niệm cốt lõi

- `ENTRYPOINT`: Định nghĩa lệnh chính và cố định sẽ luôn được thực thi khi container khởi động. Lệnh này đóng vai trò định danh mục đích của container và rất khó bị ghi đè từ bên ngoài khi chạy `docker run` (trừ khi dùng cờ đặc biệt `--entrypoint`).
- `CMD`: Cung cấp lệnh mặc định hoặc tham số mặc định cho `ENTRYPOINT`. Lệnh hoặc tham số của `CMD` có thể dễ dàng bị ghi đè nếu người dùng truyền thêm tham số khác lúc khởi chạy container.

### Bảng so sánh chi tiết

| Tiêu chí | CMD | ENTRYPOINT |
| --- | --- | --- |
| Mục đích chính | Cung cấp lệnh hoặc tham số cấu hình mặc định. | Xác định lệnh thực thi chính, cố định của container. |
| Khi chạy `docker run` | Dễ bị thay thế hoàn toàn nếu truyền tham số mới. | Rất khó bị ghi đè, tham số mới truyền vào sẽ biến thành đối số. |
| Tính chất đặc trưng | Linh hoạt, ưu tiên khả năng tùy biến. | Cố định, mang tính đóng gói một công cụ hoặc dịch vụ chuyên biệt. |
| Trường hợp áp dụng | Chạy script đơn giản, container chạy một lần hoặc thiết lập argument mặc định. | Khởi chạy ứng dụng server như Web, API, hoặc các công cụ CLI như Nginx, Ffmpeg, Curl. |

### Cơ chế kết hợp

Khi kết hợp cả hai lệnh trong cùng một Dockerfile, Docker sẽ lấy các giá trị trong `CMD` làm đối số đầu vào cho lệnh trong `ENTRYPOINT`.

#### Ví dụ thực tế

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

- Trường hợp 1, chạy mặc định: lệnh thực thi thực tế là `python app.py`.
- Trường hợp 2, ghi đè `CMD` từ CLI: lệnh thực thi thực tế là `python other_script.py`. Lúc này `CMD` mặc định đã bị thay thế bởi `other_script.py`.

### Hướng dẫn thực hành chuẩn

#### Quy tắc 1: Xác định rõ "nhân dạng" bằng `ENTRYPOINT`

Nếu container được build ra chỉ để phục vụ một mục đích duy nhất, hãy cố định runtime của nó bằng `ENTRYPOINT`.

```dockerfile
ENTRYPOINT ["nginx"]
```

#### Quy tắc 2: Tận dụng `CMD` làm tham số cấu hình mặc định

Kết hợp `ENTRYPOINT` cố định công cụ chạy và `CMD` để chứa các file hoặc tham số mặc định giúp container vừa chuyên biệt vừa linh hoạt.

```dockerfile
ENTRYPOINT ["java"]
CMD ["-jar", "app.jar"]
```

#### Quy tắc 3: Luôn sử dụng định dạng JSON (Exec Form)

Hãy luôn viết `CMD` và `ENTRYPOINT` dưới dạng mảng các chuỗi đặt trong dấu ngoặc kép.

- Nên dùng: `ENTRYPOINT ["python", "app.py"]`
- Tránh dùng: `ENTRYPOINT python app.py`

Lý do: shell form sẽ bọc lệnh của bạn qua một lớp `/bin/sh -c`. Điều này khiến tiến trình chính không nhận được các tín hiệu hệ thống Unix như `SIGTERM` khi chạy `docker stop`, dẫn đến container tắt chậm và không giải phóng tài nguyên an toàn.

### Tóm tắt kịch bản sử dụng

- Chỉ dùng `ENTRYPOINT`: khi tạo các công cụ CLI hoặc service bất biến.
- Chỉ dùng `CMD`: khi tạo các container chạy script ngắn hạn hoặc môi trường lab đơn giản.
- Kết hợp `ENTRYPOINT + CMD` là mô hình khuyến nghị cho các ứng dụng App Server và Microservices thực tế.

### Các lỗi cần tránh

- Sử dụng shell form bừa bãi: viết lệnh dạng chuỗi thuần túy khiến container chạy ngầm qua shell, gây khó debug và làm giảm khả năng xử lý tín hiệu hệ thống.
- Gói logic phức tạp trực tiếp vào `ENTRYPOINT`: ví dụ `ENTRYPOINT ["sh", "-c", "python app.py && làm_việc_khác"]`. Thay vào đó, hãy viết một file script khởi chạy riêng như `entrypoint.sh`, copy nó vào image và gọi file script đó bằng `ENTRYPOINT`.

## 4. Tại sao nên có .dockerignore?

Tương tự như `.gitignore` trong Git, file này giúp loại bỏ các file hoặc thư mục không cần thiết như `node_modules`, file log, cấu hình cục bộ nhạy cảm như `.env`, hoặc mã nguồn ẩn như `.git` ra khỏi build context trước khi gửi đến Docker daemon.

Việc này giúp giảm dung lượng image, tăng tốc độ build và ngăn chặn việc vô tình đóng gói các thông tin bảo mật quan trọng vào image công khai.


## 5. EXPOSE thực sự làm gì? Có tự mở port không?

### Bản chất của EXPOSE

`EXPOSE` chỉ mang tính chất tài liệu hướng dẫn (documentation). Nó thông báo cho người vận hành biết container này dự kiến sẽ lắng nghe trên port nào khi chạy.

### EXPOSE có tự mở port không?

Không. `EXPOSE` không tự động mở hoặc ánh xạ port ra ngoài máy host. Muốn truy cập được container từ bên ngoài, bạn phải dùng `-p` hoặc `-P` khi chạy `docker run`.

## 6. Tại sao không nên chạy container as root?

### Rủi ro khi chạy với root

Mặc định, các tiến trình bên trong container thường chạy dưới quyền `root`. Nếu ứng dụng có lỗ hổng bảo mật và bị khai thác, đặc quyền này có thể bị lợi dụng để thoát khỏi container và ảnh hưởng đến hệ thống máy host.

### Cách làm an toàn hơn

Chạy container bằng một user thông thường giúp tuân thủ nguyên tắc đặc quyền tối thiểu, giới hạn phạm vi ảnh hưởng nếu có sự cố và tăng mức độ an toàn cho máy chủ.