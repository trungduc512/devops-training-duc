# TLS Lab

## 1. `curl -v https://example.com`

```text
* Host example.com:443 was resolved.
* IPv6: 2606:4700:10::6814:179a, 2606:4700:10::ac42:93f3
* IPv4: 172.66.147.243

# ===== DNS Resolution =====
# Domain example.com được phân giải thành địa chỉ IPv6 và IPv4.

*   Trying 172.66.147.243:443...
* Connected to example.com (172.66.147.243) port 443

# ===== TCP Connect =====
# curl bắt đầu kết nối TCP đến IP 172.66.147.243 cổng 443.
# Quá trình TCP 3-way handshake (SYN -> SYN/ACK -> ACK) diễn ra ở đây.

* ALPN: curl offers h2,http/1.1
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
*  CAfile: /etc/ssl/certs/ca-certificates.crt
*  CApath: /etc/ssl/certs
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):

# ===== TLS Handshake =====
# Client và Server thương lượng phiên bản TLS.
# Thương lượng Cipher Suite.
# Server gửi Certificate.
# Client kiểm tra Certificate.
# Hai bên hoàn tất trao đổi khóa và bắt đầu mã hóa dữ liệu.

* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / X25519 / id-ecPublicKey

# Cipher Suite:
# TLS_AES_256_GCM_SHA384

* ALPN: server accepted h2

# Server chọn giao thức HTTP/2.

* Server certificate:
*  subject: CN=example.com
*  start date: May 31 21:39:12 2026 GMT
*  expire date: Aug 29 21:41:26 2026 GMT
*  subjectAltName: host "example.com" matched cert's "example.com"
*  issuer: C=US; O=SSL Corporation; CN=Cloudflare TLS Issuing ECC CA 3
*  SSL certificate verify ok.

# Certificate:
# Subject: example.com
# Issuer : Cloudflare TLS Issuing ECC CA 3
# SAN    : example.com
# Certificate được xác thực thành công.

* using HTTP/2
* [HTTP/2] [1] OPENED stream for https://example.com/
* [HTTP/2] [1] [:method: GET]
* [HTTP/2] [1] [:scheme: https]
* [HTTP/2] [1] [:authority: example.com]
* [HTTP/2] [1] [:path: /]
* [HTTP/2] [1] [user-agent: curl/8.5.0]
* [HTTP/2] [1] [accept: */*]

> GET / HTTP/2
> Host: example.com
> User-Agent: curl/8.5.0
> Accept: */*

# ===== HTTP Request Headers =====
# Phương thức: GET
# Host: example.com
# User-Agent: curl/8.5.0
# Accept: */*

* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing

< HTTP/2 200
< date: Mon, 22 Jun 2026 02:50:34 GMT
< content-type: text/html
< server: cloudflare
< last-modified: Fri, 19 Jun 2026 18:46:03 GMT
< allow: GET, HEAD
< accept-ranges: bytes
< age: 7
< cf-cache-status: HIT
< cf-ray: a0f7f240a899854b-HKG

# ===== HTTP Response Headers =====
# Status: HTTP/2 200 OK
# Content-Type: text/html
# Server: cloudflare
# Response body là trang HTML "Example Domain".
```

## Giải thích các phần

### DNS Resolution

```
Host example.com:443 was resolved.
IPv4: 172.66.147.243
IPv6: ...
```

* DNS phân giải tên miền `example.com` thành địa chỉ IP.
* curl sẽ dùng một trong các địa chỉ IP này để kết nối.

---

### TCP Connect

```
Trying 172.66.147.243:443...
Connected to example.com
```

* Thiết lập kết nối TCP tới cổng 443.
* Quá trình TCP 3-way handshake diễn ra trước khi bắt đầu TLS.

---

### TLS Handshake

```
Client Hello
Server Hello
Certificate
CERT Verify
Finished
```

Trong giai đoạn này:

* Client và Server thương lượng TLS 1.3.
* Chọn Cipher Suite.
* Server gửi Certificate.
* Client kiểm tra Certificate.
* Hai bên tạo khóa phiên (Session Key).

Cipher được chọn:

```
TLS_AES_256_GCM_SHA384
```

---

### Certificate

```
Subject : example.com
Issuer  : Cloudflare TLS Issuing ECC CA 3
```

