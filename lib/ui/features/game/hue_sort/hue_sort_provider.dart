import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hue_sort_engine.dart';

class HueSortState {
  final HueSortLevel level;
  final List<Color> currentColors;
  final int? selectedIndex;
  final bool isSolved;
  final int hintsRemaining;

  HueSortState({
    required this.level,
    required this.currentColors,
    this.selectedIndex,
    this.isSolved = false,
    required this.hintsRemaining,
  });

  HueSortState copyWith({
    HueSortLevel? level,
    List<Color>? currentColors,
    int? selectedIndex,
    bool? isSolved,
    int? hintsRemaining,
    bool clearSelection = false,
  }) {
    return HueSortState(
      level: level ?? this.level,
      currentColors: currentColors ?? this.currentColors,
      selectedIndex: clearSelection ? null : (selectedIndex ?? this.selectedIndex),
      isSolved: isSolved ?? this.isSolved,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
    );
  }

  int get wrongTilesCount {
    int count = 0;
    for (int i = 0; i < currentColors.length; i++) {
      if (currentColors[i].r != level.solution[i].r ||
          currentColors[i].g != level.solution[i].g ||
          currentColors[i].b != level.solution[i].b) {
        count++;
      }
    }
    return count;
  }
}

class HueSortViewModel extends StateNotifier<HueSortState> {
  HueSortViewModel() : super(_initialState());

  final _engine = HueSortEngine();
  final List<HueSortState> _history = [];

  bool get canUndo => _history.isNotEmpty;

  static int maxHintsForSize(int size) {
    if (size <= 4) return 1;
    if (size <= 7) return 2;
    return 5;
  }

  static HueSortState _initialState() {
    final engine = HueSortEngine();
    final level = engine.generateLevel();
    return HueSortState(
      level: level,
      currentColors: List.from(level.colors),
      hintsRemaining: maxHintsForSize(level.size),
    );
  }

  void initGame({
    int? levelNumber,
    int? gridSize,
    HueSortDifficulty? difficulty,
    bool isRandom = false,
  }) {
    _history.clear();
    final level = _engine.generateLevel(
      level: isRandom ? null : (levelNumber ?? 1),
      size: gridSize ?? (isRandom && levelNumber != null ? HueSortEngine.sizeForLevel(levelNumber) : null),
      difficulty: difficulty,
      isRandom: isRandom,
    );
    state = HueSortState(
      level: level,
      currentColors: List.from(level.colors),
      hintsRemaining: maxHintsForSize(level.size),
    );
  }

  void newGame() {
    _history.clear();
    final level = _engine.generateLevel(
      size: state.level.size,
      difficulty: state.level.difficulty,
      isRandom: true,
    );
    state = HueSortState(
      level: level,
      currentColors: List.from(level.colors),
      hintsRemaining: maxHintsForSize(level.size),
      isSolved: false,
    );
  }

  void useHint() {
    if (state.isSolved || state.hintsRemaining <= 0) return;

    int targetSlot = -1;
    for (int i = 0; i < state.currentColors.length; i++) {
      if (!state.level.fixedIndices.contains(i)) {
        final current = state.currentColors[i];
        final solution = state.level.solution[i];
        if (current.r != solution.r || current.g != solution.g || current.b != solution.b) {
          targetSlot = i;
          break;
        }
      }
    }

    if (targetSlot == -1) return;

    final targetColor = state.level.solution[targetSlot];
    int fromSlot = -1;
    for (int i = 0; i < state.currentColors.length; i++) {
      if (i != targetSlot && !state.level.fixedIndices.contains(i)) {
        final c = state.currentColors[i];
        if (c.r == targetColor.r && c.g == targetColor.g && c.b == targetColor.b) {
          fromSlot = i;
          break;
        }
      }
    }

    if (fromSlot == -1) return;

    _history.add(state.copyWith());

    final newColors = List<Color>.from(state.currentColors);
    final temp = newColors[targetSlot];
    newColors[targetSlot] = newColors[fromSlot];
    newColors[fromSlot] = temp;

    bool solved = _checkSolved(newColors);
    state = state.copyWith(
      currentColors: newColors,
      isSolved: solved,
      hintsRemaining: state.hintsRemaining - 1,
      clearSelection: true,
    );
  }

  void undo() {
    if (_history.isNotEmpty) {
      state = _history.removeLast();
    }
  }

  void swapTiles(int fromIndex, int toIndex) {
    if (state.isSolved) return;
    if (fromIndex == toIndex) return;
    if (state.level.fixedIndices.contains(fromIndex) ||
        state.level.fixedIndices.contains(toIndex)) {
      return;
    }

    _history.add(state.copyWith());

    final newColors = List<Color>.from(state.currentColors);
    final temp = newColors[fromIndex];
    newColors[fromIndex] = newColors[toIndex];
    newColors[toIndex] = temp;

    bool solved = _checkSolved(newColors);
    state = state.copyWith(
      currentColors: newColors,
      isSolved: solved,
      clearSelection: true,
    );
  }

  void selectTile(int index) {
    if (state.isSolved) return;
    if (state.level.fixedIndices.contains(index)) return;

    if (state.selectedIndex == null) {
      state = state.copyWith(selectedIndex: index);
    } else if (state.selectedIndex == index) {
      state = state.copyWith(clearSelection: true);
    } else {
      swapTiles(state.selectedIndex!, index);
    }
  }

  bool _checkSolved(List<Color> current) {
    for (int i = 0; i < current.length; i++) {
      if (current[i].r != state.level.solution[i].r ||
          current[i].g != state.level.solution[i].g ||
          current[i].b != state.level.solution[i].b) {
        return false;
      }
    }
    return true;
  }
}
