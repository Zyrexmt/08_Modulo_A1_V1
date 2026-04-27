import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modulo_a1_v1/appController.dart';
import 'package:modulo_a1_v1/services/rankingEntry.dart';
import 'package:modulo_a1_v1/services/tetrisLogic.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _countdown = 3;
  bool _gameStarted = false;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _currentX = 0;
  double _currentY = 0;
  double _baseX = 0;
  double _baseY = 0;
  bool _baselineCaptured = false;
  Timer? _inputTimer;
  bool _dialogShown = false;
  bool _disposed = false;

  String _playerName = globalName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) _playerName = args;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCountdown();
    });
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown == 1) {
        timer.cancel();
        setState(() {
          _gameStarted = true;
          _countdown = 0;
        });
        _startGame();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _startGame() {
    final game = Provider.of<TetrisGameProvider>(
      context,
      listen: false,
    );
    game.startGame();

    _accelSub = accelerometerEventStream().listen((event) {
      if (!_baselineCaptured) {
        _baseX = event.x;
        _baseY = event.y;
        _baselineCaptured = true;
      }
      _currentX = event.x;
      _currentY = event.y;
    });

    _inputTimer = Timer.periodic(const Duration(milliseconds: 250), (
      _,
    ) {
      if (!_gameStarted || !_baselineCaptured) return;
      final g = Provider.of<TetrisGameProvider>(
        context,
        listen: false,
      );

      final dx = _currentX - _baseX;
      final dy = _currentY - _baseY;
      if (dx > 2.0)
        g.moveLeft();
      else if (dx < -2.0)
        g.moveRight();

      g.setFastDrop(dy < -3.0);
    });
  }

  Future<void> _saveAndExit(int score) async {
    _accelSub?.cancel();
    _inputTimer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    final String? existing = prefs.getString('ranking');
    List<RankingEntry> list = [];

    if (existing != null) {
      final jsonList = jsonDecode(existing) as List<dynamic>;
      list = jsonList.map((e) => RankingEntry.fromJson(e)).toList();
    }

    final name = _playerName.trim().isEmpty
        ? 'Anônimo'
        : _playerName.trim();

    list.add(RankingEntry(playerName: name, score: score));
    await prefs.setString(
      'ranking',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );

    if (!mounted || _disposed) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _onEncerrar() {
    final game = Provider.of<TetrisGameProvider>(
      context,
      listen: false,
    );
    game.stopGame();
    _saveAndExit(game.score);
  }

  @override
  void dispose() {
    _disposed = true;
    _accelSub?.cancel();
    _inputTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<TetrisGameProvider>(
          builder: (context, game, _) {
            if (game.isGameOver && _gameStarted && !_dialogShown) {
              _dialogShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showGameOverDialog(game.score);
              });
            }

            return Column(
              children: [
                const SizedBox(height: 20),
                if (_countdown > 0)
                  Text(
                    '$_countdown',
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const Text(
                  'PONTUAÇÃO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xff333333),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${game.score.toString().padLeft(3, '0')} pts',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 240,
                      height: 400,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xff333333),
                          width: 2,
                        ),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 60,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                            ),
                        itemBuilder: (context, index) {
                          Color? cellColor = game.grid[index];

                          if (game.currentPiece != null &&
                              game.currentPiece!.position.contains(
                                index,
                              )) {
                            cellColor = game.currentPiece!.color;
                          }

                          return Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: cellColor ?? Colors.transparent,
                              border: Border.all(
                                color: const Color(0xffededed),
                                width: 0.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                _buildControlsHint(),
                const SizedBox(height: 20),

                _buildEncerraButton(),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlsHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [],
    );
  }

  Widget _hintItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        Text(
          text,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEncerraButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _onEncerrar,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff333333),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'ENCERRAR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showGameOverDialog(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Fim de Jogo'),
        content: Text('Sua pontuação: $score pts'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveAndExit(score);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
