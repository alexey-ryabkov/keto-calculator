import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameC = TextEditingController();
  DateTime? _birthdate;
  int _sexIndex = 0; // 0 = male, 1 = female
  final TextEditingController _weightC = TextEditingController();
  final TextEditingController _heightC = TextEditingController();
  String _lifestyle = 'Sedentary';
  String _dietType = 'not_keto';

  final List<String> _lifestyleOptions = [
    'Sedentary',
    'Lightly active',
    'Moderately active',
    'Very active',
  ];

  final List<Map<String, String>> _dietOptions = [
    {'value': 'not_keto', 'label': 'Not keto'},
    {'value': 'keto', 'label': 'Keto'},
    {'value': 'strict_keto', 'label': 'Strict keto'},
  ];

  @override
  void dispose() {
    _nicknameC.dispose();
    _weightC.dispose();
    _heightC.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(1900);
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime(now.year - 25),
      firstDate: first,
      lastDate: now,
      locale: const Locale('ru'),
    );
    if (picked != null) {
      setState(() => _birthdate = picked);
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final sex = _sexIndex == 0 ? 'male' : 'female';
    final summary = <String, dynamic>{
      'nickname': _nicknameC.text,
      'birthdate': _birthdate?.toIso8601String(),
      'sex': sex,
      'weight': _weightC.text,
      'height': _heightC.text,
      'lifestyle': _lifestyle,
      'diet': _dietType,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Сохранено: ${summary['nickname']}, ${summary['sex']}'),
      ),
    );

    // ...
  }

  @override
  Widget build(BuildContext context) {
    final birthText = _birthdate == null
        ? 'Выберите дату'
        : DateFormat('dd.MM.yyyy').format(_birthdate!);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nicknameC,
                  decoration: const InputDecoration(labelText: 'Nickname'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Введите nickname'
                      : null,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Birthdate'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(birthText),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Sex toggle (male/female)
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Sex'),
                  child: ToggleButtons(
                    isSelected: [_sexIndex == 0, _sexIndex == 1],
                    onPressed: (i) => setState(() => _sexIndex = i),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Male'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Female'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Введите вес';
                          final n = double.tryParse(v.replaceAll(',', '.'));
                          if (n == null || n <= 0) return 'Неверный вес';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _heightC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Введите рост';
                          final n = double.tryParse(v.replaceAll(',', '.'));
                          if (n == null || n <= 0) return 'Неверный рост';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _lifestyle,
                  items: _lifestyleOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _lifestyle = v ?? _lifestyleOptions.first),
                  decoration: const InputDecoration(labelText: 'Lifestyle'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _dietType,
                  items: _dietOptions
                      .map(
                        (m) => DropdownMenuItem(
                          value: m['value'],
                          child: Text(m['label']!),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(
                    () => _dietType = v ?? _dietOptions.first['value']!,
                  ),
                  decoration: const InputDecoration(labelText: 'Diet type'),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
