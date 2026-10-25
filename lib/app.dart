import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'providers/budget_provider.dart';
import 'providers/category_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

bool shouldShowLoginScreen({
  required bool isConfigured,
  required AuthStatus status,
  required bool offlineMode,
}) {
  return isConfigured && status != AuthStatus.authenticated && !offlineMode;
}

class ChiTieuApp extends ConsumerWidget {
  const ChiTieuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const _AppHome(),
    );
  }
}

class _AppHome extends ConsumerWidget {
  const _AppHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final authState = ref.watch(authProvider);

    ref.listen<AppAuthState>(authProvider, (previous, next) {
      if (previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        ref.read(expenseProvider.notifier).refreshDashboard();
        ref.read(categoryProvider.notifier).loadCategories();
        ref
            .read(budgetProvider.notifier)
            .refreshCurrentMonthAfterExpenseChange();
      }
    });

    if (settings.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!settings.onboardingComplete) {
      return const OnboardingScreen();
    }

    if (shouldShowLoginScreen(
      isConfigured: authState.isConfigured,
      status: authState.status,
      offlineMode: settings.offlineMode,
    )) {
      return const LoginScreen();
    }

    return const MainScreen();
  }
}
