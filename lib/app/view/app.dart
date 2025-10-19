import 'package:flutter/material.dart';
import 'package:keto_calculator/app/view/main_shell.dart';

class App extends StatelessWidget {
  const App(this.env, {super.key});
  final String env;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keto Calculator',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.lightGreenAccent,
      ),
      home: const MainShell(),
    );
  }
}
