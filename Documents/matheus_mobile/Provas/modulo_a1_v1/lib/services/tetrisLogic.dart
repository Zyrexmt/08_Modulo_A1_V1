import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum Tetromino { T, S, I, L }

class TetrisPiece {
  Tetromino type;
  List<int> position = [];
  Color color;

  static const int colCount = 6;

  TetrisPiece(this.type, {int? spawnCol}) : color = _colorFor(type) {
    initPosition(spawnCol: spawnCol);
  }

  static Color _colorFor(Tetromino type) {
    switch (type) {
      case Tetromino.T:
        return const Color(0xffd81b60);
      case Tetromino.S:
        return const Color(0xff388e3c);
      case Tetromino.I:
        return const Color(0xffe64a19);
      case Tetromino.L:
        return const Color(0xff1e88e5);
    }
  }

  void initPosition({int? spawnCol}) {
    final rng = Random();
    switch (type) {
      case Tetromino.T:
        final col = spawnCol ?? rng.nextInt(colCount - 2);
        position = [
          col + 1,
          col + colCount,
          col + colCount + 1,
          col + colCount + 2,
        ];
        break;
      case Tetromino.S:
        final col = spawnCol ?? rng.nextInt(colCount - 1);
        position = [
          col + 1,
          col + colCount,
          col + colCount + 1,
          col + colCount * 2,
        ];
        break;
      case Tetromino.I:
        final col = spawnCol ?? rng.nextInt(colCount);
        position = [
          col + 2,
          col + colCount + 2,
          col + colCount * 2 + 2,
          col + colCount * 3 + 2,
        ];
        break;
      case Tetromino.L:
        final col = spawnCol ?? rng.nextInt(colCount - 2);
        position = [
          col + 2,
          col + colCount,
          col + colCount + 1,
          col + colCount + 2,
        ];
        break;
    }
  }
}

class TetrisGameProvider with ChangeNotifier {
  static const int rowCount = 10;
  static const int colCount = 6;
  static int totalCells = rowCount * colCount;

  List<Color?> grid = List.generate(totalCells, (_) => null);
  TetrisPiece? currentPiece;
  int score = 0;
  bool isGameOver = false;
  Timer? _gameTimer;

  int _tickMs = 500;

  void startGame() {
    grid = List.generate(totalCells, (_) => null);
    score = 0;
    isGameOver = false;
    currentPiece = null;
    _createNewPiece();
    _startTimer(500);
  }

  void _startTimer(int ms) {
    _gameTimer?.cancel();
    _tickMs = ms;
    _gameTimer = Timer.periodic(Duration(milliseconds: ms), (_) {
      moveDown();
    });
  }

  void setFastDrop(bool fast) {
    int target = fast ? 1000 : 500;
    if (_tickMs != target) _startTimer(target);
  }

  static const int spawnOffset = -colCount;

  void _createNewPiece() {
    final types = Tetromino.values;
    currentPiece = TetrisPiece(types[Random().nextInt(types.length)]);

    currentPiece!.position = currentPiece!.position
        .map((p) => p + spawnOffset)
        .toList();

    for (int pos in currentPiece!.position) {
      if (pos >= 0 && pos < totalCells && grid[pos] != null) {
        isGameOver = true;
        _gameTimer?.cancel();
        notifyListeners();
        return;
      }
    }
    notifyListeners();
  }

  void moveLeft() {
    if (currentPiece == null || isGameOver) return;
    if (_canMoveHorizontal(-1)) {
      for (int i = 0; i < currentPiece!.position.length; i++) {
        currentPiece!.position[i]--;
      }
      notifyListeners();
    }
  }

  void moveRight() {
    if (currentPiece == null || isGameOver) return;
    if (_canMoveHorizontal(1)) {
      for (int i = 0; i < currentPiece!.position.length; i++) {
        currentPiece!.position[i]++;
      }
      notifyListeners();
    }
  }

  void moveDown() {
    if (currentPiece == null || isGameOver) return;
    if (_canMoveDown()) {
      for (int i = 0; i < currentPiece!.position.length; i++) {
        currentPiece!.position[i] += colCount;
      }
    } else {
      _landPiece();
    }
    notifyListeners();
  }

  bool _canMoveDown() {
    for (int pos in currentPiece!.position) {
      int next = pos + colCount;
      if (next >= totalCells) return false;
      if (next >= 0 && grid[next] != null) return false;
    }
    return true;
  }

  bool _canMoveHorizontal(int dir) {
    for (int pos in currentPiece!.position) {
      if (dir == -1 && pos % colCount == 0) return false;
      if (dir == 1 && pos % colCount == colCount - 1) return false;
      int next = pos + dir;
      if (next >= 0 && next < totalCells && grid[next] != null) {
        return false;
      }
    }
    return true;
  }

  bool _checkCollision() {
    for (int pos in currentPiece!.position) {
      if (pos >= 0 && pos < totalCells && grid[pos] != null) {
        return true;
      }
    }
    return false;
  }

  void _landPiece() {
    for (int pos in currentPiece!.position) {
      if (pos >= 0 && pos < totalCells) {
        grid[pos] = currentPiece!.color;
      }
    }
    score += 1;
    _createNewPiece();
  }

  void stopGame() {
    _gameTimer?.cancel();
    isGameOver = true;
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void resetGame() {
    grid = List.generate(totalCells, (_) => null);
    currentPiece = null;
    score = 0;
    isGameOver = false;

    notifyListeners();
  }
}
