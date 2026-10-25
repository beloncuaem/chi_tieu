<p align="center">
  <img src="https://raw.githubusercontent.com/beloncuaem/chi_tieu/main/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="96" height="96" alt="Chi Tiêu Logo" />
</p>

<h1 align="center">Chi Tiêu — Locket Expense Journal</h1>

<p align="center">
  <b>Nhật ký chi tiêu bằng ảnh kiểu Locket, giao diện Fintech hiện đại, đồng bộ Supabase (Auth, PostgreSQL RLS, Storage) và hoạt động ngoại tuyến với SQLite.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-Cloud%20Database-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/State-Riverpod%202.6-blue" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Database-PostgreSQL%20%7C%20SQLite-4169E1" alt="PostgreSQL SQLite" />
  <img src="https://img.shields.io/badge/Tests-69%20Passed%20(100%25)-success" alt="Tests" />
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License" />
</p>

---

## 🌟 Giới thiệu

**Chi Tiêu** là ứng dụng quản lý tài chính cá nhân với trải nghiệm **nhật ký ảnh**:
mở app là camera, chụp hóa đơn hoặc khoảnh khắc chi tiêu, rồi lướt dọc để xem lại
từng khoản chi như một dòng thời gian. Điều hướng chính dùng nút **3 gạch** ở góc trên
trái thay cho thanh tab đáy.

Dữ liệu được ưu tiên lưu trên **Supabase** khi đã đăng nhập và tự động fallback về
**SQLite** khi ngoại tuyến hoặc chưa cấu hình cloud.

---

## 🚀 Tính năng nổi bật

### 1. 📸 Nhật ký ảnh kiểu Locket
- Trang đầu tiên là **camera trực tiếp** với nút chụp, thư viện, đổi camera và nhập nhanh.
- Vuốt dọc để xem lần lượt các khoản chi có ảnh, **mới nhất trước**.
- Ảnh toàn màn hình kèm danh mục, mức độ cần thiết, số tiền, ghi chú, ngày giờ.
- Nút sửa/xóa dạng kính mờ; xóa có hoàn tác và chuyển vào thùng rác.
- Ảnh cloud dùng `cached_network_image`; ảnh local hiển thị trực tiếp từ thiết bị.

### 2. ☰ Điều hướng bằng Drawer
- Nút 3 gạch cố định ở góc trên trái của mọi màn hình chính.
- Drawer gồm: hồ sơ người dùng, **Nhật ký ảnh**, **Tổng quan**, **Thống kê**, **Ngân sách**,
  quản lý danh mục, thùng rác, cài đặt và chuyển sáng/tối.
- Hiển thị trạng thái **Cloud Sync** hoặc **Local / ngoại tuyến** ngay trong drawer.

### 3. 💎 Giao diện Fintech hiện đại
- Tông **Deep Slate** kết hợp **Emerald Green**, phông **Be Vietnam Pro**.
- Thẻ kính mờ (glassmorphism), gradient, huy hiệu icon pastel.
- Hỗ trợ đầy đủ Light Mode và Dark Mode.

### 4. 🔐 Xác thực Supabase
- Đăng nhập/đăng ký **Email & Mật khẩu**.
- **Google OAuth** qua trình duyệt, quay lại app bằng deep link
  `io.supabase.chitieu://login-callback/`.
- **Chế độ khách ngoại tuyến** không cần tài khoản.
- Kiểm tra provider Google trước khi mở trình duyệt để báo lỗi rõ ràng thay vì trang JSON.

### 5. ☁️ Cloud-first & Bảo mật RLS
- PostgreSQL + Row Level Security: mỗi người dùng chỉ thấy dữ liệu của mình.
- Hồ sơ `profiles` tạo tự động bằng trigger khi đăng ký.
- Ảnh hóa đơn nén client-side rồi upload lên bucket `expense-receipts`.
- Đồng bộ dữ liệu local lên cloud bằng một nút trong Cài đặt.

### 6. 📊 Thống kê & Ngân sách
- Biểu đồ tròn phân bổ theo danh mục, biểu đồ thanh theo mức độ cần thiết.
- Thống kê hôm nay/tuần/tháng/năm hoặc khoảng ngày tùy chọn.
- Ngân sách tổng hoặc theo danh mục, thanh tiến trình đổi màu theo hạn mức.
- Thùng rác cho phép khôi phục khoản chi đã xóa.

---

## 🛠️ Công nghệ sử dụng

| Tầng | Công nghệ / Thư viện | Mục đích |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart 3.13+) | Ứng dụng đa nền tảng |
| **State Management** | `flutter_riverpod` ^2.6.1 | StateNotifier, quản lý trạng thái |
| **Backend & Cloud** | `supabase_flutter` ^2.8.3 | Auth, PostgreSQL RLS, Storage |
| **Local Database** | `sqflite` ^2.4.2 | Lưu trữ ngoại tuyến |
| **Giao diện** | `google_fonts`, Material 3 | Be Vietnam Pro, Light/Dark |
| **Biểu đồ** | `fl_chart` ^0.70.2 | Donut và bar chart |
| **Camera & Ảnh** | `camera`, `image_picker`, `cached_network_image` | Chụp, chọn, cache ảnh |
| **Môi trường** | `flutter_dotenv` ^5.2.1 | Đọc `.env` |
| **Kiểm thử** | `flutter_test` | 69 Unit & Widget tests |