Certificate được CA ký và curl xác thực thành công:

```
SSL certificate verify ok.
```

---

### HTTP Request

```
GET / HTTP/2
Host: example.com
User-Agent: curl/8.5.0
```

Đây là request được gửi sau khi kênh TLS đã được thiết lập.

---

### HTTP Response

```
HTTP/2 200
Content-Type: text/html
Server: cloudflare
```

Server trả về mã trạng thái 200 cùng nội dung HTML của trang Example Domain.


## 2. Xem Certificate Chain bằng OpenSSL

### Lệnh

```bash
openssl s_client -connect example.com:443 -showcerts
```

### Kết quả (rút gọn)

```text
CONNECTED(00000003)

depth=3 C = US, O = SSL Corporation, CN = SSL.com TLS ECC Root CA 2022
verify return:1

depth=2 C = US, O = SSL Corporation, CN = SSL.com TLS Transit ECC CA R2
verify return:1

depth=1 C = US, O = SSL Corporation, CN = Cloudflare TLS Issuing ECC CA 3
verify return:1

depth=0 CN = example.com
verify return:1

Certificate chain

0 s:CN = example.com
  i:C = US, O = SSL Corporation,
    CN = Cloudflare TLS Issuing ECC CA 3

1 s:C = US, O = SSL Corporation,
    CN = Cloudflare TLS Issuing ECC CA 3
  i:C = US, O = SSL Corporation,
    CN = SSL.com TLS Transit ECC CA R2

2 s:C = US, O = SSL Corporation,
    CN = SSL.com TLS Transit ECC CA R2
  i:C = US, O = SSL Corporation,
    CN = SSL.com TLS ECC Root CA 2022

3 s:C = US, O = SSL Corporation,
    CN = SSL.com TLS ECC Root CA 2022
  i:C = GB, O = Comodo CA Limited,
    CN = AAA Certificate Services

Verification: OK

New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384

Verify return code: 0 (ok)
```

---

## Giải thích Certificate Chain

Certificate chain là chuỗi các chứng chỉ dùng để xác minh rằng chứng chỉ của website là đáng tin cậy.

Chuỗi chứng chỉ của `example.com`:

```text
AAA Certificate Services
        │
        ▼
SSL.com TLS ECC Root CA 2022
        │
        ▼
SSL.com TLS Transit ECC CA R2
        │
        ▼
Cloudflare TLS Issuing ECC CA 3
        │
        ▼
example.com
```

Ý nghĩa từng cấp:

* **Level 0 (Leaf Certificate)**

  * Certificate của website `example.com`.
  * Đây là chứng chỉ mà trình duyệt sử dụng khi truy cập website.

* **Level 1 (Intermediate CA)**

  * `Cloudflare TLS Issuing ECC CA 3`
  * CA trung gian dùng để ký chứng chỉ của website.

* **Level 2 (Intermediate CA)**

  * `SSL.com TLS Transit ECC CA R2`
  * Tiếp tục xác nhận CA ở cấp dưới.

* **Level 3 (Root CA)**

  * `SSL.com TLS ECC Root CA 2022`
  * Root CA được hệ điều hành hoặc trình duyệt tin cậy.

Ngoài ra output còn cho biết:

* **Protocol:** TLSv1.3
* **Cipher Suite:** TLS_AES_256_GCM_SHA384
* **Server Temporary Key:** X25519
* **Certificate Verification:** `Verify return code: 0 (ok)` (chứng chỉ hợp lệ).


## 3. TLS 1.3 Handshake (đơn giản hoá)

```text
                         TLS 1.3 Handshake

Client                                              Server
  |                                                    |
  |---------------- ClientHello ----------------------->|
  |  - Supported TLS Version                           |
  |  - Cipher Suites                                   |
  |  - Key Share (ECDHE)                               |
  |  - SNI                                             |
  |  - ALPN                                            |
  |                                                    |
  |<--------------- ServerHello ------------------------|
  |        Chọn TLS Version                            |
  |        Chọn Cipher Suite                           |
  |        Server Key Share                            |
  |                                                    |
  |<------------- Encrypted Extensions ----------------|
  |                                                    |
  |<--------------- Certificate ------------------------|
  |                                                    |
  |<------------- Certificate Verify ------------------|
  |                                                    |
  |<------------------ Finished ------------------------|
  |                                                    |
  |------------------ Finished ------------------------>|
  |                                                    |
  |========== Kênh TLS được thiết lập ================|
  |                                                    |
  |<========== HTTP Request / Response ================>|
```

