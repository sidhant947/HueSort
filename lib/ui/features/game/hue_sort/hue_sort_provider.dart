import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hue_sort_engine.dart';

class HueSortState {
  final HueSortLevel level;
  final List<Color> currentColors;
  final int? selectedIndex;
  final bool isSolved;

  HueSortState({
    required this.level,
    required this.currentColors,
    this.selectedIndex,
    this.isSolved = false,
  });

  HueSortState copyWith({
    HueSortLevel? level,
    List<Color>? currentColors,
    int? selectedIndex,
    bool? isSolved,
    bool clearSelection = false,
  }) {
    return HueSortState(
      level: level ?? this.level,
      currentColors: currentColors ?? this.currentColors,
      selectedIndex: clearSelection ? null : (selectedIndex ?? this.selectedIndex),
      isSolved: isSolved ?? this.isSolved,
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

  static HueSortState _initialState() {
    final engine = HueSortEngine();
    final level = engine.generateLevel();
    return HueSortState(
      level: level,
      currentColors: List.from(level.colors),
    );
  }

  void initGame(int levelNumber) {
    _history.clear();
    final level = _engine.generateLevel(level: levelNumber);
    state = HueSortState(
      level: level,
      currentColors: List.from(level.colors),
    );
  }

  void newGame() {
    _history.clear();
    final level = _engine.generateLevel(level: state.level.size);
    state = HueSortState(
      level: level,
      currentColors: List.from(level.colors),
      isSolved: false,
    );
  }

  void undo() {
    if (_history.isNotEmpty) {
      state = _history.removeLast();
    }
  }

  void selectTile(int index) {
    if (state.isSolved) return;
    if (state.level.fixedIndices.contains(index)) return;

    if (state.selectedIndex == null) {
      state = state.copyWith(selectedIndex: index);
    } else if (state.selectedIndex == index) {
      state = state.copyWith(clearSelection: true);
    } else {
      _history.add(state.copyWith());

      final newColors = List<Color>.from(state.currentColors);
      final temp = newColors[state.selectedIndex!];
      newColors[state.selectedIndex!] = newColors[index];
      newColors[index] = temp;

      bool solved = _checkSolved(newColors);
      state = state.copyWith(
        currentColors: newColors,
        isSolved: solved,
        clearSelection: true,
      );
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
