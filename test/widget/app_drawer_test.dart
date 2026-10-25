import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chi_tieu/core/navigation/app_section.dart';
import 'package:chi_tieu/widgets/app_drawer.dart';

AppDrawer _drawer({
  AppSection selected = AppSection.feed,
  ValueChanged<AppSection>? onSelectSection,
  VoidCallback? onOpenCategories,
  VoidCallback? onOpenTrash,
  VoidCallback? onOpenSettings,
  VoidCallback? onToggleTheme,
  VoidCallback? onLogin,
  Future<void> Function()? onLogout,
  bool isCloudUser = false,
}) {
  return AppDrawer(
    selected: selected,
    onSelectSection: onSelectSection ?? (_) {},
    onOpenCategories: onOpenCategories ?? () {},
    onOpenTrash: onOpenTrash ?? () {},
    onOpenSettings: onOpenSettings ?? () {},
    onToggleTheme: onToggleTheme ?? () {},
    displayName: isCloudUser ? 'Quang' : 'Khách',
    email: isCloudUser ? 'quang@example.com' : null,
    isCloudUser: isCloudUser,
    isDarkMode: true,
    onLogin: onLogin,
    onLogout: onLogout,
  );
}

Future<void> _openDrawer(WidgetTester tester, AppDrawer drawer) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final key = GlobalKey<ScaffoldState>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(key: key, drawer: drawer, body: const SizedBox.expand()),
    ),
  );
  key.currentState!.openDrawer();
  await tester.pumpAndSettle();
}

void main() {
  group('AppDrawer', () {
    testWidgets('Hiển thị các mục điều hướng chính', (tester) async {
      await _openDrawer(tester, _drawer());

      for (final section in AppSection.values) {
        expect(find.text(section.label), findsOneWidget);
      }
      expect(find.text('Quản lý danh mục'), findsOneWidget);
      expect(find.text('Thùng rác'), findsOneWidget);
      expect(find.text('Cài đặt'), findsOneWidget);
      expect(find.text('Chế độ ngoại tuyến'), findsOneWidget);
    });

    testWidgets('Chọn mục gọi callback và đóng drawer', (tester) async {
      AppSection? selected;
      await _openDrawer(
        tester,
        _drawer(onSelectSection: (section) => selected = section),
      );

      await tester.tap(find.text(AppSection.statistics.label));
      await tester.pumpAndSettle();

      expect(selected, AppSection.statistics);
      expect(find.text('Quản lý danh mục'), findsNothing);
    });

    testWidgets('Mở quản lý danh mục', (tester) async {
      var opened = false;
      await _openDrawer(tester, _drawer(onOpenCategories: () => opened = true));

      await tester.tap(find.text('Quản lý danh mục'));
      await tester.pumpAndSettle();

      expect(opened, isTrue);
    });

    testWidgets('Mở thùng rác', (tester) async {
      var opened = false;
      await _openDrawer(tester, _drawer(onOpenTrash: () => opened = true));

      await tester.tap(find.text('Thùng rác'));
      await tester.pumpAndSettle();

      expect(opened, isTrue);
    });

    testWidgets('Mở cài đặt', (tester) async {
      var opened = false;
      await _openDrawer(tester, _drawer(onOpenSettings: () => opened = true));

      await tester.tap(find.text('Cài đặt'));
      await tester.pumpAndSettle();

      expect(opened, isTrue);
    });

    testWidgets('Đổi giao diện sáng/tối', (tester) async {
      var toggled = false;
      await _openDrawer(tester, _drawer(onToggleTheme: () => toggled = true));

      await tester.tap(find.text('Chuyển giao diện sáng'));
      await tester.pumpAndSettle();

      expect(toggled, isTrue);
    });

    testWidgets('Hiển thị hồ sơ cloud và nút đăng xuất', (tester) async {
      var loggedOut = false;
      await _openDrawer(
        tester,
        _drawer(isCloudUser: true, onLogout: () async => loggedOut = true),
      );

      expect(find.text('Quang'), findsOneWidget);
      expect(find.text('quang@example.com'), findsOneWidget);
      expect(find.text('Cloud Sync'), findsOneWidget);

      await tester.tap(find.byTooltip('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(loggedOut, isTrue);
    });

    testWidgets('Khách có nút đăng nhập', (tester) async {
      var tappedLogin = false;
      await _openDrawer(tester, _drawer(onLogin: () => tappedLogin = true));

      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();
      expect(tappedLogin, isTrue);
    });
  });
}
