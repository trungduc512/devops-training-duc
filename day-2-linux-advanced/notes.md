# Part A — Process & Signal

Tài liệu này giải thích các signal phổ biến, cách tách process khỏi terminal, cách tìm và kill process theo command line, và cách đọc trạng thái tiến trình trong `ps`.

## 1. Sự khác nhau giữa `SIGTERM`, `SIGKILL`, `SIGHUP`, `SIGINT`

| Signal | Số | Nguồn phát sinh điển hình | Có thể bắt/ignore? | Ý nghĩa thực tế |
|--------|----|---------------------------|--------------------|-----------------|
| `SIGTERM` | 15 | `kill`, `systemctl stop`, service manager | Có | Yêu cầu tiến trình dừng một cách “đàng hoàng” |
| `SIGKILL` | 9 | `kill -9` | Không | Buộc tiến trình chết ngay lập tức |
| `SIGHUP` | 1 | Terminal bị đóng, hoặc người quản trị gửi tay | Có | Báo mất controlling terminal, hoặc yêu cầu reload cấu hình |
| `SIGINT` | 2 | `Ctrl+C` trong terminal | Có | Ngắt tiến trình đang chạy từ bàn phím |

### `SIGTERM`

Đây là signal mặc định khi bạn chạy `kill <pid>`.

Tiến trình có thể xử lý `SIGTERM` để:

- ghi log cuối cùng
- đóng file descriptor
- giải phóng lock, socket, temporary file
- dừng worker theo thứ tự an toàn

Vì vậy `SIGTERM` thường là lựa chọn đầu tiên khi muốn dừng một chương trình.

Ví dụ:

```bash
kill 1234
```

### `SIGKILL`

Đây là “phương án cuối cùng”. Kernel sẽ chấm dứt process ngay, không cho chương trình cơ hội cleanup.

Điểm quan trọng:

- không thể bắt
- không thể bỏ qua
- không thể xử lý bằng handler trong code

Hệ quả là có thể để lại file tạm, lock file, hoặc trạng thái dang dở trong ứng dụng.

Ví dụ:

```bash
kill -9 1234
```

### `SIGHUP`

Ban đầu signal này dùng để báo rằng terminal đã bị ngắt kết nối. Trong thực tế hiện nay, nhiều daemon dùng `SIGHUP` như một tín hiệu “reload cấu hình”.

Nó thường được dùng khi:

- muốn đọc lại file cấu hình mà không restart hoàn toàn
- muốn reload log file
- daemon cần re-open connection hoặc reset một phần trạng thái

Ví dụ phổ biến:

```bash
kill -HUP $(cat /run/nginx.pid)
```

### `SIGINT`

Signal này thường xuất hiện khi bạn bấm `Ctrl+C` trong terminal. Nó giống một lệnh ngắt tương tác từ người dùng.

Ứng dụng có thể:

- dừng ngay
- hoặc bắt signal để cleanup rồi thoát

Ví dụ:

```bash
python app.py
```

Nhấn `Ctrl+C` sẽ gửi `SIGINT` cho process foreground.

### Tóm tắt nhanh

- `SIGTERM`: xin dừng an toàn
- `SIGKILL`: buộc dừng, không thương lượng
- `SIGHUP`: báo ngắt terminal hoặc yêu cầu reload
- `SIGINT`: ngắt từ bàn phím, thường là `Ctrl+C`

## 2. `nohup` vs `disown` vs `setsid`

Ba cách này đều liên quan đến việc để process tiếp tục chạy sau khi bạn đóng terminal, nhưng chúng làm việc ở các lớp khác nhau.

### `nohup`

`nohup` chạy command với hành vi bỏ qua `SIGHUP`.

Kết quả:

- process không chết chỉ vì terminal đóng
- output mặc định được ghi vào `nohup.out` nếu không redirect
- thường dùng ngay lúc khởi chạy command

Ví dụ:

```bash
nohup sleep 300 > sleep.log 2>&1 &
```

Khi nào dùng:

- chạy script nhanh từ terminal và muốn nó sống tiếp sau logout
- không cần thay đổi session
- chỉ cần chống mất terminal

