import 'package:flutter/material.dart';
import 'package:modulo_a1_v1/pages/gamePage.dart';
import 'package:modulo_a1_v1/pages/homePage.dart';
import 'package:modulo_a1_v1/pages/rankingPage.dart';
import 'package:modulo_a1_v1/pages/splashScreeen.dart';
import 'package:modulo_a1_v1/services/tetrisLogic.dart';
import 'package:provider/provider.dart';

class AppControllwe extends StatelessWidget {
  const AppControllwe({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TetrisGameProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/home': (context) => const HomePage(),
          '/rank': (context) => const RankPage(),
          '/game': (context) => const GamePage(),
        },
        initialRoute: '/splash',
      ),
    );
  }
}

String globalName = '';
