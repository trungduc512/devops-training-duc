## 1. Docker Bridge Network

### Bước 1: Tạo một bridge network riêng có tên là `demo-net`

**Command:**

```bash
docker network create demo-net
```

**Output:**

```
327a42f6264a1f449a30e4bc62751d2f16b255c98e4bb8366d168beb5a47ed61
```

**Kiểm tra:**
```bash
docker network ls
```

**Output:**

| NETWORK ID     | NAME     | DRIVER | SCOPE |
|----------------|----------|--------|-------|
| 327a42f6264a   | demo-net | bridge | local |
---

### Bước 2: Chạy 2 container cùng network

**Command chạy `app1`:**

```bash
docker run -d \
  --name app1 \
  --network demo-net \
  -e NAME=app1 \
  demo-app
```

**Output:**

```
573ac7a541f7df10fe7617d67473cbe29bed9aed855ef9946fc35559453280e3
```

**Command chạy `app2`:**

```bash
docker run -d \
  --name app2 \
  --network demo-net \
  -e NAME=app2 \
  demo-app
```

**Output:**

```
1671f158c638458fd3089c48caa66954964405f694639a53d83d748c3176e889
```
---

### Bước 3: Kiểm tra giao tiếp giữa các container qua DNS (từ `app1` gọi tới `app2`)

Cài đặt `curl` vào container `app1` (do base image alpine không có sẵn `curl` và ứng dụng đang chạy dưới user non-root `node`, ta thực thi dưới quyền `root` để cài đặt):
**Command:**

```bash
docker exec -u root app1 apk add --no-cache curl
```

**Output:**

```
(1/9) Installing brotli-libs (1.2.0-r0)
(2/9) Installing c-ares (1.34.6-r0)
(3/9) Installing libunistring (1.4.1-r0)
(4/9) Installing libidn2 (2.3.8-r0)
(5/9) Installing nghttp2-libs (1.69.0-r0)
(6/9) Installing libpsl (0.21.5-r3)
(7/9) Installing zstd-libs (1.5.7-r2)
(8/9) Installing libcurl (8.19.0-r0)
(9/9) Installing curl (8.19.0-r0)
Executing busybox-1.37.0-r30.trigger
OK: 15.9 MiB in 27 packages
```

Thực hiện lệnh `curl` từ container `app1` đến `http://app2:3000`:
**Command:**

```bash
docker exec app1 curl -s http://app2:3000
```

**Output:**

```json
{"msg":"hello from app2","ts":1782158560780}
```

---

## 2. Docker Volume Persistence (PostgreSQL)

### Bước 1: Tạo PostgreSQL với named volume

Khởi tạo volume có tên là `pgdata` và mount vào thư mục lưu trữ dữ liệu của Postgres `/var/lib/postgresql/data`.
**Command:**

```bash
docker volume create pgdata
```

**Output:**

```
pgdata
```

Run PostgreSQL

```bash
docker run -d \
  --name postgres-demo \
  --network demo-net \
  -e POSTGRES_PASSWORD=123456 \
  -v pgdata:/var/lib/postgresql/data \
  postgres:16-alpine
```

**Output:**
```
d80d24f769a918ec6e2fda9859db1cb8cd1bf622f18576326345313a9e3c07a0
```

---

### Bước 2: Tạo dữ liệu trong database

Kết nối vào cơ sở dữ liệu
**Command:**

```bash
docker exec -it postgres-demo psql -U postgres
```

Trong psql
```bash
CREATE DATABASE demo;
\l
```

**Output:**

```
CREATE DATABASE
                                                      List of databases
   Name    |  Owner   | Encoding | Locale Provider |  Collate   |   Ctype    | ICU Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+------------+------------+------------+-----------+-----------------------
 demo      | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | 
 postgres  | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | 
 template0 | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | =c/postgres          +
           |          |          |                 |            |            |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | =c/postgres          +
           |          |          |                 |            |            |            |           | postgres=CTc/postgres
(4 rows)

```

Thoát:
```bash
\q
```
---

### Bước 3: Restart container

Chúng ta tiến hành khởi động lại container.
**Command:**

```bash
docker restart postgres-demo
```

**Output:**

```
postgres-demo
```

Kiểm tra lại xem dữ liệu đã ghi có còn tồn tại hay không.
**Command:**

```bash
docker exec -i postgres-demo psql -U postgres -c "\list"
```

**Output:**

```
                                                      List of databases
   Name    |  Owner   | Encoding | Locale Provider |  Collate   |   Ctype    | ICU Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+------------+------------+------------+-----------+-----------------------
 demo      | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | 
 postgres  | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | 
 template0 | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | =c/postgres          +
           |          |          |                 |            |            |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | =c/postgres          +
           |          |          |                 |            |            |            |           | postgres=CTc/postgres
(4 rows)
```

---

## 3. Bind Mount

### Bước 1: Tạo thư mục chứa mã nguồn tĩnh trên host và file `index.html` ban đầu

**Command:**

```bash
mkdir -p site && echo "<h1>Hello Docker</h1>" > site/index.html
```

---

### Bước 2: Chạy container Nginx sử dụng Bind Mount tới thư mục vừa tạo

Mount thư mục cục bộ `site` trên host vào `/usr/share/nginx/html` của Nginx container.
**Command:**

```bash
docker run -d --name web-nginx -p 8080:80 -v $PWD/site:/usr/share/nginx/html nginx:alpine
```

**Output:**

```
2a556466e143820adc51b4e6495663e2817176e83e36bf9ddb0ca07d41fe94c8
```

---

### Bước 3: Kiểm tra nội dung ban đầu từ bên ngoài host

**Command:**

```bash
curl http://localhost:8080
```

**Output:**

```html
<h1>Hello Docker</h1>
```

---

### Bước 4: Sửa đổi file tĩnh trên máy host, reload Nginx và kiểm tra thay đổi

Tiến hành cập nhật nội dung file `site/index.html` (vì là file tĩnh nên không cần reload nginx)
**Command:**

```bash
echo "<h1>Hello updated</h1>" > site/index.html && curl http://localhost:8080
```

**Output:**

```
<h1>Hello updated</h1>
```