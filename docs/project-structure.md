# Cấu trúc dự án

```text
chi_tieu/
├── lib/
│   ├── main.dart                         # Khởi tạo Flutter, SQLite và ProviderScope
│   ├── app.dart                          # MaterialApp, theme và màn hình gốc
│   ├── core/
│   │   ├── constants/                    # Chuỗi hiển thị và màu sắc chung
│   │   ├── theme/                        # Light/Dark ThemeData
│   │   └── utils/                        # Định dạng tiền tệ và ngày giờ
│   ├── data/
│   │   ├── database/database_helper.dart # Schema SQLite và dữ liệu danh mục mặc định
│   │   ├── models/                       # Expense, Category, Budget
│   │   └── repositories/                 # Truy vấn SQLite theo từng miền dữ liệu
│   ├── providers/                        # StateNotifier/Riverpod cho chi tiêu, danh mục,
│   │                                    # ngân sách, thống kê và giao diện
│   ├── screens/
│   │   ├── main_screen.dart              # Điều hướng 4 tab chính
│   │   ├── camera/                       # Camera, chọn ảnh, biểu mẫu tạo khoản chi
│   │   ├── home/                         # Tổng quan và danh sách khoản chi
│   │   ├── statistics/                   # Bộ lọc thời gian, biểu đồ, nhận xét
│   │   ├── budget/                       # Ngân sách tháng
│   │   ├── categories/                   # Quản lý danh mục
│   │   └── settings/                     # Cài đặt giao diện và lối vào danh mục
│   └── widgets/                          # Các widget dùng lại
├── test/                                 # Unit test hiện có cho model/utility
├── android/                              # Host Android và cấu hình Gradle
├── ios/                                  # Host iOS và cấu hình Xcode
├── windows/                              # Host Windows và CMake runner
├── pubspec.yaml                          # Metadata và dependencies Flutter
├── analysis_options.yaml                 # Quy tắc phân tích Dart
└── README.md                             # Tổng quan và hướng dẫn chạy
```

## Luồng dữ liệu

```text
Screen / Widget
      ↓ đọc và gọi hành động
Riverpod Provider (StateNotifier)
      ↓
Repository
      ↓
DatabaseHelper / SQLite
```

Ví dụ khi lưu một khoản chi:

1. `ExpenseFormSheet` sao chép ảnh vào thư mục tài liệu ứng dụng và tạo `Expense`.
2. `ExpenseNotifier` gọi `ExpenseRepository.insertExpense`.
3. `ExpenseRepository` ghi vào bảng `expenses` của SQLite.
4. Provider tải lại danh sách chi tiêu hôm nay để cập nhật màn Tổng quan.

## Các bảng SQLite

| Bảng | Nội dung chính |
| --- | --- |
| `categories` | Tên, biểu tượng, cờ danh mục mặc định, thời điểm tạo. |
| `expenses` | Ảnh, mô tả, số tiền, danh mục, mức độ ưu tiên, thời điểm tạo. |
| `budgets` | Tháng, danh mục tùy chọn và giá trị ngân sách. |

## Điều hướng hiện tại

`MainScreen` dùng `NavigationBar` và `IndexedStack` để giữ trạng thái của bốn tab: **Chụp → Tổng quan → Thống kê → Ngân sách**. `SettingsScreen` và `ManageCategoriesScreen` đã tồn tại trong mã nguồn nhưng chưa được gắn vào NavigationBar hoặc AppBar của luồng chính.
