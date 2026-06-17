## Task: `day-1-linux`

- **Intern**: `Đỗ Trung Đức`
- **Phase / Week / Day**: `Phase 1 / Week 1 / Day 1`
- **Branch**: `phase-1/week-1/day-1-linux`
- **Submitted at**: `2026-06-17 19:00:00 +07`
- **Time spent**: `6`

## 1. Mục tiêu
- Quen với 20+ command Linux dùng hằng ngày.
- Viết được bash script đơn giản.
- Hiểu khái niệm: file system hierarchy, permission, user/group, pipe, redirect.

## 2. Cách chạy
1. Chuẩn bị trước khi chạy 

```bash
chmod +x lab.sh backup.sh
```
2. Cách chạy file lab.sh
```bash
./lab.sh
```

3. Cách chạy file backup.sh


Xem hướng dẫn sử dụng
```bash
./backup.sh --help
# Hoặc
./backup.sh -h
```

Chạy thực hiện backup thư mục hiện tại
```bash
./backup.sh .
```

Exclude file có các pattern
```bash
./backup.sh . --exclude=PATTERN
```


## 3. Kết quả
- Screenshot / log output (kèm trong `./screenshots/`).

## 4. Khó khăn & cách giải quyết
Vấn đề: Khi thực hiện yêu cầu thống kê 10 địa chỉ IP xuất hiện nhiều nhất trong /var/log/auth.log, em nhận thấy file auth.log chưa có dữ liệu về địa chỉ IP do hệ thống chưa phát sinh các phiên đăng nhập SSH.

Cách giải quyết: Em cài đặt và khởi động SSH Server trên máy, sau đó thực hiện đăng nhập bằng lệnh ssh localhost. Việc này tạo các bản ghi xác thực trong /var/log/auth.log, bao gồm địa chỉ IP 127.0.0.1 (hoặc ::1 nếu sử dụng IPv6). Sau đó, chạy lại script để kiểm tra chức năng thống kê địa chỉ IP và xác nhận rằng kết quả được hiển thị đúng.

## 5. Reference
[https://last9.io/blog/what-is-var-log/](https://last9.io/blog/what-is-var-log/)

## 6. Self-check
- [x] Code chạy được trên máy sạch.
- [x] README có hướng dẫn run lại.
- [x] Không hard-code secret.
- [x] Commit message theo Conventional Commits.
- [x] Đã review lại code 1 lượt.