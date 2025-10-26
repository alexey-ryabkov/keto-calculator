import 'package:flutter/material.dart';
import 'package:keto_calculator/core/models/journal_entry.dart';

class JournalEntryForm extends StatefulWidget {
  const JournalEntryForm({
    // required this.selectedDate,
    required this.onSubmit,
    super.key,
  });
  // final DateTime selectedDate;
  final void Function(JournalEntry entry) onSubmit;

  @override
  State<JournalEntryForm> createState() => _JournalEntryFormState();
}

class _JournalEntryFormState extends State<JournalEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _kcalC = TextEditingController();
  final _proteinC = TextEditingController();
  final _fatC = TextEditingController();
  final _carbC = TextEditingController();

  @override
  void dispose() {
    _titleC.dispose();
    _kcalC.dispose();
    _proteinC.dispose();
    _fatC.dispose();
    _carbC.dispose();
    super.dispose();
  }

  void _add() {
    if (!_formKey.currentState!.validate()) return;
    final e = JournalEntry.fromJson({
      'datetime': DateTime.now(), // widget.date.toIso8601String(),
      'title': _titleC.text.trim(),
      'kcal': double.tryParse(_kcalC.text.replaceAll(',', '.')) ?? 0.0,
      'proteins': double.tryParse(_proteinC.text.replaceAll(',', '.')) ?? 0.0,
      'fats': double.tryParse(_fatC.text.replaceAll(',', '.')) ?? 0.0,
      'carbs': double.tryParse(_carbC.text.replaceAll(',', '.')) ?? 0.0,
      'weightGrams': null,
      'id': null,
    });
    widget.onSubmit(e);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add entry', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleC,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter title' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _proteinC,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter protein' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fatC,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter fat' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _carbC,
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter carbs' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _kcalC,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter calories' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _add,
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
