import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'providers/theme_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

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

    if (settings.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!settings.onboardingComplete) {
      return const OnboardingScreen();
    }

    if (authState.isConfigured && authState.status == AuthStatus.unauthenticated) {
      return const LoginScreen();
    }

    return const MainScreen();
  }
}
