import 'dart:math';
import 'package:flutter/material.dart';

enum HueSortDifficulty { easy, medium, hard, expert }

class HueSortLevel {
  final int size;
  final List<Color> colors;
  final List<Color> solution;
  final List<int> fixedIndices;
  final HueSortDifficulty difficulty;

  HueSortLevel({
    required this.size,
    required this.colors,
    required this.solution,
    required this.fixedIndices,
    this.difficulty = HueSortDifficulty.easy,
  });
}

class HueSortEngine {
  static const List<int> bossLevels = [5, 15, 30, 50, 75, 100];

  static bool isBossLevel(int level) => bossLevels.contains(level);

  static int sizeForLevel(int level) {
    if (level <= 5) return 3;
    if (level <= 15) return 4;
    if (level <= 30) return 5;
    if (level <= 50) return 6;
    if (level <= 75) return 7;
    if (level <= 100) return 8;
    if (level <= 130) return 9;
    return 10;
  }

  static HueSortDifficulty difficultyForLevel(int level) {
    if (isBossLevel(level)) {
      return HueSortDifficulty.expert;
    }

    if (level <= 5) {
      if (level <= 2) return HueSortDifficulty.easy;
      return HueSortDifficulty.medium;
    } else if (level <= 15) {
      final sub = level - 5;
      if (sub <= 2) return HueSortDifficulty.easy;
      if (sub <= 6) return HueSortDifficulty.medium;
      return HueSortDifficulty.hard;
    } else if (level <= 30) {
      final sub = level - 15;
      if (sub <= 3) return HueSortDifficulty.easy;
      if (sub <= 9) return HueSortDifficulty.medium;
      return HueSortDifficulty.hard;
    } else if (level <= 50) {
      final sub = level - 30;
      if (sub <= 4) return HueSortDifficulty.easy;
      if (sub <= 12) return HueSortDifficulty.medium;
      return HueSortDifficulty.hard;
    } else {
      final cycle = level % 10;
      if (cycle == 1 || cycle == 2) return HueSortDifficulty.easy;
      if (cycle <= 6) return HueSortDifficulty.medium;
      if (cycle <= 8) return HueSortDifficulty.hard;
      return HueSortDifficulty.expert;
    }
  }

  HueSortLevel generateLevel({
    int? level,
    int? size,
    HueSortDifficulty? difficulty,
    bool isRandom = false,
  }) {
    final gridSize = size ?? (level != null ? sizeForLevel(level) : 4);
    final diff = difficulty ?? (level != null ? difficultyForLevel(level) : HueSortDifficulty.medium);
    final random = isRandom ? Random() : Random(level ?? 1);

    final corners = _generateCornerColors(diff, random);

    List<Color> solution = List.filled(gridSize * gridSize, Colors.black);

    for (int y = 0; y < gridSize; y++) {
      double tY = y / (gridSize - 1);
      for (int x = 0; x < gridSize; x++) {
        double tX = x / (gridSize - 1);
        solution[y * gridSize + x] = _bilinearInterpolate(
          corners[0],
          corners[1],
          corners[2],
          corners[3],
          tX,
          tY,
        );
      }
    }

    final fixedIndices = [0, gridSize - 1, gridSize * (gridSize - 1), gridSize * gridSize - 1];

    List<int> movableIndices = [];
    for (int i = 0; i < gridSize * gridSize; i++) {
      if (!fixedIndices.contains(i)) movableIndices.add(i);
    }

    List<Color> shuffled = List.from(solution);
    List<int> shuffledIndices = List.from(movableIndices)..shuffle(random);

    bool allSame = true;
    for (int i = 0; i < movableIndices.length; i++) {
      if (shuffledIndices[i] != movableIndices[i]) {
        allSame = false;
        break;
      }
    }
    if (allSame && movableIndices.length > 1) {
      final first = shuffledIndices[0];
      shuffledIndices[0] = shuffledIndices[1];
      shuffledIndices[1] = first;
    }

    for (int i = 0; i < movableIndices.length; i++) {
      shuffled[movableIndices[i]] = solution[shuffledIndices[i]];
    }

    return HueSortLevel(
      size: gridSize,
      colors: shuffled,
      solution: solution,
      fixedIndices: fixedIndices,
      difficulty: diff,
    );
  }

