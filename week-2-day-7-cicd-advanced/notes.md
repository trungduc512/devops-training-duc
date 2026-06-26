# Part E — Failure Scenarios

## 1. Khi pipeline thất bại ở step push, làm sao retry nhanh không build lại?
Khi step push (đẩy image lên Registry) bị lỗi (thường do đứt mạng, lỗi xác thực token, hoặc registry bị timeout), nếu chạy lại từ đầu sẽ rất tốn thời gian build code. Có 2 cách để xử lý:

* **Sử dụng tính năng "Re-run failed jobs" của GitHub Actions:** Thay vì chạy lại toàn bộ workflow (Re-run all jobs), bạn chỉ cần chọn "Re-run failed jobs". Nếu job build và job push được tách riêng, nó sẽ bỏ qua job build đã thành công.
* **Tận dụng Docker Layer Caching (Bộ nhớ đệm):** Nếu bước build và push nằm chung trong một step (như dùng `docker/build-push-action`), bạn bắt buộc phải cấu hình cache (ví dụ: `cache-from: type=gha` và `cache-to: type=gha,mode=max`). Khi bạn re-run job, Docker sẽ kéo lại các layer đã build từ GitHub Cache. Quá trình "build" sẽ mất 0 giây (chỉ hiện *CACHED*) và Action sẽ nhảy thẳng đến bước push bị lỗi trước đó.

## 2. Cách debug 1 job mà chỉ fail trên runner (không tái hiện được ở local)?
Lỗi này cực kỳ phổ biến (thường gọi là lỗi "It works on my machine"). Nguyên nhân do môi trường local (Windows/Mac) khác biệt về hệ điều hành, đường dẫn, quyền user, hoặc múi giờ so với Ubuntu Runner. Để debug, bạn dùng các phương pháp sau:

* **Bật Debug Logging:** Thêm 2 biến Secrets hoặc Variables vào kho lưu trữ với tên `ACTIONS_STEP_DEBUG` và `ACTIONS_RUNNER_DEBUG`, gán giá trị `true`. GitHub sẽ in ra log cực kỳ chi tiết (kể cả các biến môi trường ẩn).
* **Dùng Tmate (SSH vào Runner):** Thêm step `uses: mxschmitt/action-tmate@v3` ngay trước step bị lỗi. Workflow sẽ tạm dừng và cung cấp cho bạn một lệnh SSH. Bạn có thể SSH thẳng vào máy ảo Runner của GitHub để gõ lệnh `ls`, `cat`, kiểm tra file, thư mục và chạy test thủ công y như trên máy mình.
* **Tải Artifacts trung gian về:** Nếu không muốn dùng SSH, hãy dùng `actions/upload-artifact` để nén thư mục build hoặc các file log lỗi ở trên Runner tải về máy local để kiểm tra xem file sinh ra có đúng như kỳ vọng không.

## 3. So sánh `needs`, `if`, và `concurrency` group
Ba từ khóa này có chức năng hoàn toàn khác nhau trong việc điều hướng luồng chạy của CI/CD:

* **`needs` (Thứ tự thực thi):** Dùng để thiết lập *sự phụ thuộc*. Giúp định nghĩa job nào phải chạy trước, job nào chạy sau. 
    * *Ví dụ:* `needs: [lint, test]` nghĩa là job hiện tại chỉ được phép bắt đầu chạy khi cả 2 job lint và test đã báo thành công.
* **`if` (Điều kiện thực thi):** Dùng để thiết lập *logic True/False*. Nó quyết định xem một job hoặc step có được phép chạy hay không dựa trên một điều kiện cụ thể.
    * *Ví dụ:* `if: github.ref == 'refs/heads/main'` (chỉ chạy nếu nhánh là main) hoặc `if: always()` (luôn chạy bất chấp job trước đó bị lỗi).
* **`concurrency` (Kiểm soát chạy song song):** Dùng để *ngăn chặn đụng độ (race conditions)*. Đảm bảo tại một thời điểm chỉ có 1 workflow hoặc 1 job được chạy cho một nhóm nhất định.
    * *Ví dụ:* Bạn push 3 commit liên tiếp lên nhánh `main`. Nếu set `concurrency: production` và `cancel-in-progress: true`, GitHub sẽ tự động hủy 2 luồng đang chạy dở của các commit cũ và chỉ deploy cái code mới nhất, tránh việc 2 luồng cùng deploy lên 1 server gây lỗi.

## 4. Tại sao nên dùng OIDC để auth AWS thay vì static access key?
OIDC (OpenID Connect) hiện nay là **tiêu chuẩn bắt buộc (best practice)** về bảo mật khi kết nối GitHub Actions với bất kỳ Cloud nào (AWS, GCP, Azure), thay thế hoàn toàn cho việc dùng cặp `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` truyền thống. Lý do:

* **Không có Credentials dài hạn (Short-lived tokens):** Static key lưu trong GitHub Secrets nếu bị lộ (do bị hack hoặc vô tình in ra log) thì hacker có quyền truy cập vĩnh viễn cho đến khi bạn xóa key. OIDC cấp một token tạm thời (chỉ sống trong khoảng 15-60 phút) để chạy xong CI/CD rồi tự hủy. Không có key tĩnh nào được tạo ra hay lưu trữ.
* **Không phải quản lý rác (No Secret Management):** Bạn không cần phải nhớ luân chuyển (rotate) key định kỳ hay sợ nhân viên cũ nghỉ việc mang theo key. 
* **Phân quyền cực kỳ chi tiết (Granular Control):** Dựa vào cấu hình Trust Policy trên AWS IAM, bạn có thể khóa chặt quyền truy cập: *Chỉ cho phép tài khoản GitHub của bạn, ở kho lưu trữ cụ thể, và CHỈ được pull code từ nhánh "main"* mới có quyền gọi lên AWS. Nếu ai đó tạo nhánh phụ chạy CI/CD, AWS sẽ từ chối truy cập ngay lập tức.