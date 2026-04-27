import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modulo_a1_v1/services/rankingEntry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  List<RankingEntry> _rankingList = [];

  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rankingData = prefs.getString('ranking');

    if (rankingData != null) {
      final List<dynamic> jsonList = jsonDecode(rankingData);
      setState(() {
        _rankingList = jsonList
            .map((e) => RankingEntry.fromJson(e))
            .toList();
        _rankingList.sort((a, b) => b.score.compareTo(a.score));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                'RANKING DE PONTUAÇÕES',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildTableHeader(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff333333),
                      width: 2,
                    ),
                  ),
                  child: _rankingList.isEmpty
                      ? const Center(
                          child: Text('NENHUMA PONTUAÇÃO AINDA'),
                        )
                      : ListView.separated(
                          itemCount: _rankingList.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: Color(0xff333333),
                          ),
                          itemBuilder: (context, index) {
                            final entry = _rankingList[index];
                            return _buildTableRow(
                              index + 1,
                              entry.playerName,
                              entry.score,
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 30),
              _buildBackButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xff333333), width: 2),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'POSIÇÃO',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'JOGADOR',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'PONTUAÇÃO',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(int pos, String name, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('${pos}º', textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 1,
            child: Text(name, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 1,
            child: Text('$score pts', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () =>
            Navigator.of(context).pushReplacementNamed('/home'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xffededed),
          foregroundColor: Color(0xff333333),
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: Color(0xff333334), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'VOLTAR À TELA INICIAL',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


