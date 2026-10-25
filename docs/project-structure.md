# Cấu trúc dự án Chi Tiêu (v2.1 — Locket Journal)

> Cập nhật: 2026-10-26. Tài liệu phản ánh kiến trúc Cloud-first + SQLite fallback,
> xác thực Supabase và giao diện nhật ký ảnh kiểu Locket.

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
│   │   ├── database/database_helper.dart  # Schema SQLite, danh mục mặc định
│   │   ├── models/                        # Expense, Category, Budget, PriorityLevel
│   │   └── repositories/
│   │       ├── auth_repository.dart       # Email/Google OAuth + preflight provider
│   │       ├── expense_repository.dart    # Cloud-first, fallback SQLite
│   │       ├── category_repository.dart
│   │       ├── budget_repository.dart
│   │       ├── supabase_storage_service.dart
│   │       └── data_sync_service.dart     # Đồng bộ dữ liệu local → cloud
│   ├── providers/                         # Riverpod StateNotifier
│   │   ├── auth_provider.dart
│   │   ├── expense_provider.dart
│   │   ├── category_provider.dart
│   │   ├── budget_provider.dart
│   │   ├── statistics_provider.dart
│   │   ├── priority_provider.dart
│   │   ├── app_settings_provider.dart     # onboarding, theme, offlineMode
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── main_screen.dart               # Scaffold + Drawer + AnimatedSwitcher 4 khu vực
│   │   ├── onboarding/                    # Onboarding 3 bước
│   │   ├── auth/                          # LoginScreen, RegisterScreen
│   │   ├── camera/
│   │   │   ├── camera_screen.dart          # Locket feed: PageView dọc, camera ở trang 0
│   │   │   ├── feed_helpers.dart           # Lọc ảnh + sắp xếp mới nhất trước
│   │   │   ├── feed_photo_page.dart        # Trang ảnh toàn màn hình
│   │   │   └── expense_form_sheet.dart     # Nhập số tiền/danh mục/ưu tiên
│   │   ├── home/                          # Dashboard tổng quan
│   │   ├── statistics/                    # Bộ lọc, biểu đồ, nhận xét
│   │   ├── budget/                        # Ngân sách tháng
│   │   ├── categories/                    # Quản lý danh mục
│   │   ├── settings/                      # Cài đặt, đồng bộ, theme
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
Supabase (nếu đã đăng nhập)  ──lỗi/mất mạng──►  SQLite (fallback)
      ↓
PostgreSQL + RLS + Storage bucket `expense-receipts`
```

- **Cloud-first**: repository thử ghi/đọc Supabase trước; mọi thao tác được bảo vệ bởi RLS theo `auth.uid()`.
- **Offline fallback**: khi chưa đăng nhập, chưa cấu hình hoặc gọi cloud thất bại, repository dùng SQLite.
- **Đồng bộ**: `DataSyncService.syncLocalToCloud()` đẩy danh mục, khoản chi và ảnh local lên tài khoản đang đăng nhập.
- **Ảnh**: file local được nén, upload lên Storage, sau đó lưu `image_url` vào bảng `expenses`.

## 3. Xác thực và điều hướng

```text
main() → SupabaseConfig.initialize() → ChiTieuApp
                                        │
                        chưa hoàn tất onboarding?
                              ├── có → OnboardingScreen
                              └── không ↓
                 Supabase cấu hình & chưa đăng nhập & không offline?
                              ├── có → LoginScreen (email / Google / offline)
                              └── không → MainScreen
```

- `AuthStatus`: `initial → loading → authenticated | unauthenticated | error`.
- Đăng nhập Google dùng OAuth trong trình duyệt hệ thống, quay về app qua deep link
  `io.supabase.chitieu://login-callback/` (đã khai báo trong `android/app/src/main/AndroidManifest.xml`).
- Trước khi mở trình duyệt, `AuthRepository.isGoogleProviderEnabled()` gọi
  `GET /auth/v1/settings`; nếu `external.google = false`, app hiện thông báo ngay
  thay vì để người dùng gặp trang JSON `Unsupported provider`.
- Chế độ khách (`offlineMode = true`) bỏ qua màn đăng nhập và dùng SQLite.

## 4. Điều hướng giao diện

`MainScreen` không còn `NavigationBar` dưới đáy. Mỗi màn hình chính có nút **3 gạch** ở góc trên trái:

```text
MainScreen (Scaffold + Drawer)
├── AppSection.feed        → CameraScreen (Locket PageView dọc)
├── AppSection.dashboard   → HomeScreen
├── AppSection.statistics  → StatisticsScreen
└── AppSection.budget      → BudgetScreen

Drawer → push ManageCategoriesScreen / TrashScreen / SettingsScreen / LoginScreen
```

### Locket feed

- `PageView.builder` theo chiều dọc.
- Trang 0: camera trực tiếp + nút thư viện / chụp / đổi camera / nhập nhanh.
- Trang 1..n: các khoản chi có ảnh, mới nhất trước (`buildFeedPhotos`).
- Sau khi lưu khoản chi mới, feed tự cuộn tới ảnh vừa tạo.
- Ảnh cloud dùng `CachedNetworkImage`; ảnh local dùng `Image.file`, có placeholder lỗi.

## 5. Bảng dữ liệu

### SQLite

| Bảng | Nội dung |
| --- | --- |
| `categories` | Tên, icon, `is_default`, thời điểm tạo |
| `expenses` | Ảnh, mô tả, số tiền, danh mục, ưu tiên, `created_at`, `deleted_at` |
| `budgets` | Tháng (`yyyy-MM`), danh mục tùy chọn, hạn mức |

### Supabase PostgreSQL

| Bảng / bucket | Nội dung |
| --- | --- |
| `profiles` | Hồ sơ người dùng, tạo tự động bằng trigger |
| `categories` | Danh mục theo `user_id` |
| `expenses` | Khoản chi theo `user_id`, ảnh là `image_url` |
| `budgets` | Ngân sách theo `user_id` và tháng |
| `expense-receipts` | Storage bucket chứa ảnh hóa đơn |

## 6. Kiểm thử

```bash
flutter analyze          # No issues found (0 warning/info)
flutter test             # 69/69 passed
flutter build apk --release
```

- Unit: model, formatter, state, icon, feed ordering.
- Widget: Login/Settings/Trash, ExpenseCard, PriorityBadge, CategoryChip, AppDrawer.
- Đã xác minh trên emulator `codex_api35` (Android API 35):
  onboarding → login → email sai trả lỗi từ Supabase → offline mode → Locket feed → drawer.
- Đã xác minh bản **release APK** cài trên emulator: offline mode được ghi nhớ qua lần khởi động lại,
  feed vuốt dọc + trang ảnh, drawer chuyển 4 khu vực, status bar đổi màu icon theo theme,
  Google preflight báo lỗi rõ ràng và email sai nhận lỗi trực tiếp từ Supabase
  (xác nhận APK kết nối backend bình thường).

## 7. Lưu ý khi nâng cấp

1. Giữ nguyên scheme/host deep link nếu đổi package Android; cập nhật đồng thời Supabase Redirect URLs.
2. Không commit `.env`; chỉ commit `.env.example`.
3. Nếu thêm provider OAuth mới, cập nhật preflight trong `auth_repository.dart` và tài liệu troubleshooting.
4. Nếu đổi cấu trúc bảng, cập nhật cả `database_helper.dart`, `supabase_setup.sql` và model `toMap/fromMap`.
5. `flutter_local_notifications` đã khai báo nhưng chưa nối vào luồng cảnh báo ngân sách.
