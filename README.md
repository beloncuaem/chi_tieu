# Chi Tiêu

Ứng dụng Flutter quản lý chi tiêu cá nhân theo hướng **offline-first**. Người dùng lưu một khoản chi kèm ảnh hóa đơn hoặc ảnh minh họa, sau đó theo dõi tổng chi, ngân sách và thống kê trực quan ngay trên thiết bị.

## Chức năng hiện có

- Chụp ảnh bằng camera hoặc chọn ảnh từ thư viện để tạo khoản chi.
- Lưu mô tả, số tiền, danh mục, mức độ cần thiết và thời điểm chi.
- Xem tổng chi hôm nay, danh sách khoản chi gần đây và xóa khoản chi bằng thao tác vuốt.
- Xem thống kê theo hôm nay, tuần, tháng, năm hoặc khoảng ngày tùy chọn; có biểu đồ danh mục và mức độ cần thiết.
- Thiết lập ngân sách tổng hoặc ngân sách theo danh mục cho tháng hiện tại.
- Thêm hoặc xóa danh mục tùy chỉnh; danh mục mặc định không thể xóa.
- Hỗ trợ giao diện sáng/tối trong phần cài đặt.

## Công nghệ

- Flutter / Dart (`sdk: ^3.13.5`)
- Riverpod để quản lý trạng thái
- SQLite (`sqflite`) để lưu dữ liệu cục bộ
- `camera` và `image_picker` để lấy ảnh
- `fl_chart` cho biểu đồ
- `intl` để định dạng ngày và tiền tệ Việt Nam

## Tài liệu

- [Yêu cầu và phạm vi dự án](docs/requirements.md)
- [Cấu trúc dự án](docs/project-structure.md)

## Chạy dự án

1. Cài Flutter SDK tương thích với Dart 3.13.5 hoặc mới hơn.
2. Tại thư mục này, cài dependencies:

   ```bash
   flutter pub get
   ```

3. Chạy trên thiết bị hoặc giả lập:

   ```bash
   flutter run
   ```

4. Kiểm tra mã nguồn và test:

   ```bash
   flutter analyze
   flutter test
   ```

## Lưu ý phát triển

- Dữ liệu và đường dẫn ảnh được lưu cục bộ trong SQLite; ứng dụng chưa có đăng nhập, đồng bộ đám mây hay sao lưu/khôi phục.
- Màn hình mở đầu là tab **Chụp**. Các tab còn lại là **Tổng quan**, **Thống kê** và **Ngân sách**.
- Trước khi chạy trên thiết bị thật, cần hoàn thiện quyền camera/thư viện ảnh trong cấu hình Android và iOS. Chi tiết các điểm cần hoàn thiện nằm trong tài liệu yêu cầu.

## Giấy phép

Chưa xác định giấy phép phát hành.
