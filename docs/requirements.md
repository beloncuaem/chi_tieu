# Yêu cầu và phạm vi dự án Chi Tiêu

## 1. Mục tiêu

Xây dựng ứng dụng di động giúp một cá nhân ghi nhận, phân loại và theo dõi chi tiêu hằng ngày. Mỗi khoản chi có thể đính kèm ảnh để lưu hóa đơn hoặc ngữ cảnh của giao dịch. Ứng dụng ưu tiên dùng được khi không có mạng và lưu dữ liệu ngay trên thiết bị.

## 2. Người dùng

Người dùng cá nhân muốn kiểm soát chi tiêu bằng đồng Việt Nam (VND), theo ngày/tháng và theo nhóm nhu cầu.

## 3. Yêu cầu chức năng

| Mã | Yêu cầu | Trạng thái trong mã nguồn |
| --- | --- | --- |
| FR-01 | Chụp ảnh bằng camera hoặc chọn ảnh từ thư viện. | Đã có màn Camera và chọn ảnh. |
| FR-02 | Tạo khoản chi gồm ảnh, mô tả, số tiền, danh mục, mức độ cần thiết và thời điểm tạo. | Đã có. |
| FR-03 | Phân loại độ cần thiết: Thiết yếu, Rất cần, Cần vừa, Chưa cần. | Đã có. |
| FR-04 | Hiển thị tổng chi hôm nay và danh sách khoản chi; cho phép xóa khoản chi. | Đã có. |
| FR-05 | Quản lý danh mục: có danh mục mặc định, thêm và xóa danh mục tùy chỉnh. | Đã có giao diện và tầng dữ liệu. |
| FR-06 | Thiết lập ngân sách tổng tháng hoặc ngân sách theo từng danh mục; hiển thị tiến độ sử dụng. | Đã có. |
| FR-07 | Thống kê theo hôm nay, tuần này, tháng này, năm nay hoặc một khoảng ngày tự chọn. | Đã có. |
| FR-08 | Trực quan hóa chi tiêu theo danh mục và mức độ cần thiết; tạo nhận xét tổng quan. | Đã có. |
| FR-09 | Chuyển giữa giao diện sáng và tối. | Đã có provider và màn Cài đặt, nhưng Cài đặt chưa được liên kết vào điều hướng chính. |

## 4. Quy tắc dữ liệu

- Mỗi khoản chi phải có mô tả, số tiền, danh mục và thời điểm tạo.
- Khoản chi có thể có hoặc không có đường dẫn ảnh cục bộ.
- Danh mục mặc định được tạo ở lần khởi tạo cơ sở dữ liệu đầu tiên và không được xóa.
- Ngân sách được lưu theo tháng ở định dạng `yyyy-MM`; có thể là ngân sách tổng hoặc thuộc một danh mục.
- Tiền tệ hiển thị theo định dạng Việt Nam (VND).

## 5. Yêu cầu phi chức năng

- Ứng dụng hoạt động cục bộ, không yêu cầu tài khoản hay kết nối mạng cho các chức năng hiện có.
- Dữ liệu được lưu trong SQLite trên thiết bị.
- Ảnh được sao chép vào thư mục tài liệu của ứng dụng trước khi lưu đường dẫn.
- Giao diện dùng Material 3, hỗ trợ chế độ sáng/tối.

## 6. Phạm vi chưa được triển khai

- Nhận diện hóa đơn hoặc OCR; ảnh hiện chỉ là tệp đính kèm.
- Đăng nhập, đồng bộ nhiều thiết bị, sao lưu/khôi phục dữ liệu.
- Chỉnh sửa một khoản chi đã tạo.
- Thông báo ngân sách; package thông báo cục bộ đã khai báo nhưng chưa được sử dụng.
- Xuất báo cáo CSV/PDF hoặc chia sẻ dữ liệu.

## 7. Điểm cần hoàn thiện trước khi phát hành

1. Bổ sung `createdAt` khi tạo `Category`; hiện model yêu cầu trường này nhưng luồng thêm danh mục và test chưa truyền giá trị.
2. Khai báo quyền camera/thư viện ảnh cho Android và mô tả quyền tương ứng trên iOS.
3. Liên kết màn Cài đặt vào điều hướng để người dùng quản lý danh mục và đổi giao diện.
4. Bảo vệ tính toàn vẹn dữ liệu khi xóa danh mục đã được dùng bởi khoản chi hoặc ngân sách.
5. Làm mới dữ liệu ngân sách và thống kê ngay sau khi thêm/xóa khoản chi.
6. Xác nhận nền tảng mục tiêu. Dự án có runner Windows nhưng camera và SQLite hiện được xây dựng chủ yếu cho luồng Android/iOS.
