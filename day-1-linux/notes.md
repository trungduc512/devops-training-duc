# Lệnh
ls — ví dụ: ls -la — Liệt kê file/thư mục (tên, quyền, kích thước, thời gian).

cd — ví dụ: cd /tmp — Thay đổi thư mục làm việc.

pwd — ví dụ: pwd — Hiển thị đường dẫn thư mục hiện tại.

mkdir — ví dụ: mkdir -p a/b — Tạo thư mục; `-p` tạo luôn thư mục cha.

rm — ví dụ: rm -i file — Xóa file; `-r` cho thư mục, `-i` hỏi trước.

cp — ví dụ: cp -r src dest — Sao chép file/thư mục; `-r` đệ quy.

mv — ví dụ: mv a b — Di chuyển hoặc đổi tên file/thư mục.

touch — ví dụ: touch f — Tạo file rỗng hoặc cập nhật timestamp.

cat — ví dụ: cat f — Hiển thị nội dung file ra stdout.

less — ví dụ: less f — Xem file theo trang, hỗ trợ tìm kiếm.

head — ví dụ: head -n5 f — Hiển thị 5 dòng đầu của file.

tail — ví dụ: tail -n5 f — Hiển thị 5 dòng cuối; `-f` theo dõi log.

grep — ví dụ: grep -n foo f — Tìm pattern trong file; `-n` in số dòng.

find — ví dụ: find . -name "*.sh" — Tìm file/dir theo điều kiện.

xargs — ví dụ: echo a b | xargs rm — Chuyển stdin thành args cho lệnh khác.

awk — ví dụ: awk '{print $1}' f — Xử lý và trích xuất cột văn bản.

sed — ví dụ: sed 's/a/b/g' f — Thay thế hoặc lọc dòng theo pattern.

sort — ví dụ: sort f — Sắp xếp các dòng.

uniq — ví dụ: sort f | uniq -c — Gom trùng và đếm.

wc — ví dụ: wc -l f — Đếm dòng/từ/ký tự.

tee — ví dụ: cmd | tee out.txt — Ghi output vào file và in ra stdout.

ps — ví dụ: ps aux — Liệt kê tiến trình đang chạy.

top — ví dụ: top — Giám sát tiến trình theo thời gian thực.

htop — ví dụ: htop — Giao diện tương tác cho top (nâng cao).

kill — ví dụ: kill PID — Gửi tín hiệu tới tiến trình theo PID.

nice — ví dụ: nice -n10 cmd — Chạy lệnh với độ ưu tiên thấp hơn.

df — ví dụ: df -h — Hiển thị dung lượng đĩa (human-readable).

du — ví dụ: du -sh dir — Hiển thị kích thước thư mục/tệp.

free — ví dụ: free -m — Hiển thị lượng RAM và swap còn/từng dùng.

uptime — ví dụ: uptime — Hiển thị thời gian chạy và load average.

uname — ví dụ: uname -r — Hiển thị phiên bản kernel.

who — ví dụ: who — Liệt kê người dùng đang đăng nhập.

chmod — ví dụ: chmod 644 f — Thay đổi quyền truy cập file.

chown — ví dụ: chown user:group f — Thay đổi chủ sở hữu và nhóm.

umask — ví dụ: umask 022 — Thiết lập mặt nạ quyền mặc định cho file mới.

tar — ví dụ: tar -czvf a.tar.gz dir — Đóng gói và nén thư mục.

gzip — ví dụ: gzip f — Nén file (tạo f.gz).

zip — ví dụ: zip -r a.zip dir — Tạo file zip.

unzip — ví dụ: unzip a.zip -d out — Giải nén zip.

ssh — ví dụ: ssh user@host — Kết nối shell tới máy từ xa qua SSH.

scp — ví dụ: scp f user@host:/tmp — Sao chép file qua SSH.

rsync — ví dụ: rsync -av src dest — Đồng bộ thư mục hiệu quả.

ln — ví dụ: ln target link — Tạo hard link (cùng inode).

ln -s — ví dụ: ln -s target link — Tạo symbolic link (symlink).

env — ví dụ: env — Hiển thị biến môi trường.

export — ví dụ: export X=1 — Đặt biến môi trường cho shell hiện tại.

source — ví dụ: source ~/.bashrc — Nạp file vào shell hiện tại.

curl — ví dụ: curl -sI https://example.com — Lấy header HTTP.

wget — ví dụ: wget https://example.com/file — Tải file từ web.

which — ví dụ: which cmd — Hiển thị đường dẫn executable trong PATH.

whereis — ví dụ: whereis cmd — Tìm binary và man page liên quan.

type — ví dụ: type ls — Kiểm tra alias/builtin/executable.

history — ví dụ: history — Hiển thị lịch sử lệnh.

alias — ví dụ: alias ll='ls -la' — Tạo bí danh lệnh.

echo — ví dụ: echo hi — In chuỗi ra stdout.

printf — ví dụ: printf "%s\n" hi — In theo định dạng chính xác.
