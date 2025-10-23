// preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  String _language = 'en';
  bool _isDark = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('preferred_language') ?? 'en';
    final dark = prefs.getBool('dark_theme') ?? false;
    // TODO
    // (appThemeNotifier.value == ThemeMode.dark);
    setState(() {
      _language = lang;
      _isDark = dark;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', _language);
    await prefs.setBool('dark_theme', _isDark);
    // TODO
    // appThemeNotifier.value = _isDark ? ThemeMode.dark : ThemeMode.light;
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preferences saved')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _language,
                decoration: const InputDecoration(
                  labelText: 'Preferred language',
                ),
                items: const [
                  DropdownMenuItem(value: 'ru', child: Text('Russian')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (v) => setState(() => _language = v ?? 'en'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Dark theme'),
                value: _isDark,
                onChanged: (v) => setState(() => _isDark = v),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
