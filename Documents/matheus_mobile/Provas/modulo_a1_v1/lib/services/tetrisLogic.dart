import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum Tetromino { L, J, I, O, S, Z, T }

class TetrisPiece {
  Tetromino type;
  List<int> position = [];
  Color color;

  static const int colCount = 6;

  TetrisPiece(this.type) : color = _colorFor(type) {
    initPosition();
  }

  static Color _colorFor(Tetromino type) {
    switch (type) {
      case Tetromino.L:
        return Colors.orange;
      case Tetromino.J:
        return Colors.blue;
      case Tetromino.I:
        return Colors.cyan;
      case Tetromino.O:
        return Colors.yellow;
      case Tetromino.S:
        return Colors.green;
      case Tetromino.Z:
        return Colors.red;
      case Tetromino.T:
        return Colors.purple;
    }
  }

  void initPosition() {
    switch (type) {
      case Tetromino.L:
        position = [2, 8, 14, 15];
        break;
      case Tetromino.J:
        position = [2, 8, 14, 15];
        break;
      case Tetromino.I:
        position = [2, 8, 14, 15];
        break;
      case Tetromino.O:
        position = [2, 8, 14, 15];
        break;
      case Tetromino.S:
        position = [2, 8, 14, 15];
        break;
      case Tetromino.Z:
        position = [2, 8, 14, 15];
        break;
      case Tetromino.T:
        position = [2, 8, 14, 15];
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
    _gameTimer?.cancel;
    _tickMs = ms;
    _gameTimer = Timer.periodic(Duration(milliseconds: ms), (_) {
      moveDown();
    });
  }

  void setFastDrop(bool fast) {
    int target = fast ? 100 : 500;
    if (_tickMs != target) _startTimer(target);
  }

  void _createNewPiece() {
    final types = Tetromino.values;
    currentPiece = TetrisPiece(types[Random().nextInt(types.length)]);

    if (_checkCollision()) {
      isGameOver = true;
      _gameTimer?.cancel();
      notifyListeners();
    }
  }

  void moveLeft() {
    if (currentPiece == null || isGameOver) return;
    if (_canMove(-1)) {
      for (int i = 0; i < currentPiece!.position.length; i++) {
        currentPiece!.position[i]--;
      }
      notifyListeners();
    }
  }

  void moveRight() {
    if (currentPiece == null || isGameOver) return;
    if (_canMove(1)) {
      for (int i = 0; i < currentPiece!.position.length; i++) {
        currentPiece!.position[i] += colCount;
      }
    } else {
      _landPiece();
    }
    notifyListeners();
  }

  void moveDown() {
    if (currentPiece == null || isGameOver) return;
    if (_canMove(colCount)) {
      for (int i = 0; i < currentPiece!.position.length; i++) {
        currentPiece!.position[i] += colCount;
      }
    } else {
      _landPiece();
    }
    notifyListeners();
  }

  bool _canMove(int direction) {
    for (int pos in currentPiece!.position) {
      int next = pos + direction;

      if (next >= totalCells) return false;

      if (direction == -1 && pos % colCount == 0) return false;

      if (direction == 1 && (pos + 1) % colCount == 0) return false;

      if (next >= 0 && grid[next] != null) return false;
    }
    return true;
  }

  bool _checkCollision() {
    for (int pos in currentPiece!.position) {
      if (pos >= 0 && pos < totalCells && grid[pos] != null)
        return true;
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
}
