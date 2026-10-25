# Cấu trúc dự án Chi Tiêu (v2.2 — Locket Journal)

> Cập nhật: 2026-10-26. Tài liệu phản ánh kiến trúc Cloud-only (Supabase),
> xác thực bắt buộc, giao diện nhật ký ảnh kiểu Locket và bản sửa lỗi ngân sách/thùng rác.

## 1. Cây thư mục

```text
chi_tieu/
├── lib/
│   ├── main.dart                          # Entry point: dotenv, Supabase, SQLite, ProviderScope
│   ├── app.dart                           # MaterialApp, theme, onboarding/auth gate
│   ├── core/
│   │   ├── config/supabase_config.dart    # Đọc .env, khởi tạo Supabase, URL/key cho preflight
│   │   ├── constants/                     # AppColors, AppStrings
│   │   ├── navigation/app_section.dart    # enum 4 khu vực: feed / dashboard / statistics / budget
│   │   ├── services/notification_service.dart
│   │   ├── theme/app_theme.dart           # Light/Dark Material 3
│   │   └── utils/                         # CurrencyFormatter, DateFormatter, IconHelper
│   ├── data/
│   │   ├── database/database_helper.dart  # SQLite: onboarding + mức độ cần thiết
│   │   ├── models/                        # Expense, Category, Budget, PriorityLevel
│   │   └── repositories/
│   │       ├── auth_repository.dart       # Email/Google OAuth + preflight provider
│   │       ├── expense_repository.dart    # Chỉ Supabase, upload ảnh tự động
│   │       ├── category_repository.dart   # Chỉ Supabase
│   │       ├── budget_repository.dart     # Chỉ Supabase, chọn dòng ngân sách tổng mới nhất
│   │       ├── budget_alert_repository.dart
│   │       ├── app_settings_repository.dart # onboarding (SQLite)
│   │       ├── priority_repository.dart   # mức độ cần thiết (SQLite)
│   │       └── supabase_storage_service.dart
│   ├── providers/                         # Riverpod StateNotifier
│   │   ├── auth_provider.dart
│   │   ├── expense_provider.dart
│   │   ├── category_provider.dart
│   │   ├── budget_provider.dart
│   │   ├── statistics_provider.dart
│   │   ├── priority_provider.dart
│   │   ├── app_settings_provider.dart     # onboarding
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── main_screen.dart               # Scaffold + Drawer + AnimatedSwitcher 4 khu vực
│   │   ├── onboarding/                    # Onboarding 3 bước
│   │   ├── auth/                          # LoginScreen, RegisterScreen
│   │   ├── camera/
│   │   │   ├── camera_screen.dart          # Locket feed: PageView dọc, camera ở trang 0
│   │   │   ├── feed_helpers.dart           # Lọc ảnh + sắp xếp mới nhất trước
│   │   │   ├── feed_grid_screen.dart       # Xem ảnh dạng lưới, chọn để nhảy trong feed
│   │   │   ├── feed_photo_page.dart        # Trang ảnh toàn màn hình
│   │   │   └── expense_form_sheet.dart     # Nhập số tiền/danh mục/ưu tiên, lưu cloud
│   │   ├── home/                          # Dashboard tổng quan
│   │   ├── statistics/                    # Bộ lọc, biểu đồ, nhận xét
│   │   ├── budget/                        # Ngân sách tháng
│   │   ├── categories/                    # Quản lý danh mục
│   │   ├── settings/                      # Cài đặt, trạng thái cloud, theme
│   │   └── trash/                         # Thùng rác, khôi phục
│   └── widgets/
│       ├── app_drawer.dart                # Menu 3 gạch: hồ sơ + không gian + tiện ích
│       ├── hamburger_button.dart
│       ├── glass_card.dart
│       ├── screen_background.dart
│       ├── expense_card.dart
│       ├── category_icon_badge.dart
│       ├── category_chip.dart
│       ├── priority_badge.dart
│       └── amount_display.dart
├── test/
│   ├── unit/                              # Model, formatter, state, feed helper
│   └── widget/                            # Screen, widget, drawer
├── docs/
│   ├── project-structure.md
│   ├── requirements.md
│   └── google-oauth-troubleshooting.md
├── android/                               # Manifest, quyền, OAuth deep link
├── supabase_setup.sql                     # Bảng + RLS + Storage bucket
├── .env / .env.example                    # SUPABASE_URL, SUPABASE_ANON_KEY
└── pubspec.yaml
```

## 2. Kiến trúc dữ liệu

```text
Screen / Widget
      ↓ ref.watch / ref.read
Riverpod StateNotifier
      ↓
Repository
      ↓
Supabase (bắt buộc đăng nhập)
      ↓
PostgreSQL + RLS + Storage bucket `expense-receipts`
```

- **Cloud-only**: mọi thao tác đọc/ghi khoản chi, danh mục, ngân sách đều đi thẳng Supabase;
  không có fallback SQLite và không có đồng bộ thủ công.
- **Lỗi mạng**: repository ném `StateError`, UI hiển thị thông báo và không lưu dữ liệu.
- **Ảnh**: file tạm được upload lên Storage ngay khi lưu; sau đó `image_url` được ghi vào
  bảng `expenses` và tệp tạm trên máy bị xóa. Hủy form cũng xóa tệp tạm.

## 3. Xác thực và điều hướng

```text
main() → SupabaseConfig.initialize() → ChiTieuApp
                                        │
                        chưa hoàn tất onboarding?
                              ├── có → OnboardingScreen
                              └── không ↓
                      chưa đăng nhập?
                              ├── có → LoginScreen (email / Google)
                              └── không → MainScreen
```

