# 1. High Latency

**Mục tiêu:** phát hiện khi thời gian phản hồi của ứng dụng tăng cao trong một khoảng thời gian đủ dài, dù các request vẫn có thể trả về thành công.

**Điều kiện gợi ý:** p95 latency vượt **500 ms** liên tục trong **10 phút**.

```promql
histogram_quantile(
  0.95,
  sum by (le, service) (
    rate(http_request_duration_seconds_bucket{job="web-app"}[5m])
  )
) > 0.5
```

**Khuyến nghị cấu hình**

* `severity`: `warning`; có thể nâng lên `critical` nếu p95 vượt **1 giây**.
* `for`: `10m` để tránh cảnh báo do các spike ngắn.
* Loại bỏ các endpoint như health check hoặc endpoint nội bộ khỏi phép tính nếu chúng không phản ánh trải nghiệm thực tế của người dùng.

**Khi alert được kích hoạt**

* Phân tích trace của các request chậm.
* Kiểm tra độ trễ của các dependency (database, cache, API bên ngoài).
* Xem xét các truy vấn database và mức sử dụng tài nguyên (CPU, memory, I/O).

---

# 2. High Error Rate

**Mục tiêu:** phát hiện khi tỷ lệ lỗi phía server (HTTP 5xx) tăng lên đáng kể.

**Điều kiện gợi ý:** tỷ lệ lỗi HTTP 5xx vượt **5%** trong **5 phút**, đồng thời lưu lượng truy cập lớn hơn **1 request/giây**.

```promql
(
  sum by (service) (
    rate(http_requests_total{job="web-app",status=~"5.."}[5m])
  )
  /
  sum by (service) (
    rate(http_requests_total{job="web-app"}[5m])
  )
) > 0.05
and on (service)
sum by (service) (
  rate(http_requests_total{job="web-app"}[5m])
) > 1
```

**Khuyến nghị cấu hình**

* `severity`: `critical`
* `for`: `5m`

Điều kiện về lưu lượng giúp loại bỏ các trường hợp có quá ít request. Ví dụ, nếu chỉ có một request và request đó thất bại thì tỷ lệ lỗi sẽ là 100%, nhưng điều này chưa đủ để phản ánh một sự cố nghiêm trọng.

**Khi alert được kích hoạt**

* Kiểm tra deployment hoặc release gần nhất.
* Xem log của các request trả về HTTP 5xx.
* Kiểm tra các dependency có bị lỗi hay không.
* Phân tích trace để xác định nguyên nhân gây lỗi.

---

# 3. Host CPU Saturation

**Mục tiêu:** phát hiện khi máy chủ sử dụng CPU ở mức quá cao trong thời gian dài, có thể làm tăng latency hoặc gây timeout cho ứng dụng.

**Điều kiện gợi ý:** mức sử dụng CPU trung bình vượt **85%** liên tục trong **15 phút**.

```promql
100 * (
  1 - avg by (instance) (
    rate(node_cpu_seconds_total{
      job="node-exporter",
      mode="idle"
    }[5m])
  )
) > 85
```

**Khuyến nghị cấu hình**

* `severity`: `warning`
* Có thể bổ sung một mức `critical` nếu CPU vượt **95%** trong **5 phút**.
* `for`: `15m` nhằm tránh cảnh báo do các workload tăng đột biến trong thời gian ngắn.

**Khi alert được kích hoạt**

* Xác định process hoặc container tiêu thụ CPU nhiều nhất.
* Kiểm tra lưu lượng truy cập hiện tại.
* Đánh giá tình trạng autoscaling hoặc CPU throttling.
* Xem lại các deployment gần đây.

CPU chỉ phản ánh một dạng **resource saturation**. Tùy vào đặc điểm của hệ thống, có thể cần theo dõi thêm các chỉ số như memory pressure, disk I/O, connection pool, request queue hoặc container CPU throttling để có cái nhìn toàn diện hơn.

---

# Alert Noise và Actionable Alert

## Alert Noise

Alert được xem là **noise** khi nó tạo ra thông báo nhưng không mang lại giá trị thực tế cho người trực, hoặc không yêu cầu bất kỳ hành động nào.

Một số ví dụ:

* CPU tăng trên 85% trong vài giây rồi nhanh chóng trở lại bình thường.
* Chỉ có một request thất bại khi lưu lượng gần như bằng không, khiến tỷ lệ lỗi hiển thị là 100%.
* Một sự cố duy nhất nhưng tạo ra hàng loạt alert từ application, pod, node và dependency.
* Alert tự biến mất trước khi người trực có cơ hội điều tra.
* Alert không chỉ rõ owner, dashboard hoặc runbook để xử lý.
* Alert phản ánh một vấn đề kỹ thuật nhưng không ảnh hưởng đến người dùng hoặc SLO.

Nếu hệ thống tạo quá nhiều alert dạng này, đội vận hành dễ rơi vào tình trạng **alert fatigue**, khiến họ phản ứng chậm hoặc bỏ qua cả những cảnh báo thực sự quan trọng.

---

## Actionable Alert

Một alert được xem là **actionable** khi người nhận có thể ngay lập tức hiểu vấn đề và biết cần thực hiện bước tiếp theo.

Một actionable alert nên đáp ứng các tiêu chí sau:

* Phản ánh tác động thực sự đến người dùng hoặc nguy cơ vi phạm SLO.
* Sử dụng ngưỡng (`threshold`) và khoảng `for` hợp lý để giảm cảnh báo giả.
* Xác định rõ owner và mức độ nghiêm trọng (`severity`).
* Cung cấp đầy đủ thông tin như service, môi trường, instance hoặc region bị ảnh hưởng cùng giá trị hiện tại.
* Đính kèm liên kết tới dashboard, log, trace và runbook để hỗ trợ điều tra.
* Đề xuất hành động cụ thể như rollback deployment, scale service, kiểm tra dependency hoặc chuyển hướng traffic.
* Hỗ trợ grouping hoặc inhibition để nhiều alert phát sinh từ cùng một sự cố được gộp lại, tránh gửi quá nhiều thông báo trùng lặp.
