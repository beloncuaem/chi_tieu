<p align="center">
  <img src="https://raw.githubusercontent.com/beloncuaem/chi_tieu/main/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="96" height="96" alt="Chi Tiêu Logo" />
</p>

<h1 align="center">Chi Tiêu - Smart Expense Tracker</h1>

<p align="center">
  <b>Ứng dụng quản lý tài chính cá nhân phong cách Fintech Neo-Bank hiện đại, tích hợp đám mây Supabase (Auth, PostgreSQL RLS, Storage) & SQLite Fallback an toàn.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-Cloud%20Database-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/State-Riverpod%202.6-blue" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Database-PostgreSQL%20%7C%20SQLite-4169E1" alt="PostgreSQL SQLite" />
  <img src="https://img.shields.io/badge/Tests-53%20Passed%20(100%25)-success" alt="Tests" />
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License" />
</p>

---

## 🌟 Giới thiệu

**Chi Tiêu** là ứng dụng theo dõi chi tiêu và quản lý ngân sách cá nhân được thiết kế theo chuẩn giao diện ngân hàng số thế hệ mới (**Fintech Neo-Bank**). Ứng dụng hỗ trợ ghi nhận chi tiêu kèm hình ảnh hóa đơn/biên lai chụp từ camera, tự động nén tối ưu và đồng bộ hóa tức thì lên nền tảng đám mây **Supabase**, đồng thời duy trì khả năng hoạt động mượt mà ngoại tuyến (**Offline-ready**) với cơ sở dữ liệu **SQLite**.

---

## 🚀 Tính năng nổi bật

### 1. 💎 Giao diện Fintech Neo-Bank Cao cấp
- **Bảng màu thời thượng**: Tông màu chủ đạo **Deep Slate (`#0B0F19`)** phối hợp cùng **Emerald Green (`#10B981`)** mang lại cảm giác tin cậy, giàu có và chuẩn công nghệ tài chính.
- **Thẻ số dư Glassmorphism**: Thẻ ví điện tử bo góc mềm 24px với dải gradient sang trọng, tổng hợp chi tiêu tháng, tuần và ngày.
- **Typography Be Vietnam Pro**: Tích hợp phông chữ tiếng Việt sắc nét từ Google Fonts cho cả hai chế độ **Sáng (Light Mode)** và **Tối (Dark Mode)**.
- **Hệ thống Icon & Huy hiệu Pastel**: Bộ icon vector hiện đại đặt trong các huy hiệu tròn màu pastel thanh lịch, tương thích với cả các biểu tượng emoji truyền thống.

### 2. 🔐 Hệ thống Xác thực & Người dùng (Supabase Auth)
- Đăng nhập & Đăng ký an toàn với **Email & Mật khẩu**.
- Hỗ trợ đăng nhập nhanh bằng **Google Sign-In (OAuth)**.
- Chế độ trải nghiệm ngoại tuyến dành cho người dùng chưa đăng nhập.

### 3. ☁️ Cơ sở dữ liệu Cloud-First & Bảo mật RLS
- Dữ liệu giao dịch được lưu trữ trên **PostgreSQL** của Supabase.
- Cơ chế bảo mật hàng cấp độ cao **Row Level Security (RLS)**: Đảm bảo người dùng chỉ có quyền truy cập và thao tác trên dữ liệu của chính mình.
- Tự động tạo hồ sơ người dùng (`profiles`) qua Database Trigger khi đăng ký.

### 4. 🔄 Đồng bộ hóa Dữ liệu (Cloud Sync & SQLite Fallback)
- **Kiến trúc Hybrid**: Khi có kết nối mạng và đã đăng nhập, dữ liệu đọc/ghi trực tiếp từ Cloud. Khi mất mạng hoặc chưa cấu hình Supabase, ứng dụng tự động fallback về **SQLite** nội bộ.
- **One-tap Cloud Migration**: Tính năng đồng bộ toàn bộ dữ liệu offline đã ghi nhận trước đó lên tài khoản đám mây chỉ bằng một nút bấm trong mục Cài đặt.

### 5. 📸 Quản lý Hóa đơn & Biên lai (Cloud Storage)
- Chụp ảnh hóa đơn trực tiếp bằng camera hoặc chọn từ thư viện ảnh.
- Thuật toán nén ảnh client-side thông minh giúp giảm kích thước hóa đơn xuống còn ~100–200KB trước khi tải lên **Supabase Storage Bucket** (`expense-receipts`).
- Tự động lưu trữ ảnh đám mây, tích hợp bộ nhớ đệm `cached_network_image` và hỗ trợ phóng to xem trước toàn màn hình.

### 6. 📊 Phân tích & Ngân sách Thông minh
- **Biểu đồ fl_chart trực quan**: Biểu đồ tròn (Donut chart) phân bổ chi tiêu theo danh mục và biểu đồ xu hướng theo ngày/tuần/tháng/năm.
- **Thiết lập hạn mức ngân sách**: Đặt ngân sách tổng hoặc chi tiết theo từng danh mục.
- **Cảnh báo thông minh**: Thanh tiến trình đổi màu tự động (Xanh an toàn, Vàng 80%, Đỏ vượt hạn mức) và gửi thông báo nhắc nhở qua `flutter_local_notifications`.

---

## 🛠️ Công nghệ sử dụng

