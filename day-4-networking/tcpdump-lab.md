# TCPdump Lab

## 1. Thứ tự packet

### (1) TCP 3-way handshake

```text
SYN
172.20.87.32 → 104.20.23.154
Flags [S]

SYN-ACK
104.20.23.154 → 172.20.87.32
Flags [S.]

ACK
172.20.87.32 → 104.20.23.154
Flags [.] 
```

### (2) HTTP Request

```text
HTTP GET
172.20.87.32 → 104.20.23.154
GET / HTTP/1.1
Host: example.com
```

### (3) Server Response

```text
ACK (server xác nhận request)
104.20.23.154 → 172.20.87.32
ACK 75

HTTP 200 OK + HTML
104.20.23.154 → 172.20.87.32
HTTP/1.1 200 OK
+ HTML body (Example Domain)
```

### (4) Connection close

```text
FIN (client)
172.20.87.32 → 104.20.23.154
Flags [F.]

FIN (server)
104.20.23.154 → 172.20.87.32
Flags [F.]

Final ACK
172.20.87.32 → 104.20.23.154
Flags [.] 
```

## 2. HTTPS thì bắt được gì?

Với HTTPS, bạn vẫn bắt được phần đầu của kết nối như DNS resolution, TCP 3-way handshake, và TLS handshake. Trong TLS handshake, có thể thấy các thông tin như SNI, ALPN, cipher suite, và certificate chain.

Bạn không bắt được HTTP payload vì sau khi TLS bắt tay xong, toàn bộ request/response HTTP được mã hóa thành TLS application data. Packet capture chỉ thấy dữ liệu mã hóa, không đọc được `GET /`, headers, hay body như với HTTP thường.

Muốn xem payload HTTPS thì cần một trong các cách sau:

```text
1. Có session keys để giải mã traffic
2. Dùng proxy MITM với certificate tin cậy trên máy client
3. Bật cơ chế log key như SSLKEYLOGFILE trên client
```

Tóm lại: với HTTPS, bạn bắt được metadata của kết nối, nhưng không bắt được nội dung HTTP nếu không giải mã thêm.