---

## 📁 Cấu trúc Thư mục

```text
chi_tieu/
├── android/                   # Manifest, quyền, OAuth deep link
├── docs/                      # Cấu trúc, yêu cầu, hướng dẫn OAuth
├── lib/
│   ├── core/                  # config, constants, navigation, services, theme, utils
│   ├── data/                  # models, database, repositories (Supabase + SQLite)
│   ├── providers/             # Riverpod StateNotifier
│   ├── screens/
│   │   ├── main_screen.dart   # Scaffold + Drawer + 4 khu vực
│   │   ├── auth/              # Login, Register
│   │   ├── camera/            # Locket feed, camera, form khoản chi
│   │   ├── home/              # Tổng quan
│   │   ├── statistics/        # Thống kê
│   │   ├── budget/            # Ngân sách
│   │   ├── categories/        # Danh mục
│   │   ├── settings/          # Cài đặt
│   │   ├── trash/             # Thùng rác
│   │   └── onboarding/        # Giới thiệu lần đầu
│   └── widgets/               # AppDrawer, GlassCard, ExpenseCard, ...
├── test/                      # Unit & Widget tests
├── supabase_setup.sql         # Bảng + RLS + Storage
├── .env.example               # Mẫu biến môi trường
└── pubspec.yaml
```

Chi tiết xem tại [docs/project-structure.md](docs/project-structure.md).

---

## ⚡ Hướng dẫn Cài đặt & Khởi chạy

### 1. Yêu cầu môi trường
- Flutter SDK 3.27+ (khuyến nghị 3.47+).
- Android Studio / VS Code + Android SDK.
- Tài khoản Supabase nếu muốn dùng cloud.

### 2. Tải mã nguồn
```bash
git clone https://github.com/beloncuaem/chi_tieu.git
cd chi_tieu
flutter pub get
```

### 3. Cấu hình Supabase
1. Tạo project tại [supabase.com](https://supabase.com).
2. Mở **SQL Editor**, chạy toàn bộ [supabase_setup.sql](supabase_setup.sql).
3. Tạo `.env` từ mẫu:
   ```bash
   cp .env.example .env
   ```
   Điền thông tin từ **Project Settings → API**:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-supabase-anon-key
   ```
4. Trong **Authentication → Providers**, bật **Email**.
5. Muốn dùng Google: bật **Google** và cấu hình OAuth Client ID/Secret.
   Làm theo [docs/google-oauth-troubleshooting.md](docs/google-oauth-troubleshooting.md).
6. Trong **Authentication → URL Configuration**, thêm redirect:
   ```text
   io.supabase.chitieu://login-callback/
   ```

> Không commit `.env`. Chỉ anon/publishable key được nhúng vào app;
> tuyệt đối không dùng `service_role` key trong client.

### 4. Chạy ứng dụng
```bash
flutter run
```

### 5. Xuất APK
```bash
flutter build apk --release
```
File: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Kiểm thử

```bash
flutter analyze     # không có lỗi biên dịch
flutter test        # 69/69 passed
```

- **Unit Tests**: model, formatter VND/ngày, trạng thái ngân sách/thống kê/auth,
  ánh xạ icon, sắp xếp feed ảnh.
- **Widget Tests**: Login/Settings/Trash, ExpenseCard, PriorityBadge, CategoryChip,
  AppDrawer (điều hướng, tiện ích, hồ sơ cloud/khách).

### Đã xác minh trên emulator Android API 35
- Onboarding và cấp quyền camera/thông báo.
- Đăng nhập email sai → Supabase trả `Invalid login credentials`
  → app hiển thị **"Email hoặc mật khẩu không chính xác."** (xác nhận kết nối backend).
- Chế độ ngoại tuyến vào thẳng Locket feed.
- Feed dọc, nút 3 gạch, drawer và 4 khu vực hiển thị đúng.
- Google OAuth được chặn rõ ràng khi provider chưa bật (xem tài liệu troubleshooting).
- **Bản release APK** cài trên emulator: offline mode được ghi nhớ sau khi khởi động lại,
  trang ảnh Locket mở đúng, drawer chuyển trang hoạt động, icon status bar đổi theo nền sáng/tối,
  Google preflight hiển thị thông báo tiếng Việt và đăng nhập email sai nhận lỗi
  trực tiếp từ Supabase (APK kết nối backend bình thường).

---

## 🔧 Khắc phục sự cố Google OAuth

Lỗi phổ biến khi cài APK:

```json
{"code":400,"error_code":"validation_failed","msg":"Unsupported provider: provider is not enabled"}
```

Nguyên nhân: **Google provider chưa được bật trong Supabase Dashboard**, không phải lỗi APK.
Chi tiết bằng chứng và các bước sửa:
[docs/google-oauth-troubleshooting.md](docs/google-oauth-troubleshooting.md).

---

## 📄 Giấy phép

Dự án phát hành theo **MIT License**.
