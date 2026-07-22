import 'dart:math';
import 'package:flutter/material.dart';

class HueSortLevel {
  final int size;
  final List<Color> colors;
  final List<Color> solution;
  final List<int> fixedIndices;

  HueSortLevel({
    required this.size,
    required this.colors,
    required this.solution,
    required this.fixedIndices,
  });
}

class HueSortEngine {
  static int sizeForLevel(int level) {
    return min(4 + (level - 1) ~/ 5, 10);
  }

  HueSortLevel generateLevel({int level = 1}) {
    final size = sizeForLevel(level);
    final random = Random(level);
    final corners = List.generate(4, (_) => Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    ));

    List<Color> solution = List.filled(size * size, Colors.black);

    for (int y = 0; y < size; y++) {
      double tY = y / (size - 1);
      for (int x = 0; x < size; x++) {
        double tX = x / (size - 1);

        final top = Color.lerp(corners[0], corners[1], tX)!;
        final bottom = Color.lerp(corners[2], corners[3], tX)!;
        solution[y * size + x] = Color.lerp(top, bottom, tY)!;
      }
    }

    final fixedIndices = [0, size - 1, size * (size - 1), size * size - 1];

    List<int> movableIndices = [];
    for (int i = 0; i < size * size; i++) {
      if (!fixedIndices.contains(i)) movableIndices.add(i);
    }

    List<Color> shuffled = List.from(solution);
    List<int> shuffledIndices = List.from(movableIndices)..shuffle(random);

    for (int i = 0; i < movableIndices.length; i++) {
      shuffled[movableIndices[i]] = solution[shuffledIndices[i]];
    }

    return HueSortLevel(
      size: size,
      colors: shuffled,
      solution: solution,
      fixedIndices: fixedIndices,
    );
  }
}
