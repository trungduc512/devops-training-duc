# Observability: Log, Metric, Trace và các khái niệm liên quan

## 1. Log, Metric và Trace

| Loại dữ liệu | Trả lời câu hỏi                             | Đặc điểm                                                                                                              | Ví dụ                                                                                       |
| ------------ | ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| **Log**      | Điều gì đã xảy ra?                          | Ghi lại một sự kiện tại một thời điểm cụ thể, kèm timestamp và thông tin chi tiết                                     | `2026-06-27T10:15:02Z ERROR payment failed order_id=123 reason=timeout`                     |
| **Metric**   | Hệ thống đang hoạt động ra sao?             | Dữ liệu được tổng hợp theo thời gian, phù hợp để xây dựng dashboard, cảnh báo và theo dõi xu hướng                    | `http_requests_total{service="checkout",status="500"} 42`                                   |
| **Trace**    | Một request đã đi qua những thành phần nào? | Mô tả toàn bộ hành trình của một request xuyên suốt nhiều service, trong đó mỗi bước được biểu diễn bằng một **span** | Request đi qua `API Gateway → Checkout → Payment → Database`, span của Payment mất 2,1 giây |

### Ví dụ

Giả sử người dùng thực hiện thanh toán nhưng nhận về mã lỗi **HTTP 500**.

* **Metric** phát hiện tỷ lệ lỗi của service `checkout` tăng từ **0,2%** lên **8%**, từ đó kích hoạt alert.
* **Trace** cho thấy phần lớn thời gian xử lý nằm ở span gọi tới `payment-service`.
* **Log** của `payment-service` ghi nhận lỗi timeout khi kết nối đến hệ thống ngân hàng.

Ba loại dữ liệu này bổ sung cho nhau:

* **Metric** giúp phát hiện vấn đề.
* **Trace** giúp xác định khu vực xảy ra sự cố.
* **Log** cung cấp thông tin chi tiết để tìm nguyên nhân gốc.

---

## 2. Pull-based và Push-based

### Pull-based (ví dụ: Prometheus)

Trong mô hình pull, Prometheus chủ động truy cập endpoint `/metrics` của từng target theo chu kỳ để thu thập dữ liệu.

```text
Prometheus --scrape /metrics--> Application
```

### Ưu điểm

* Prometheus kiểm soát tập trung chu kỳ scrape, timeout và danh sách target.
* Có thể dễ dàng phát hiện target không còn hoạt động thông qua metric `up = 0`.
* Application không cần biết địa chỉ của hệ thống monitoring.
* Có thể kiểm tra trực tiếp endpoint `/metrics` để debug.
* Hỗ trợ service discovery để tự động tìm và theo dõi target mới.

### Nhược điểm

* Prometheus phải truy cập được tới tất cả target, điều này khó khăn hơn nếu target nằm sau firewall, NAT hoặc ở nhiều mạng khác nhau.
* Batch job hoặc workload có vòng đời rất ngắn có thể kết thúc trước lần scrape tiếp theo, dẫn đến mất dữ liệu.
* Mỗi target đều phải cung cấp endpoint `/metrics`.

> Đối với các batch job ngắn hạn, Prometheus cung cấp **Pushgateway**. Tuy nhiên đây chỉ là giải pháp cho trường hợp đặc biệt, không làm thay đổi bản chất pull-based của Prometheus.

---

### Push-based (ví dụ: StatsD và OpenTelemetry Collector)

Trong mô hình push, application hoặc agent chủ động gửi telemetry tới collector hoặc backend.

```text
Application --push--> StatsD / OpenTelemetry Collector
```

* Với **StatsD**, metric thường được gửi qua giao thức UDP.
* Với **OpenTelemetry**, SDK hoặc agent gửi telemetry qua giao thức OTLP tới Collector. Collector sẽ xử lý rồi chuyển tiếp tới backend. Ngoài ra, Collector cũng có thể scrape Prometheus nên không chỉ hỗ trợ cơ chế push.

### Ưu điểm

* Phù hợp với batch job, serverless và các workload có vòng đời ngắn.
* Application chỉ cần kết nối ra collector mà không cần mở cổng để monitoring system truy cập vào.
* Collector có thể thực hiện buffer, batch, retry, lọc hoặc chuyển đổi dữ liệu trước khi gửi đi.
* Có thể triển khai collector gần application nhằm giảm số lượng kết nối trực tiếp tới backend.

### Nhược điểm

