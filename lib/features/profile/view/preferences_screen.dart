import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/app/models/models.dart';
import 'package:keto_calculator/features/profile/bloc/profile_bloc.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  AppLanguage _language = defLang;
  bool _isThemeDark = defThemeMode == ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ProfileBloc>();
    setState(() {
      _language = bloc.prefLanguage;
      _isThemeDark = bloc.prefThemeMode == ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              5,
              3,
              0,
            ),
            child: Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.close),
                iconAlignment: IconAlignment.end,
                label: const Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _language.name,
                decoration: const InputDecoration(
                  labelText: 'Preferred language',
                ),
                items: AppLanguage.values
                    .map(
                      (lang) => DropdownMenuItem(
                        value: lang.name,
                        child: Text(lang.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(
                  () => _language = AppLanguage.values.byName(
                    v ?? defLang.name,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dark theme', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _isThemeDark,
                    onChanged: (v) => setState(() => _isThemeDark = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final bloc = context.read<ProfileBloc>();
    final theme = _isThemeDark ? ThemeMode.dark : ThemeMode.light;
    await bloc.updatePrefs(themeMode: theme, language: _language);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved')),
    );
  }
}