- `AuthStatus`: `initial → loading → authenticated | unauthenticated | error`.
- Đăng nhập Google dùng OAuth trong trình duyệt hệ thống, quay về app qua deep link
  `io.supabase.chitieu://login-callback/` (đã khai báo trong `android/app/src/main/AndroidManifest.xml`).
- Trước khi mở trình duyệt, `AuthRepository.isGoogleProviderEnabled()` gọi
  `GET /auth/v1/settings`; nếu `external.google = false`, app hiện thông báo ngay
  thay vì để người dùng gặp trang JSON `Unsupported provider`.
- Không có chế độ khách hay ngoại tuyến; khi đăng xuất, các provider dữ liệu được invalidate.

## 4. Điều hướng giao diện

`MainScreen` không còn `NavigationBar` dưới đáy. Mỗi màn hình chính có nút **3 gạch** ở góc trên trái:

```text
MainScreen (Scaffold + Drawer)
├── AppSection.feed        → CameraScreen (Locket PageView dọc)
├── AppSection.dashboard   → HomeScreen
├── AppSection.statistics  → StatisticsScreen
└── AppSection.budget      → BudgetScreen

Drawer → push ManageCategoriesScreen / TrashScreen / SettingsScreen
```

### Locket feed

- `PageView.builder` theo chiều dọc.
- Trang 0: camera trực tiếp + nút thư viện / chụp / đổi camera.
- Trang 1..n: các khoản chi có ảnh, mới nhất trước (`buildFeedPhotos`).
- Sau khi lưu khoản chi mới, feed tự cuộn tới ảnh vừa tạo.
- Nút lưới ở góc phải mở `FeedGridScreen`; chạm ảnh để nhảy tới đúng trang trong feed.
- Ảnh cloud dùng `CachedNetworkImage`; hiển thị lỗi thân thiện nếu ảnh không tải được.
- Xóa khoảnh khắc hiện snackbar hoàn tác 5 giây; snackbar cũ được ẩn trước khi hiện cái mới.
- Trang ảnh không còn nhãn/badge "Đã đồng bộ"; trạng thái lưu cloud chỉ hiển thị ở drawer/tổng quan.
- Chuyển camera trước/sau giải phóng `CameraController` cũ trước khi khởi tạo camera mới,
  có rollback nếu camera mới không mở được.

## 5. Bảng dữ liệu

### SQLite

Chỉ dùng cho tùy chọn cục bộ, không chứa dữ liệu tài chính:

| Bảng | Nội dung |
| --- | --- |
| `priority_levels` | Danh sách mức độ cần thiết (seed mặc định) |
| `app_settings` | Trạng thái onboarding |

### Supabase PostgreSQL

| Bảng / bucket | Nội dung |
| --- | --- |
| `profiles` | Hồ sơ người dùng, tạo tự động bằng trigger |
| `categories` | Danh mục theo `user_id` |
| `expenses` | Khoản chi theo `user_id`, ảnh là `image_url` |
| `budgets` | Ngân sách theo `user_id` và tháng; mỗi tháng chỉ một dòng tổng (`category_id IS NULL`) nhờ unique index `uniq_budgets_total_per_month` |
| `budget_alerts` | Đánh dấu đã gửi cảnh báo 80/90/100% theo tháng |
| `expense-receipts` | Storage bucket chứa ảnh hóa đơn |

> Bản cũ dùng `upsert` cho ngân sách tổng nên có thể sinh nhiều dòng trùng.
> Repository hiện chọn dòng mới nhất, dọn dòng trùng khi lưu và xóa toàn bộ khi đặt ngân sách về 0.
> Với database đã tạo trước bản này, chạy lại phần `budgets` trong `supabase_setup.sql`
> để dọn dữ liệu cũ và tạo unique index.

## 6. Kiểm thử

```bash
flutter analyze          # No issues found (0 warning/info)
flutter test             # 66/66 passed
flutter build apk --release
flutter build apk --debug
```

- Unit: model, formatter, state, icon, feed ordering.
- Widget: Login/Settings/Trash, ExpenseCard, PriorityBadge, CategoryChip, AppDrawer.
- Đã xác minh trên emulator `codex_api35` (Android API 35):
  onboarding → login → email sai trả lỗi từ Supabase → feed Locket → drawer.
- Đã xác minh bản **release APK** cài trên emulator: feed vuốt dọc + trang ảnh,
  drawer chuyển 4 khu vực, status bar đổi màu icon theo theme,
  Google preflight báo lỗi rõ ràng và email sai nhận lỗi trực tiếp từ Supabase
  (xác nhận APK kết nối backend bình thường).
- Bản **debug APK** mới nhất build thành công sau khi sửa camera, ngân sách và thùng rác.

## 7. Lưu ý khi nâng cấp

1. Giữ nguyên scheme/host deep link nếu đổi package Android; cập nhật đồng thời Supabase Redirect URLs.
2. Không commit `.env`; chỉ commit `.env.example`.
3. Nếu thêm provider OAuth mới, cập nhật preflight trong `auth_repository.dart` và tài liệu troubleshooting.
4. Nếu đổi cấu trúc bảng, cập nhật cả `database_helper.dart`, `supabase_setup.sql` và model `toMap/fromMap`.
5. Cảnh báo ngân sách đã nối với `NotificationService` ở các mốc 80/90/100% và được đánh dấu
   trong bảng `budget_alerts`; kiểm tra quyền thông báo nếu không nhận được.
6. Database tạo trước v2.2 cần chạy phần dọn dữ liệu + unique index của `budgets` trong
   `supabase_setup.sql` để tránh nhiều dòng ngân sách tổng.
