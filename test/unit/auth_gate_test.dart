import 'package:flutter_test/flutter_test.dart';
import 'package:chi_tieu/app.dart';
import 'package:chi_tieu/providers/auth_provider.dart';

void main() {
  group('shouldShowLoginScreen', () {
    test('Hiện login khi chưa đăng nhập', () {
      expect(shouldShowLoginScreen(status: AuthStatus.unauthenticated), isTrue);
    });

    test('Vẫn hiện login sau khi đăng nhập thất bại (status error)', () {
      expect(shouldShowLoginScreen(status: AuthStatus.error), isTrue);
    });

    test('Không hiện login khi đã xác thực', () {
      expect(shouldShowLoginScreen(status: AuthStatus.authenticated), isFalse);
    });
  });
}
