// features/profile/view/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keto_calculator/core/models/app_user.dart';
import 'package:keto_calculator/core/models/profile.dart';
import 'package:keto_calculator/features/profile/bloc/profile_bloc.dart';
import 'package:keto_calculator/features/profile/bloc/profile_state.dart';
// import 'package:keto_calculator/features/profile/data/profile_repository.dart';

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
  String _lifestyle = 'sedentary';
  String _dietType = 'notKeto';

  final List<Map<String, String>> _lifestyleOptions = [
    {'value': 'sedentary', 'label': 'Sedentary'},
    {'value': 'lightlyActive', 'label': 'Lightly active'},
    {'value': 'active', 'label': 'Moderately active'},
    {'value': 'veryActive', 'label': 'Very active'},
  ];

  final List<Map<String, String>> _dietOptions = [
    {'value': 'notKeto', 'label': 'Not keto'},
    {'value': 'keto', 'label': 'Keto'},
    {'value': 'strictKeto', 'label': 'Strict keto'},
  ];

  bool _initializedFromState = false;

  @override
  void initState() {
    super.initState();
    // context.read<ProfileBloc>().init()
  }

  @override
  void dispose() {
    _nicknameC.dispose();
    _weightC.dispose();
    _heightC.dispose();
    super.dispose();
  }

  // Future<void> _pickDate() async {
  //   final now = DateTime.now();
  //   final first = DateTime(1900);
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: _birthdate ?? DateTime(now.year - 25),
  //     firstDate: first,
  //     lastDate: now,
  //     locale: const Locale('ru'),
  //   );
  //   if (picked != null) {
  //     setState(() => _birthdate = picked);
  //   }
  // }

  Future<void> _onSave(ProfileState state) async {
    // FIXME
    if (!_formKey.currentState!.validate() || _birthdate == null) return;

    final sex = _sexIndex == 0 ? Sex.male : Sex.female;
    final profile = Profile(
      userId: AppUser.instance.id,
      nickname: _nicknameC.text.trim(),
      birthdate: _birthdate!,
      sex: sex,
      weightKg: double.parse(_weightC.text.replaceAll(',', '.')),
      heightCm: double.parse(_heightC.text.replaceAll(',', '.')),
      lifestyle: _lifestyleFromValue(_lifestyle),
      dietType: _dietTypeFromValue(_dietType),
    );

    final cubit = context.read<ProfileBloc>();

    if (state.status == ProfileStatus.none || state.profile == null) {
      await cubit.create(profile);
    } else {
      await cubit.save(profile);
    }
  }

  Lifestyle _lifestyleFromValue(String v) {
    return Lifestyle.values.firstWhere(
      (e) => e.name == v,
      orElse: () => Lifestyle.sedentary,
    );
  }
  // Lifestyle _lifestyleFromLabel(String label) {
  //   return Lifestyle.values.firstWhere(
  //     (e) =>
  //         e.name.replaceAll(RegExp(r'([A-Z])'), ' ').trim().toLowerCase() ==
  //         label.toLowerCase(),
  //     orElse: () => Lifestyle.sedentary,
  //   );
  // }

  DietType _dietTypeFromValue(String v) {
    return DietType.values.firstWhere(
      (e) => e.name == v,
      orElse: () => DietType.notKeto,
    );
  }

  void _populateFormFromProfile(Profile p) {
    _nicknameC.text = p.nickname;
    _birthdate = p.birthdate;
    _sexIndex = p.sex == Sex.male ? 0 : 1;
    _weightC.text = p.weightKg.toString();
    _heightC.text = p.heightCm.toString();
    // _lifestyle = p.lifestyle.name == ''
    //     ? _lifestyleOptions.first
    //     : _titleFromLifestyle(p.lifestyle);
    _lifestyle = p.lifestyle.name;
    _dietType = p.dietType.name;
  }

  // String _titleFromLifestyle(Lifestyle l) {
  //   switch (l) {
  //     case Lifestyle.sedentary:
  //       return 'Sedentary';
  //     case Lifestyle.lightlyActive:
  //       return 'Lightly active';
  //     case Lifestyle.active:
  //       return 'Moderately active';
  //     case Lifestyle.veryActive:
  //       return 'Very active';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..init(),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.error ?? 'unknown'}')),
            );
          } else if (state.status == ProfileStatus.saving) {
            // TODO show saving indicator?
          } else if (state.status == ProfileStatus.ready) {
            if (!_initializedFromState && state.profile != null) {
              _populateFormFromProfile(state.profile!);
              _initializedFromState = true;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Профиль сохранён')),
            );
          } else if (state.status == ProfileStatus.none) {
            if (!_initializedFromState) {
              _nicknameC.text = '';
              _birthdate = null;
              _sexIndex = 0;
              _weightC.text = '';
              _heightC.text = '';
              _lifestyle = _lifestyleOptions.first['value']!;
              _dietType = _dietOptions.first['value']!;
              _initializedFromState = true;
            }
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<ProfileBloc>().reload();
            },
            child: SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Profile'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => context.read<ProfileBloc>().reload(),
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        TextFormField(
                          controller: _nicknameC,
                          decoration: const InputDecoration(
                            labelText: 'Nickname',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Введите nickname'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _birthdate == null
                                ? ''
                                : DateFormat('dd.MM.yyyy').format(_birthdate!),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Birthdate',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (v) => _birthdate == null
                              ? 'Select your birthdate'
                              : null,
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  _birthdate ?? DateTime(now.year - 25),
                              firstDate: DateTime(1900),
                              lastDate: now,
                              locale: const Locale('en'),
                            );
                            if (picked != null) {
                              setState(() => _birthdate = picked);
                            }
                          },
                        ),
                        /* InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(4),
                          child: InputDecorator(
                            isFocused: false,
                            decoration: const InputDecoration(
                              labelText: 'Birthdate',
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _birthdate == null
                                      ? 'Select date'
                                      : DateFormat(
                                          'dd.MM.yyyy',
                                        ).format(_birthdate!),
                                ),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ), */
                        const SizedBox(height: 12),
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
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Введите вес';
                                  }
                                  final n = double.tryParse(
                                    v.replaceAll(',', '.'),
                                  );
                                  if (n == null || n <= 0) {
                                    return 'Неверный вес';
                                  }
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
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Введите рост';
                                  }
                                  final n = double.tryParse(
                                    v.replaceAll(',', '.'),
                                  );
                                  if (n == null || n <= 0) {
                                    return 'Неверный рост';
                                  }
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
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m['value'],
                                  child: Text(m['label']!),
                                ),
                              )
                              .toList(),
                          // items: _lifestyleOptions
                          //     .map(
                          //       (s) =>
                          //           DropdownMenuItem(value: s, child: Text(s)),
                          //     )
                          //     .toList(),
                          onChanged: (v) => setState(
                            () => _lifestyle =
                                v ?? _lifestyleOptions.first['value']!,
                          ),
                          // onChanged: (v) => setState(
                          //   () => _lifestyle = v ?? _lifestyleOptions.first,
                          // ),
                          decoration: const InputDecoration(
                            labelText: 'Lifestyle',
                          ),
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
                          decoration: const InputDecoration(
                            labelText: 'Diet type',
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _onSave(
                            state,
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