### `disown`

`disown` là built-in của shell, thường là Bash. Nó gỡ job ra khỏi danh sách job control của shell.

Kết quả:

- shell không còn theo dõi job đó nữa
- shell sẽ không gửi `SIGHUP` cho job khi thoát
- process vẫn chạy, nhưng không nhất thiết đã được “cách ly” khỏi terminal như `setsid`

Nó thường được dùng khi process đã chạy rồi.

Ví dụ:

```bash
sleep 300 &
disown
```

Khi nào dùng:

- bạn đã lỡ chạy background job trước
- muốn shell quên job đó đi
- không muốn restart lại command bằng `nohup`

### `setsid`

`setsid` tạo một session mới cho process.

Kết quả:

- process không còn controlling terminal cũ
- process trở thành session leader mới
- ít phụ thuộc vào shell hơn `nohup` và `disown`

Ví dụ:

```bash
setsid sleep 300
```

Khi nào dùng:

- cần tách hẳn process khỏi terminal
- cần tạo môi trường chạy kiểu daemon
- muốn process không thuộc session cũ

### So sánh ngắn

| Công cụ | Bỏ qua `SIGHUP` | Tạo session mới | Dùng ở thời điểm |
|---------|------------------|-----------------|------------------|
| `nohup` | Có | Không | Lúc khởi chạy |
| `disown` | Gián tiếp, qua shell | Không | Sau khi process đã chạy |
| `setsid` | Có, vì tách khỏi terminal cũ | Có | Lúc khởi chạy |

### Chọn cái nào?

- cần chạy nhanh, đơn giản: dùng `nohup`
- cần shell ngừng quản lý job đang chạy: dùng `disown`
- cần tách process thành session mới: dùng `setsid`

## 3. Khi nào dùng `pkill -f`

Mặc định, `pkill` so khớp theo tên process/executable. Điều đó chưa đủ nếu nhiều process có cùng tên binary nhưng khác command line.

`-f` khiến `pkill` so khớp theo toàn bộ command line, không chỉ tên executable.

Ví dụ:

```bash
python app.py --port 8000
python app.py --port 9000
```

Nếu chạy:

```bash
pkill python
```

thì có thể kill tất cả process tên `python`, kể cả process không liên quan trực tiếp tới script bạn muốn dừng.

Nếu chạy:

```bash
pkill -f "app.py --port 8000"
```

thì bạn nhắm đúng command line cụ thể hơn.

### Khi nên dùng `-f`

- cần kill process theo tham số chạy
- nhiều instance cùng executable nhưng khác mục đích
- Java, Python, Node, shell script, wrapper script
- command không hiện rõ trong tên binary

Ví dụ thường gặp:

```bash
pkill -f "java.*spring"
pkill -f "gunicorn.*:8000"
pkill -f "python.*manage.py runserver"
```

### Cẩn thận với `-f`

`-f` match rộng hơn nên dễ kill nhầm nếu pattern quá chung.

Nên kiểm tra trước bằng:

```bash
pgrep -af "pattern"
```

Sau đó mới dùng `pkill -f` khi chắc chắn pattern đúng.

## 4. Đọc output `ps auxf` — giải thích cột `STAT`

`ps auxf` cho bạn danh sách process theo dạng cây, giúp nhìn quan hệ cha-con rõ hơn. Trong output, cột `STAT` mô tả trạng thái hiện tại của process.

### Các trạng thái chính

| Ký tự | Tên | Ý nghĩa |
|-------|-----|---------|
| `R` | Running | Process đang chạy hoặc sẵn sàng chạy trên CPU |
| `S` | Sleeping | Đang ngủ, chờ một sự kiện có thể interrupt |
| `D` | Uninterruptible sleep | Đang chờ I/O hoặc kernel resource, khó/không thể bị ngắt ngay |
| `T` | Stopped | Process đã bị dừng bởi signal hoặc debugger |
| `Z` | Zombie | Process đã kết thúc nhưng parent chưa thu hồi exit status |

