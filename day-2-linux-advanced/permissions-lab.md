# Permission Lab

## 1. Tạo group `devops`

```bash
sudo groupadd devops
```

Kiểm tra:

```bash
getent group devops
```

---

## 2. Thêm user vào group

Ví dụ user hiện tại là `duc`:

```bash
sudo usermod -aG devops duc
```

Đăng nhập lại hoặc chạy:

```bash
newgrp devops
```

Kiểm tra:

```bash
groups
```

---

## 3. Tạo thư mục `/tmp/shared-lab`

```bash
sudo mkdir -p /tmp/shared-lab
```

Đổi group:

```bash
sudo chgrp devops /tmp/shared-lab
```

Cấp quyền đọc/ghi/thực thi cho owner và group:

```bash
sudo chmod 2775 /tmp/shared-lab
```

Giải thích:

* `2` là **setgid bit**
* `775` tương ứng:

  * Owner: rwx
  * Group: rwx
  * Others: r-x

Kiểm tra:

```bash
ls -ld /tmp/shared-lab
```

Ví dụ:

```text
drwxrwsr-x
```

Ký tự `s` ở vị trí group cho biết setgid đã được bật.

---

## 4. Kiểm tra kế thừa group

Tạo file:

```bash
touch /tmp/shared-lab/test.txt
```

Kiểm tra:

```bash
ls -l /tmp/shared-lab
```

Ví dụ:

```text
-rw-r--r-- 1 duc devops 0 Jun 18 test.txt
```

Mặc dù user là `duc`, group của file vẫn là `devops`, chứng tỏ setgid hoạt động.

---

## 5. Tạo file `secret.txt`

```bash
touch /tmp/shared-lab/secret.txt
```

Chỉ owner được đọc và ghi:

```bash
chmod 600 /tmp/shared-lab/secret.txt
```

Kiểm tra:

```bash
ls -l /tmp/shared-lab/secret.txt
```

Kết quả:

```text
-rw------- 1 duc devops ...
```

---

## 6. Cấp quyền chỉ đọc bằng ACL

Giả sử có user `alice`.

Cho phép chỉ đọc:

```bash
sudo setfacl -m u:alice:r /tmp/shared-lab/secret.txt
```

Kiểm tra ACL:

```bash
getfacl /tmp/shared-lab/secret.txt
```

Ví dụ:

```text
user::rw-
user:alice:r--
group::---
mask::r--
other::---
```

---

## 7. Kiểm tra

Đăng nhập bằng user `alice`:

```bash
su - alice
```

Đọc file:

```bash
cat /tmp/shared-lab/secret.txt
```

Thành công.

Thử ghi:

```bash
echo hello >> /tmp/shared-lab/secret.txt
```

Kết quả:

```text
Permission denied
```

Điều này chứng minh ACL chỉ cấp quyền đọc.

---

## Các lệnh sử dụng

```bash
groupadd
usermod
mkdir
chgrp
chmod
touch
ls
setfacl
getfacl
groups
```
