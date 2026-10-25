import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/app_settings_repository.dart';

class AppSettingsState {
  final bool isLoading;
  final bool onboardingComplete;
  final bool offlineMode;

  const AppSettingsState({
    this.isLoading = true,
    this.onboardingComplete = false,
    this.offlineMode = false,
  });

  AppSettingsState copyWith({
    bool? isLoading,
    bool? onboardingComplete,
    bool? offlineMode,
  }) => AppSettingsState(
    isLoading: isLoading ?? this.isLoading,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    offlineMode: offlineMode ?? this.offlineMode,
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
    final offline = await _repository.getString('offline_mode') == 'true';
    state = state.copyWith(
      isLoading: false,
      onboardingComplete: complete,
      offlineMode: offline,
    );
  }

  Future<void> completeOnboarding() async {
    await _repository.setString('onboarding_complete', 'true');
    state = state.copyWith(onboardingComplete: true);
  }

  Future<void> continueOffline() async {
    await _repository.setString('offline_mode', 'true');
    state = state.copyWith(offlineMode: true);
  }

  Future<void> exitOffline() async {
    await _repository.setString('offline_mode', 'false');
    state = state.copyWith(offlineMode: false);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>(
      (ref) => AppSettingsNotifier(),
    );
