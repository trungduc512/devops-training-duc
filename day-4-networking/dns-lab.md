# DNS Lab

## Part B

### 1. Các lệnh kiểm tra DNS

```bash
dig google.com
dig +trace google.com
dig MX gmail.com
dig TXT google.com
dig @8.8.8.8 example.com
nslookup example.com
```

### 2. Giải thích `dig +trace`

`dig +trace google.com` không hỏi trực tiếp DNS resolver mặc định của máy. Thay vào đó, nó truy vấn theo từng bước từ root server xuống các tầng thấp hơn của hệ thống DNS.

Luồng hoạt động:

1. Hỏi root server để biết `.com` do ai quản lý.
2. Hỏi TLD server của `.com` để biết `google.com` được ủy quyền cho nameserver nào.
3. Hỏi authoritative nameserver của `google.com` để lấy bản ghi cuối cùng.

Ý nghĩa của output:

- Các dòng `; <<>> DiG <<>> +trace ...` cho biết đây là chế độ trace.
- Các phần `NS` ở từng bước thể hiện delegation, tức là DNS đang chuyển hướng truy vấn sang cấp nameserver tiếp theo.
- Khi gặp phần `ANSWER SECTION`, đó là nơi trả về kết quả cuối cùng cho tên miền cần tra cứu.
- Nếu trace bị chặn ở một bước nào đó, thường là do network không ra được root/TLD server, firewall, hoặc vấn đề DNS route.

### 3. Cấu hình `/etc/hosts` để map domain giả về `127.0.0.1`

Ví dụ map `local.test` về localhost:

```bash
sudo sh -c 'echo "127.0.0.1 local.test" >> /etc/hosts'
```

Kiểm tra lại:

```bash
getent hosts local.test
ping -c 1 local.test
```

Kết quả mong đợi:

- `getent hosts local.test` trả về `127.0.0.1`.
- `ping local.test` sẽ ping tới máy local, không đi ra DNS bên ngoài.

Lưu ý: `/etc/hosts` thường được ưu tiên trước DNS, nên nếu tên miền có trong file này thì hệ thống sẽ dùng bản ghi ở đây trước.

### 4. Phân biệt `/etc/hosts`, `/etc/resolv.conf`, `systemd-resolved`

#### `/etc/hosts`

- Là file ánh xạ tĩnh giữa hostname và IP.
- Dùng cho các mapping thủ công, nội bộ, test lab, hoặc override nhanh.
- Không cần truy vấn DNS để dùng dữ liệu trong file này.

#### `/etc/resolv.conf`

- Là file cấu hình DNS resolver cho máy.
- Thường chứa địa chỉ DNS server mà hệ thống sẽ hỏi khi không tìm thấy trong `/etc/hosts`.
- Có thể do NetworkManager, DHCP client, hoặc `systemd-resolved` sinh ra và quản lý.

#### `systemd-resolved`

- Là dịch vụ quản lý phân giải tên miền trên nhiều bản Linux hiện đại.
- Có thể cung cấp DNS cache, stub resolver, split DNS và quản lý DNS theo từng interface.
- Thường là thành phần đứng giữa ứng dụng và DNS server thật.

#### Quan hệ giữa chúng

- Ứng dụng hỏi hệ thống qua cơ chế resolver của OS.
- Hệ thống kiểm tra `/etc/hosts` trước.
- Nếu không có kết quả, nó dùng DNS server được khai báo trong `/etc/resolv.conf`.
- Nếu máy dùng `systemd-resolved`, file `/etc/resolv.conf` có thể chỉ là symlink trỏ về stub resolver của dịch vụ này.

### 5. Tóm tắt nhanh

- `dig` dùng để xem truy vấn DNS chi tiết.
- `dig +trace` giúp nhìn toàn bộ hành trình từ root đến authoritative nameserver.
- `/etc/hosts` dùng để map tĩnh và ưu tiên hơn DNS.
- `/etc/resolv.conf` cho biết máy sẽ hỏi DNS server nào.
- `systemd-resolved` là lớp quản lý resolver/caching trên nhiều distro hiện đại.
