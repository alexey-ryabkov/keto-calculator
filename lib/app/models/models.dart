import 'package:flutter/material.dart';

enum AppPage { tracking, menu, products, profile }

enum AppLanguage {
  en('English'),
  ru('Russian');

  const AppLanguage(this.label);
  final String label;
}

const AppLanguage defLang = AppLanguage.en;
const ThemeMode defThemeMode = ThemeMode.light;
