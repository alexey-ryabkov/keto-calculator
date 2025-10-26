import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keto_calculator/core/data/firebase.dart';
import 'package:keto_calculator/core/models/meal.dart';
import 'package:keto_calculator/core/models/nutrition.dart';

class AddMealForm extends StatefulWidget {
  const AddMealForm({
    required this.onAdd,
    super.key,
  });
  final void Function(Meal meal) onAdd;

  @override
  State<AddMealForm> createState() => _AddMealFormState();
}

class _AddMealFormState extends State<AddMealForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _kcalCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  ConsumableItem? _consumable;
  bool _canSubmit = false;
  bool _suppressKcalListener = false;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _proteinCtrl.addListener(_onNutrientChanged);
    _fatCtrl.addListener(_onNutrientChanged);
    _carbCtrl.addListener(_onNutrientChanged);
    _kcalCtrl.addListener(_onKcalChanged);
    _weightCtrl.addListener(_updateCanSubmit);
    // _nameCtrl.addListener(_updateCanSubmit);
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
              Text('Add meal', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                    image: _pickedImage != null
                        ? DecorationImage(
                            image: FileImage(_pickedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: _pickedImage == null
                      ? const Text('Tap to select image')
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                // validator: (v) =>
                //     (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _proteinCtrl,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter protein';
                  return _parseNonNegative(v) == null ? 'Must be ≥ 0' : null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fatCtrl,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter fat';
                  return _parseNonNegative(v) == null ? 'Must be ≥ 0' : null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _carbCtrl,
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter carbs';
                  return _parseNonNegative(v) == null ? 'Must be ≥ 0' : null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _kcalCtrl,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter calories';
                  return _parseNonNegative(v) == null ? 'Must be ≥ 0' : null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightCtrl,
                decoration: const InputDecoration(labelText: 'Weight (g)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter weight';
                  return _parsePositive(v) == null ? 'Must be > 0' : null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _add : null,
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

  // TODO preloader for button
  Future<void> _add() async {
    final weight = _parsePositive(_weightCtrl.text);
    if (!_formKey.currentState!.validate() ||
        _consumable == null ||
        weight == null) {
      return;
    }
    String? savedImg;
    final pickedImgPath = _pickedImage?.path;
    if (pickedImgPath != null) {
      savedImg = await saveFile(pickedImgPath);
    }
    final name = _nameCtrl.text.trim();
    final meal = Meal.fromConsumable(
      _consumable!,
      name: name.isNotEmpty ? name : null,
      created: DateTime.now(),
      weightGrams: weight,
      photo: savedImg,
    );
    widget.onAdd(meal);
  }

  // TODO preloader for load image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _pickedImage = File(picked.path));
  }

  void _onNutrientChanged() {
    final p = _parseNonNegative(_proteinCtrl.text);
    final f = _parseNonNegative(_fatCtrl.text);
    final c = _parseNonNegative(_carbCtrl.text);

    if (p != null && f != null && c != null) {
      _consumable = ConsumableItem(proteins: p, fats: f, carbs: c);
      final kcalValue = _consumable!.kcal;
      _suppressKcalListener = true;
      _kcalCtrl.text = _formatNumber(kcalValue);
      _suppressKcalListener = false;
    } else {
      _consumable = null;
    }
    _updateCanSubmit();
  }

  void _onKcalChanged() {
    if (_suppressKcalListener || _consumable == null) return;
    final kcal = _parseNonNegative(_kcalCtrl.text);
    if (kcal != null) {
      _consumable!.kcal = kcal;
    }
    _updateCanSubmit();
  }

  void _updateCanSubmit() {
    final weight = _parsePositive(_weightCtrl.text);
    // final nameOk = _nameC.text.trim().isNotEmpty;
    final canSubmit = _consumable != null && weight != null;
    if (canSubmit != _canSubmit) setState(() => _canSubmit = canSubmit);
  }

  double? _parseNonNegative(String s) {
    final v = double.tryParse(s.replaceAll(',', '.'));
    if (v == null) return null;
    return v >= 0 ? v : null;
  }

  double? _parsePositive(String s) {
    final v = double.tryParse(s.replaceAll(',', '.'));
    if (v == null) return null;
    return v > 0 ? v : null;
  }

  String _formatNumber(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _kcalCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    _carbCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }
}