### Giải thích

1. **ClientHello**

* Client khởi tạo kết nối TLS.
* Gửi danh sách phiên bản TLS hỗ trợ.
* Gửi danh sách Cipher Suites.
* Gửi Key Share để trao đổi khóa.
* Gửi SNI và ALPN.

2. **ServerHello**

* Server chọn phiên bản TLS.
* Chọn Cipher Suite.
* Gửi Key Share của server.

3. **Certificate**

* Server gửi chứng chỉ số (Certificate).
* Client sẽ kiểm tra Certificate Chain.

4. **Certificate Verify**

* Server chứng minh mình sở hữu Private Key tương ứng với Certificate.

5. **Finished**

* Hai bên xác nhận quá trình handshake hoàn tất.
* Từ thời điểm này toàn bộ dữ liệu đều được mã hóa bằng khóa phiên.

---

## Vai trò của SNI

**SNI (Server Name Indication)** cho phép client thông báo tên miền muốn truy cập ngay trong ClientHello.

Ví dụ:

```text
203.0.113.10

├── example.com
├── api.example.com
└── shop.example.com
```

Ba website dùng chung một địa chỉ IP.

Client sẽ gửi:

```text
SNI = example.com
```

Server nhờ đó biết phải gửi đúng Certificate cho `example.com`.

Nếu không có SNI, server sẽ không biết website nào đang được yêu cầu và có thể trả về sai Certificate.

---

## Vai trò của ALPN

**ALPN (Application-Layer Protocol Negotiation)** được dùng để thương lượng giao thức tầng ứng dụng sẽ sử dụng sau khi TLS được thiết lập.

Ví dụ:

Client hỗ trợ:

```text
HTTP/2
HTTP/1.1
```

Server hỗ trợ:

```text
HTTP/2
```

Sau handshake:

```text
ALPN: h2
```

Hai bên sẽ sử dụng HTTP/2 để truyền dữ liệu.

Trong kết quả `curl -v`:

```text
ALPN: curl offers h2,http/1.1
ALPN: server accepted h2
```

cho thấy client đề xuất HTTP/2 và HTTP/1.1, còn server chọn HTTP/2.

---

## Vai trò của OCSP

**OCSP (Online Certificate Status Protocol)** dùng để kiểm tra Certificate có bị thu hồi (revoked) hay không.

Ví dụ:

* Private Key bị lộ.
* Certificate bị CA thu hồi.

Client có thể hỏi OCSP Server:

```text
Certificate này còn hợp lệ không?
```

Kết quả:

```text
Good
Revoked
Unknown
```

Hiện nay nhiều website sử dụng **OCSP Stapling**, trong đó server gửi sẵn trạng thái OCSP trong quá trình TLS handshake để giảm thời gian xác thực.

---

## Vai trò của SAN

**SAN (Subject Alternative Name)** là danh sách các tên miền mà Certificate có hiệu lực.

Ví dụ:

```text
Subject Alternative Name

DNS:example.com
DNS:www.example.com
DNS:api.example.com
DNS:*.example.com
```

Điều này có nghĩa Certificate có thể dùng cho:

* example.com
* [www.example.com](http://www.example.com)
* api.example.com
* các subdomain phù hợp với wildcard `*.example.com`

Trong output `curl -v`:

```text
subjectAltName: host "example.com" matched cert's "example.com"
```

Điều này cho thấy tên miền truy cập khớp với SAN của Certificate nên việc xác thực thành công.

---

## Tóm tắt

| Thành phần | Vai trò                                                                  |
| ---------- | ------------------------------------------------------------------------ |
| **SNI**    | Cho server biết client muốn truy cập domain nào để gửi đúng Certificate. |
| **ALPN**   | Thương lượng giao thức tầng ứng dụng (HTTP/1.1, HTTP/2, HTTP/3...).      |
| **OCSP**   | Kiểm tra Certificate có bị thu hồi hay không.                            |
| **SAN**    | Danh sách các domain được Certificate bảo vệ.                            |