* Collector hoặc backend có thể bị quá tải nếu nhiều client cùng gửi dữ liệu trong thời gian ngắn; cần cơ chế queue, rate limit và backpressure.
* Khó phân biệt giữa trường hợp "không có dữ liệu" và "client đã chết" nếu không triển khai heartbeat.
* Client cần biết địa chỉ collector hoặc có cơ chế discovery phù hợp.
* Với StatsD, việc sử dụng UDP đồng nghĩa với việc packet có thể bị mất mà client không nhận biết.
* Buffer và retry giúp tăng độ tin cậy nhưng cũng làm hệ thống vận hành phức tạp hơn, đồng thời vẫn có nguy cơ mất dữ liệu nếu queue đầy.

### So sánh

| Tiêu chí                    | Pull                              | Push                                      |
| --------------------------- | --------------------------------- | ----------------------------------------- |
| Bên khởi tạo kết nối        | Monitoring system                 | Application hoặc agent                    |
| Workload ngắn hạn           | Có thể bỏ lỡ dữ liệu              | Phù hợp hơn                               |
| Phát hiện target chết       | Thông qua scrape failure          | Cần heartbeat hoặc cơ chế riêng           |
| Kiểm soát tần suất thu thập | Do monitoring server quyết định   | Phụ thuộc client hoặc collector           |
| Khả năng quá tải receiver   | Dễ kiểm soát bằng scrape interval | Dễ xảy ra burst khi nhiều client cùng gửi |

---

## 3. SLI, SLO và SLA

* **SLI (Service Level Indicator):** chỉ số dùng để đo chất lượng thực tế của dịch vụ, chẳng hạn availability, latency hoặc error rate.
* **SLO (Service Level Objective):** mục tiêu nội bộ mà hệ thống cần đạt đối với một hoặc nhiều SLI trong khoảng thời gian xác định.
* **SLA (Service Level Agreement):** cam kết chính thức với khách hàng về chất lượng dịch vụ, thường đi kèm điều khoản bồi thường nếu không đạt.

### Ví dụ

Đối với một API thanh toán:

* **SLI:** tỷ lệ request thành công trong 30 ngày.

```text id="9l04jy"
SLI = số request HTTP 2xx / tổng số request hợp lệ × 100%
```

* **SLO:** tối thiểu **99,95%** request phải thành công trong mỗi chu kỳ 30 ngày.
* **SLA:** cam kết với khách hàng đạt **99,9%** mỗi tháng; nếu không đáp ứng sẽ áp dụng service credit hoặc hình thức bồi thường khác.

Thông thường, doanh nghiệp đặt **SLO** cao hơn **SLA** để tạo khoảng an toàn trước khi vi phạm cam kết với khách hàng.

---

## 4. Cardinality Explosion

**Cardinality** là số lượng tổ hợp label khác nhau của một metric. Mỗi tổ hợp label sẽ tạo ra một **time series** riêng.

Ví dụ:

```text id="qxtvjv"
http_requests_total{
  method="GET",
  status="200",
  user_id="u-123456",
  path="/orders/987654"
}
```

Giả sử hệ thống có:

* 5 giá trị của `method`
* 10 giá trị của `status`
* 1.000.000 giá trị khác nhau của `user_id`
* 1.000.000 đường dẫn chứa ID động

Khi đó số lượng time series có thể tăng lên cực lớn. Việc sử dụng các label có số lượng giá trị gần như không giới hạn như `user_id`, `request_id`, `order_id`, UUID, timestamp hoặc URL chưa chuẩn hóa được gọi là **cardinality explosion**.

### Hậu quả

* Tiêu tốn nhiều RAM và dung lượng lưu trữ.
* Query và dashboard phản hồi chậm hoặc bị timeout.
* Tăng đáng kể chi phí cho hệ thống monitoring.
* Quá trình scrape hoặc ingest dữ liệu có thể bị chậm hoặc bị từ chối.
* Prometheus có nguy cơ hết bộ nhớ (OOM) và restart, làm mất khả năng quan sát khi xảy ra sự cố.
* Alert có thể bị đánh giá chậm hoặc không được kích hoạt đúng thời điểm.

### Cách hạn chế

* Chỉ sử dụng các label có số lượng giá trị nhỏ và ổn định, chẳng hạn `method`, `status_code`, `region` hoặc `service`.
* Không đưa các giá trị như `user_id`, `request_id`, `order_id`, UUID hoặc thông báo lỗi tự do vào label; những thông tin này nên được lưu trong log hoặc trace.
* Chuẩn hóa route, ví dụ sử dụng `/orders/:id` thay vì `/orders/987654`.
* Loại bỏ hoặc giới hạn các label không cần thiết tại application, collector hoặc thông qua Prometheus relabeling.
* Theo dõi số lượng active time series và thiết lập cảnh báo khi số lượng series tăng bất thường.
