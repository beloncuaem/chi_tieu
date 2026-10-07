import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/app_settings_repository.dart';

class AppSettingsState {
  final bool isLoading;
  final bool onboardingComplete;

  const AppSettingsState({
    this.isLoading = true,
    this.onboardingComplete = false,
  });

  AppSettingsState copyWith({bool? isLoading, bool? onboardingComplete}) =>
      AppSettingsState(
        isLoading: isLoading ?? this.isLoading,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier() : super(const AppSettingsState()) {
    _load();
  }

  final AppSettingsRepository _repository = AppSettingsRepository();

  Future<void> _load() async {
    final complete =
        await _repository.getString('onboarding_complete') == 'true';
    state = state.copyWith(isLoading: false, onboardingComplete: complete);
  }

  Future<void> completeOnboarding() async {
    await _repository.setString('onboarding_complete', 'true');
    state = state.copyWith(onboardingComplete: true);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>(
      (ref) => AppSettingsNotifier(),
    );
