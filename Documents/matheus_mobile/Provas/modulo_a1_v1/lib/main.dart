import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modulo_a1_v1/appController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);
  runApp(AppControllwe());
}