  static Color _bilinearInterpolate(
    Color topLeft,
    Color topRight,
    Color bottomLeft,
    Color bottomRight,
    double tx,
    double ty,
  ) {
    double r = (1 - tx) * (1 - ty) * topLeft.r +
        tx * (1 - ty) * topRight.r +
        (1 - tx) * ty * bottomLeft.r +
        tx * ty * bottomRight.r;
    double g = (1 - tx) * (1 - ty) * topLeft.g +
        tx * (1 - ty) * topRight.g +
        (1 - tx) * ty * bottomLeft.g +
        tx * ty * bottomRight.g;
    double b = (1 - tx) * (1 - ty) * topLeft.b +
        tx * (1 - ty) * topRight.b +
        (1 - tx) * ty * bottomLeft.b +
        tx * ty * bottomRight.b;

    return Color.from(
      alpha: 1.0,
      red: r.clamp(0.0, 1.0),
      green: g.clamp(0.0, 1.0),
      blue: b.clamp(0.0, 1.0),
    );
  }

  static List<Color> _generateCornerColors(HueSortDifficulty difficulty, Random random) {
    final baseHue = random.nextDouble() * 360;

    switch (difficulty) {
      case HueSortDifficulty.easy:
        final h1 = baseHue;
        final h2 = (baseHue + 70 + random.nextDouble() * 30) % 360;
        final h3 = (baseHue + 150 + random.nextDouble() * 30) % 360;
        final h4 = (baseHue + 230 + random.nextDouble() * 40) % 360;
        return [
          HSVColor.fromAHSV(1.0, h1, 0.75 + random.nextDouble() * 0.2, 0.85 + random.nextDouble() * 0.15).toColor(),
          HSVColor.fromAHSV(1.0, h2, 0.75 + random.nextDouble() * 0.2, 0.85 + random.nextDouble() * 0.15).toColor(),
          HSVColor.fromAHSV(1.0, h3, 0.75 + random.nextDouble() * 0.2, 0.85 + random.nextDouble() * 0.15).toColor(),
          HSVColor.fromAHSV(1.0, h4, 0.75 + random.nextDouble() * 0.2, 0.85 + random.nextDouble() * 0.15).toColor(),
        ];

      case HueSortDifficulty.medium:
        final span = 80.0 + random.nextDouble() * 30.0;
        final sat = 0.65 + random.nextDouble() * 0.25;
        final val = 0.75 + random.nextDouble() * 0.2;
        return [
          HSVColor.fromAHSV(1.0, baseHue, sat, val).toColor(),
          HSVColor.fromAHSV(1.0, (baseHue + span * 0.5) % 360, (sat * 0.85).clamp(0.4, 0.95), (val * 1.1).clamp(0.4, 0.98)).toColor(),
          HSVColor.fromAHSV(1.0, (baseHue + span * 0.3) % 360, (sat * 1.1).clamp(0.4, 0.98), (val * 0.8).clamp(0.4, 0.95)).toColor(),
          HSVColor.fromAHSV(1.0, (baseHue + span) % 360, (sat * 0.95).clamp(0.4, 0.95), (val * 0.95).clamp(0.4, 0.95)).toColor(),
        ];

      case HueSortDifficulty.hard:
        final span = 35.0 + random.nextDouble() * 20.0;
        final sat = 0.6 + random.nextDouble() * 0.25;
        final val = 0.7 + random.nextDouble() * 0.2;
        return [
          HSVColor.fromAHSV(1.0, baseHue, sat, val).toColor(),
          HSVColor.fromAHSV(1.0, (baseHue + span * 0.6) % 360, (sat - 0.12).clamp(0.35, 0.95), (val + 0.12).clamp(0.35, 0.98)).toColor(),
          HSVColor.fromAHSV(1.0, (baseHue + span * 0.4) % 360, (sat + 0.12).clamp(0.35, 0.98), (val - 0.12).clamp(0.35, 0.95)).toColor(),
          HSVColor.fromAHSV(1.0, (baseHue + span) % 360, sat, val).toColor(),
        ];

      case HueSortDifficulty.expert:
        final span = 15.0 + random.nextDouble() * 10.0;
        final sat = 0.65 + random.nextDouble() * 0.2;
        final val = 0.75 + random.nextDouble() * 0.15;
        return [
          HSVColor.fromAHSV(1.0, baseHue, sat, val).toColor(),
          HSVColor.fromAHSV(1.0, (baseHue + span * 0.5) % 360, (sat - 0.08).clamp(0.4, 0.95), (val + 0.08).clamp(0.4, 0.98)).toColor(),
          HSVColor.fromAHSV(1.0, (baseHue + span * 0.5) % 360, (sat + 0.08).clamp(0.4, 0.98), (val - 0.08).clamp(0.4, 0.95)).toColor(),
          HSVColor.fromAHSV(1.0, (baseHue + span) % 360, sat, val).toColor(),
        ];
    }
  }
}
