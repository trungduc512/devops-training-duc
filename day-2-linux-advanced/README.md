# Task Submission Template

## Task: `Day 2: Linux Advanced`

* **Intern**: `Đỗ Trung Đức`
* **Phase / Week / Day**: `Phase 1 / Week 1 / Day 2`
* **Branch**: `phase-1/week-1/day-2-linux-advanced`
* **Submitted at**: `2026-06-18 19:00 (+07)`
* **Time spent**: `5 hours`

---

# 1. Mục tiêu

* Tìm hiểu Linux Process và Signal.
* Làm quen với Systemd Service.
* Thực hành Linux Permission, SetGID và ACL.
* Viết Bash Script để giám sát hệ thống.
* Chạy Bash Script dưới dạng Systemd Service.

---

# 2. Cách chạy

## Part A - Process & Signal

```bash
chmod +x lab-process.sh
./lab-process.sh
```

Script sẽ:

* Tạo process `sleep 300` chạy nền.
* Hiển thị PID và PPID.
* Gửi `SIGTERM`.
* Hiển thị exit code của process.

---

## Part B - Systemd Service

### Tạo thư mục web

```bash
sudo mkdir -p /opt/webapp
echo "<h1>Hello Systemd</h1>" | sudo tee /opt/webapp/index.html
```

### Đăng ký service

```bash
sudo cp webapp.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable --now webapp
```

### Kiểm tra

```bash
systemctl status webapp

journalctl -u webapp -f
```

### Kiểm tra Auto Restart

```bash
sudo kill -9 $(pgrep -f "http.server 8080")

systemctl status webapp
```

Nếu cấu hình đúng, Systemd sẽ tự khởi động lại service sau khoảng 3 giây.

---

## Part C - Linux Permission

```bash
chmod +x permissions-lab.sh

sudo ./permissions-lab.sh
```

Script sẽ:

* Tạo group `devops`.
* Tạo thư mục `/tmp/shared-lab`.
* Thiết lập quyền đọc/ghi cho group.
* Bật SetGID để file mới tự kế thừa group.
* Tạo `secret.txt` chỉ owner được đọc.
* Cấu hình ACL cho một user khác chỉ có quyền đọc.

---

## Part D - Monitoring Service

### Copy script

```bash
sudo mkdir -p /opt/monitor

sudo cp monitor.sh /opt/monitor/
sudo chmod +x /opt/monitor/monitor.sh
```

### Đăng ký service

```bash
sudo cp monitor.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable --now monitor
```

### Kiểm tra

```bash
systemctl status monitor

journalctl -u monitor -f
```

### Dừng service

```bash
sudo systemctl stop monitor

journalctl -u monitor -n 10
```

---

# 3. Kết quả

* Hoàn thành đầy đủ 4 phần của bài lab.
* Screenshot và log được lưu trong thư mục `screenshots/`.

---

# 4. Khó khăn & cách giải quyết

* Mất nhiều thời gian để làm quen với cách hoạt động của **Systemd**, đặc biệt là cơ chế `Restart`, `ExecStart` và `journalctl`.
* Gặp lỗi `status=203/EXEC` do `ExecStart` trỏ tới sai đường dẫn và script chưa được cấp quyền thực thi. Đã khắc phục bằng cách đặt script vào `/opt/monitor`, cấp quyền `chmod +x` và chạy `systemctl daemon-reload`.
* Tìm hiểu thêm về **SetGID**, **ACL** và cách Systemd quản lý vòng đời của service.

---

# 5. Reference

---

# 6. Self-check

* [x] Code chạy được trên máy sạch.
* [x] README có hướng dẫn chạy lại.
* [x] Không hard-code secret.
* [x] Commit message theo Conventional Commits.
* [x] Đã review lại code một lượt.
