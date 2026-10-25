# Yêu cầu và phạm vi dự án Chi Tiêu (v2.1)

> Cập nhật: 2026-10-26.

## 1. Mục tiêu

Ứng dụng di động giúp một cá nhân ghi nhận, phân loại và theo dõi chi tiêu hằng ngày.
Mỗi khoản chi có thể đính kèm ảnh hóa đơn; ảnh được hiển thị thành nhật ký dạng lướt
giống Locket. Ứng dụng hoạt động được khi không có mạng và đồng bộ lên Supabase khi
người dùng đăng nhập.

## 2. Người dùng

Người dùng cá nhân theo dõi chi tiêu bằng VND theo ngày/tuần/tháng/năm, phân loại theo
danh mục và mức độ cần thiết. Người dùng có thể dùng chế độ khách (không đồng bộ) hoặc
đăng nhập email/Google để đồng bộ đám mây.

## 3. Yêu cầu chức năng

| Mã | Yêu cầu | Trạng thái |
| --- | --- | --- |
| FR-01 | Chụp ảnh bằng camera hoặc chọn ảnh từ thư viện. | Đã có |
| FR-02 | Tạo khoản chi gồm ảnh, mô tả, số tiền, danh mục, mức độ cần thiết, thời điểm. | Đã có |
| FR-03 | Phân loại độ cần thiết: Thiết yếu, Rất cần, Cần vừa, Chưa cần. | Đã có |
| FR-04 | Hiển thị tổng chi hôm nay/tuần/tháng và danh sách khoản chi; xóa mềm. | Đã có |
| FR-05 | Quản lý danh mục: mặc định, thêm và xóa danh mục tùy chỉnh. | Đã có |
| FR-06 | Ngân sách tổng hoặc theo danh mục; hiển thị tiến độ sử dụng. | Đã có |
| FR-07 | Thống kê theo ngày/tuần/tháng/năm/khoảng ngày tự chọn. | Đã có |
| FR-08 | Biểu đồ theo danh mục và mức độ cần thiết; nhận xét tổng quan. | Đã có |
| FR-09 | Chuyển giao diện sáng/tối. | Đã có |
| FR-10 | Nhật ký ảnh kiểu Locket: trang camera đầu tiên, lướt dọc xem ảnh đã chụp. | Đã có |
| FR-11 | Điều hướng bằng nút 3 gạch + drawer, không dùng thanh tab đáy. | Đã có |
| FR-12 | Đăng nhập/đăng ký email & mật khẩu qua Supabase Auth. | Đã có |
| FR-13 | Đăng nhập Google OAuth qua trình duyệt, quay về app bằng deep link. | Đã có, phụ thuộc cấu hình Supabase/Google Cloud |
| FR-14 | Chế độ khách ngoại tuyến, không yêu cầu tài khoản. | Đã có |
| FR-15 | Đồng bộ dữ liệu local lên cloud sau khi đăng nhập. | Đã có |
| FR-16 | Lưu ảnh hóa đơn lên Supabase Storage và hiển thị lại từ cloud. | Đã có |
| FR-17 | Khôi phục khoản chi từ thùng rác. | Đã có |
| FR-18 | Kiểm tra Google provider trước khi mở trình duyệt để báo lỗi rõ ràng. | Đã có |

## 4. Quy tắc dữ liệu

- Mỗi khoản chi phải có mô tả, số tiền, danh mục và thời điểm tạo.
- Khoản chi có thể có hoặc không có ảnh.
- Danh mục mặc định được tạo ở lần khởi tạo SQLite đầu tiên và không được xóa.
- Ngân sách lưu theo tháng `yyyy-MM`; có thể là ngân sách tổng hoặc theo danh mục.
- Xóa khoản chi là xóa mềm (`deleted_at`); dữ liệu vẫn phục hồi được từ thùng rác.
- Tiền tệ hiển thị theo định dạng Việt Nam (VND).
- Dữ liệu cloud được bảo vệ bởi Row Level Security theo `user_id`.

## 5. Yêu cầu phi chức năng

- Hoạt động ngoại tuyến với SQLite; không bắt buộc đăng nhập.
- Khi đăng nhập, ưu tiên đọc/ghi Supabase; lỗi cloud tự fallback SQLite.
- Giao diện Material 3, hỗ trợ sáng/tối, phông Be Vietnam Pro.
- Ảnh được nén trước khi upload để giảm dung lượng.
- Không đưa khóa bí mật vào mã nguồn; chỉ dùng `SUPABASE_URL` và anon/publishable key từ `.env`.
- Deep link OAuth: scheme `io.supabase.chitieu`, host `login-callback`.
- Mọi thay đổi phải chạy `flutter analyze` và `flutter test` trước khi bàn giao.

## 6. Phạm vi chưa triển khai

- OCR/nhận diện hóa đơn; ảnh chỉ là tệp đính kèm.
- Đồng bộ hai chiều tự động theo thời gian thực và xử lý xung đột nâng cao.
- Chỉnh sửa khoản chi đã tạo (hiện có sửa ảnh/caption ở một số luồng, chưa có form đầy đủ).
- Thông báo ngân sách: package đã khai báo nhưng chưa nối vào luồng cảnh báo.
- Xuất báo cáo CSV/PDF hoặc chia sẻ dữ liệu.
- Đăng nhập Apple/Facebook và các provider OAuth khác.

## 7. Điều kiện cấu hình bên ngoài

- Bật **Email** provider (mặc định) trong Supabase Authentication → Providers.
- Muốn dùng Google: bật **Google** provider, cấu hình Client ID/Secret từ Google Cloud
  và allowlist redirect URL. Xem `docs/google-oauth-troubleshooting.md`.
- Nếu bật "Confirm email", người dùng đăng ký phải xác nhận email trước khi đăng nhập.
- Chạy `supabase_setup.sql` để tạo bảng, RLS và bucket `expense-receipts`.

## 8. Tiêu chí nghiệm thu đã xác minh

- `flutter analyze`: không có lỗi biên dịch (chỉ còn info deprecation).
- `flutter test`: 69/69 bài pass.
- Emulator Android API 35:
  - Onboarding và cấp quyền camera/thông báo hoạt động.
  - Đăng nhập email sai hiển thị "Email hoặc mật khẩu không chính xác." từ Supabase,
    chứng minh app kết nối được backend.
  - Chế độ ngoại tuyến vào được feed.
  - Feed Locket, nút 3 gạch, drawer và 4 khu vực điều hướng hiển thị đúng.
  - Google OAuth bị chặn bởi cấu hình provider (`external.google = false`) và nay được
    app báo rõ trước khi mở trình duyệt.
