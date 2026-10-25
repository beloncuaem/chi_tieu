import 'package:flutter_test/flutter_test.dart';
import 'package:chi_tieu/app.dart';
import 'package:chi_tieu/providers/auth_provider.dart';

void main() {
  group('shouldShowLoginScreen', () {
    test('Hiện login khi đã cấu hình Supabase và chưa đăng nhập', () {
      expect(
        shouldShowLoginScreen(
          isConfigured: true,
          status: AuthStatus.unauthenticated,
          offlineMode: false,
        ),
        isTrue,
      );
    });

    test('Vẫn hiện login sau khi đăng nhập thất bại (status error)', () {
      expect(
        shouldShowLoginScreen(
          isConfigured: true,
          status: AuthStatus.error,
          offlineMode: false,
        ),
        isTrue,
      );
    });

    test('Không hiện login khi đã xác thực', () {
      expect(
        shouldShowLoginScreen(
          isConfigured: true,
          status: AuthStatus.authenticated,
          offlineMode: false,
        ),
        isFalse,
      );
    });

    test('Không hiện login khi chọn chế độ ngoại tuyến', () {
      expect(
        shouldShowLoginScreen(
          isConfigured: true,
          status: AuthStatus.unauthenticated,
          offlineMode: true,
        ),
        isFalse,
      );
    });

    test('Không hiện login khi Supabase chưa cấu hình', () {
      expect(
        shouldShowLoginScreen(
          isConfigured: false,
          status: AuthStatus.unauthenticated,
          offlineMode: false,
        ),
        isFalse,
      );
    });
  });
}
