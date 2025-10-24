import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/app/view/main_shell.dart';
import 'package:keto_calculator/features/profile/bloc/profile_bloc.dart';
import 'package:keto_calculator/features/profile/bloc/profile_state.dart';

ThemeData _theme([Brightness? brightness]) => ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.lightGreenAccent,
  brightness: brightness,
);

class App extends StatelessWidget {
  const App(this.env, {super.key});
  final String env;

  @override
  Widget build(_) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, _) {
        final themeMode = context.read<ProfileBloc>().prefThemeMode;
        return MaterialApp(
          title: 'Keto Calculator',
          theme: _theme(),
          darkTheme: _theme(Brightness.dark),
          themeMode: themeMode,
          home: const MainShell(),
        );
      },
    );
  }
}