### Ý nghĩa thực tế từng trạng thái

#### `R` - Running

Process đang thực sự được chạy trên CPU hoặc đang chờ được scheduler cấp CPU.

Đây là trạng thái bình thường của chương trình đang hoạt động.

#### `S` - Sleeping

Process đang chờ sự kiện, ví dụ:

- chờ input
- chờ network
- chờ timer

Đây cũng là trạng thái phổ biến và không có gì bất thường.

#### `D` - Uninterruptible sleep

Process đang chờ kernel hoặc I/O subsystem, thường gặp khi đọc/ghi disk, NFS, device, hoặc một tài nguyên hệ thống bị nghẽn.

Điểm đáng chú ý:

- signal thường chưa xử lý ngay được
- process có thể “treo” nhìn như không phản hồi
- nếu `D` kéo dài, cần kiểm tra I/O hoặc kernel issue

#### `T` - Stopped

Process bị dừng tạm thời, ví dụ bởi:

- `Ctrl+Z`
- `SIGSTOP`
- debugger

Process vẫn còn đó nhưng không chạy.

#### `Z` - Zombie

Process đã chết nhưng vẫn còn entry trong bảng process vì parent chưa gọi `wait()` hoặc `waitpid()`.

Zombie không còn thực thi, nhưng vẫn giữ PID và exit status cho parent đọc.

### Ký tự phụ trong `STAT`

Ngoài chữ cái chính, `STAT` có thể kèm thêm ký tự phụ như:

- `s`: session leader
- `+`: foreground process group
- `l`: multi-threaded
- `<`: ưu tiên cao
- `N`: ưu tiên thấp

Ví dụ `Ss+` có thể hiểu là process đang sleeping, là session leader, và thuộc foreground process group.

## 5. Zombie process là gì, làm sao nhận diện?

Zombie process là process đã kết thúc, nhưng parent process chưa đọc trạng thái thoát của nó bằng `wait()` hoặc `waitpid()`.

### Bản chất

Zombie không phải process đang chạy sai.

Nó chỉ là một mục còn sót lại trong process table để lưu:

- PID
- exit code
- một vài thông tin thống kê tối thiểu

Zombie hầu như không dùng CPU và RAM rất nhỏ, nhưng nếu tạo quá nhiều thì có thể làm đầy process table.

### Dấu hiệu nhận diện

Bạn có thể dùng:

```bash
ps aux
```

hoặc:

```bash
ps auxf
```

hoặc:

```bash
ps -el
```

Nếu cột `STAT` có `Z` thì process đó là zombie.

Ví dụ:

```text
PID  PPID STAT CMD
1234 1000 Z    myprogram
```

### Vì sao zombie xuất hiện?

Zombie thường xuất hiện khi:

- parent không gọi `wait()` sau khi child thoát
- parent bị bug trong xử lý child process
- chương trình spawn nhiều process con nhưng không thu dọn

### Có kill zombie được không?

Không trực tiếp.

Vì zombie đã chết rồi nên `kill -9` không giải quyết được. Cách đúng là:

- sửa parent để gọi `wait()` hoặc `waitpid()`
- restart hoặc kill parent process để PID 1/systemd nhận nuôi và thu hồi zombie

### Cách xử lý thực tế

1. Xác định PID của parent bằng cột `PPID`.
2. Kiểm tra ứng dụng có bug quản lý child không.
3. Nếu cần xử lý nhanh, restart parent process.
4. Nếu zombie tồn tại do service lỗi, xem log và sửa code quản lý tiến trình con.

### Kết luận ngắn

- `SIGTERM` là dừng an toàn
- `SIGKILL` là buộc dừng
- `SIGHUP` thường để reload hoặc báo mất terminal
- `SIGINT` là ngắt từ bàn phím
- `nohup`, `disown`, `setsid` đều giúp process sống sau khi đóng terminal nhưng ở mức khác nhau
- `pkill -f` hữu ích khi cần match theo toàn bộ command line
- `STAT` trong `ps` cho biết trạng thái tiến trình
- zombie là process đã chết nhưng parent chưa thu hồi