import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/priority_level.dart';
import '../data/repositories/priority_repository.dart';

class PriorityState {
  final List<PriorityLevel> levels;
  final bool isLoading;

  const PriorityState({this.levels = const [], this.isLoading = false});

  PriorityState copyWith({List<PriorityLevel>? levels, bool? isLoading}) =>
      PriorityState(
        levels: levels ?? this.levels,
        isLoading: isLoading ?? this.isLoading,
      );
}

class PriorityNotifier extends StateNotifier<PriorityState> {
  PriorityNotifier() : super(const PriorityState()) {
    loadLevels();
  }

  final PriorityRepository _repository = PriorityRepository();

  Future<void> loadLevels() async {
    state = state.copyWith(isLoading: true);
    final levels = await _repository.getAll();
    state = state.copyWith(levels: levels, isLoading: false);
  }

  Future<void> addLevel(String name, int colorValue) async {
    final id = await _repository.nextId();
    await _repository.insert(
      PriorityLevel(id: id, name: name, colorValue: colorValue, sortOrder: id),
    );
    await loadLevels();
  }

  Future<void> updateLevel(PriorityLevel level) async {
    await _repository.update(level);
    await loadLevels();
  }

  Future<void> deleteLevel(int id, int replacementId) async {
    await _repository.deleteAndMoveExpenses(
      id: id,
      replacementId: replacementId,
    );
    await loadLevels();
  }
}

final priorityProvider = StateNotifierProvider<PriorityNotifier, PriorityState>(
  (ref) => PriorityNotifier(),
);