| Tầng (Layer) | Công nghệ / Thư viện | Mục đích |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart 3.13+) | Xây dựng ứng dụng đa nền tảng hiệu năng cao |
| **State Management** | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) ^2.6.1 | Quản lý trạng thái nhất quán, module hóa và dễ test |
| **Backend & Cloud** | [supabase_flutter](https://pub.dev/packages/supabase_flutter) ^2.8.3 | Xác thực (Auth), Cơ sở dữ liệu (PostgreSQL RLS), Lưu trữ (Storage) |
| **Local Database** | [sqflite](https://pub.dev/packages/sqflite) ^2.4.2 | Lưu trữ cục bộ ngoại tuyến |
| **Giao diện & Phông chữ** | [google_fonts](https://pub.dev/packages/google_fonts) ^6.2.1 | Phông chữ Be Vietnam Pro chuẩn tiếng Việt |
| **Biểu đồ** | [fl_chart](https://pub.dev/packages/fl_chart) ^0.70.2 | Biểu đồ tròn và thanh tương tác trực quan |
| **Camera & Hình ảnh** | `camera`, `image_picker`, `cached_network_image` | Chụp, chọn, nén và cache ảnh hóa đơn |
| **Bảo mật môi trường** | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) ^5.2.1 | Bảo vệ Supabase URL và API Keys ngoài Git |
| **Kiểm thử** | `flutter_test` (53 Unit & Widget Tests) | Đảm bảo độ tin cậy và không lỗi hồi quy |

---

## 📁 Cấu trúc Thư mục

```text
chi_tieu/
├── android/                   # Cấu hình Android native & AndroidManifest
├── assets/                    # File tài nguyên & cấu hình .env
├── docs/                      # Tài liệu yêu cầu và thiết kế
├── lib/
│   ├── core/                  # Cấu hình chung, Theme, Constants & Tiện ích
│   │   ├── config/            # Supabase Client configuration
│   │   ├── constants/         # AppColors (Fintech tokens), AppStrings
│   │   ├── services/          # NotificationService
│   │   ├── theme/             # AppTheme (Light & Dark theme)
│   │   └── utils/             # Formatters, IconHelper
│   ├── data/                  # Tầng Dữ liệu (Models, Repositories, SQLite)
│   │   ├── database/          # DatabaseHelper (SQLite)
│   │   ├── models/            # Expense, Category, Budget, PriorityLevel
│   │   └── repositories/      # ExpenseRepo, CategoryRepo, AuthRepo, SyncService
│   ├── providers/             # Riverpod State Notifiers
│   ├── screens/               # Màn hình giao diện
│   │   ├── auth/              # LoginScreen, RegisterScreen
│   │   ├── budget/            # BudgetScreen
│   │   ├── camera/            # CameraScreen, ExpenseFormSheet
│   │   ├── categories/        # ManageCategoriesScreen
│   │   ├── home/              # HomeScreen (Fintech Dashboard)
│   │   ├── settings/          # SettingsScreen
│   │   ├── statistics/        # StatisticsScreen
│   │   └── trash/             # TrashScreen (Khôi phục khoản chi)
│   ├── widgets/               # Các Widget tái sử dụng (ExpenseCard, CategoryIconBadge, ...)
│   ├── app.dart               # Khởi tạo MaterialApp & điều hướng phiên đăng nhập
│   └── main.dart              # Entry point của ứng dụng
├── test/                      # Bộ kiểm thử tự động (Unit & Widget tests)
├── .env.example               # Mẫu file cấu hình biến môi trường
├── supabase_setup.sql         # Script khởi tạo Database & RLS Supabase 1-Click
└── pubspec.yaml               # Danh sách thư viện và cấu hình dự án
```

---

## ⚡ Hướng dẫn Cài đặt & Khởi chạy

### 1. Yêu cầu môi trường
- Đã cài đặt [Flutter SDK](https://flutter.dev/docs/get-started/install) (Khuyến nghị 3.27+ hoặc mới nhất).
- Đã cài đặt Android Studio / VS Code và Android SDK Platform.

### 2. Tải mã nguồn & Cài đặt dependencies
```bash
git clone https://github.com/beloncuaem/chi_tieu.git
cd chi_tieu
flutter pub get
```

### 3. Cấu hình Supabase (3 bước đơn giản)
1. Đăng ký tài khoản miễn phí tại [supabase.com](https://supabase.com) và tạo một Project mới.
2. Mở mục **SQL Editor** trên Dashboard Supabase, copy toàn bộ nội dung file [supabase_setup.sql](supabase_setup.sql), dán vào và nhấn **Run** để khởi tạo các bảng và phân quyền RLS.
3. Tạo file `.env` tại thư mục gốc dự án (sao chép từ `.env.example`):
   ```bash
   cp .env.example .env
   ```
   Sau đó điền thông tin lấy từ **Project Settings -> API**:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-supabase-anon-key
   ```

### 4. Khởi chạy ứng dụng
```bash
# Chạy ứng dụng trên thiết bị / máy ảo
flutter run

# Chạy toàn bộ 53 bài kiểm thử tự động
flutter test
```

### 5. Xuất file cài đặt APK Android
```bash
flutter build apk --release
```
*File APK thành phẩm sẽ nằm tại:* `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Kiểm thử (Testing)

Dự án được bảo vệ nghiêm ngặt bởi bộ 53 bài kiểm thử đơn vị (Unit Tests) và kiểm thử giao diện (Widget Tests):

```bash
00:01 +53: All tests passed!
```

- **Unit Tests**: Kiểm tra tính toán ngân sách, định dạng tiền tệ VND, mô hình dữ liệu, ánh xạ icon và trạng thái xác thực Auth.
- **Widget Tests**: Kiểm tra hiển thị thẻ chi tiêu, bộ lọc giao dịch, bảng màu, cài đặt và thùng rác.

---

## 📄 Giấy phép (License)

Dự án được phát hành theo giấy phép **MIT License**. Bạn có thể tự do sử dụng, chỉnh sửa và phân phối cho mục đích cá nhân hoặc thương mại.
