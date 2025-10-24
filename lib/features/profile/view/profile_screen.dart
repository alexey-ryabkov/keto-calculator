import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keto_calculator/core/models/app_user.dart';
import 'package:keto_calculator/core/models/profile.dart';
import 'package:keto_calculator/core/utils/utils.dart';
import 'package:keto_calculator/features/profile/bloc/profile_bloc.dart';
import 'package:keto_calculator/features/profile/bloc/profile_state.dart';
import 'package:keto_calculator/features/profile/view/preferences_screen.dart';

const _defAge = 25;
const _defFirstYear = 1900;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameCtrl = TextEditingController();
  final TextEditingController _birthdateCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();

  DateTime? _birthdate;
  Sex _sex = Sex.male;
  Lifestyle _lifestyle = Lifestyle.sedentary;
  DietType _dietType = DietType.notKeto;

  @override
  void initState() {
    super.initState();
    _initFields(context.read<ProfileBloc>().state);
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _birthdateCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      // when we suddenly got an error or when saving completed...
      listenWhen: (previous, current) =>
          current.status == ProfileStatus.error ||
          previous.status == ProfileStatus.saving &&
              previous.status != current.status,
      // ...show snack bar with a message
      listener: (context, state) {
        if (state.status == ProfileStatus.error) {
          _showError(state.error);
        } else {
          _showSaved();
        }
      },
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) =>
            previous.status == ProfileStatus.loading &&
            previous.status != current.status,
        listener: (context, state) {
          _initFields(state);
        },
        builder: (context, state) {
          final isSaving = state.status == ProfileStatus.saving;
          final isLoading =
              state.status == ProfileStatus.loading ||
              state.status == ProfileStatus.initial;
          return Scaffold(
            // appBar: AppBar(
            //   title: const Text('Profile'),
            //   actions: [
            //     TextButton.icon(
            //       icon: const Icon(Icons.settings),
            //       iconAlignment: IconAlignment.end,
            //       label: const Text('Preferences'),
            //       onPressed: _openPreferences,
            //     ),
            //   ],
            //   centerTitle: false,
            // ),
            appBar: AppBar(
              title: const Text('Profile'),
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
                      icon: const Icon(Icons.settings),
                      iconAlignment: IconAlignment.end,
                      label: const Text('Preferences'),
                      onPressed: _openPreferences,
                    ),
                  ),
                ),
              ],
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          TextFormField(
                            controller: _nicknameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nickname',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter nickname'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _birthdateCtrl,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Birthdate',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            validator: (_) => _birthdate == null
                                ? 'Select your birthdate'
                                : null,
                            onTap: _pickBirthdate,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ChoiceChip(
                                label: Text(Sex.male.label),
                                selected: _sex == Sex.male,
                                onSelected: (_) =>
                                    setState(() => _sex = Sex.male),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: Text(Sex.female.label),
                                selected: _sex == Sex.female,
                                onSelected: (_) =>
                                    setState(() => _sex = Sex.female),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _weightCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Weight (kg)',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Enter weight';
                                    }
                                    final n = double.tryParse(
                                      v.replaceAll(',', '.'),
                                    );
                                    if (n == null || n <= 0) {
                                      return 'Invalid weight';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _heightCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Height (cm)',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Enter height';
                                    }
                                    final n = double.tryParse(
                                      v.replaceAll(',', '.'),
                                    );
                                    if (n == null || n <= 0) {
                                      return 'Invalid height';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<Lifestyle>(
                            value: _lifestyle,
                            onChanged: (v) => setState(
                              () => _lifestyle = v ?? Lifestyle.sedentary,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Lifestyle',
                            ),
                            items: Lifestyle.values
                                .map(
                                  (lifestyle) => DropdownMenuItem(
                                    value: lifestyle,
                                    child: Text(lifestyle.label),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<DietType>(
                            value: _dietType,
                            items: DietType.values
                                .map(
                                  (dietType) => DropdownMenuItem(
                                    value: dietType,
                                    child: Text(dietType.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(
                              () => _dietType = v ?? DietType.notKeto,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Diet type',
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _save(state),
                            icon: SizedBox(
                              width: 24,
                              height: 24,
                              child: isSaving
                                  ? const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    )
                                  : const Icon(Icons.save),
                            ),
                            label: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Future<void> _save(ProfileState state) async {
    final form = _formKey.currentState!;
    if (!form.validate()) return;

    final bloc = context.read<ProfileBloc>();
    final profile = Profile(
      userId: AppUser.instance.id,
      nickname: _nicknameCtrl.text.trim(),
      birthdate: _birthdateCtrl.text.isNotEmpty
          ? DateFormat('dd.MM.yyyy').parse(_birthdateCtrl.text)
          : DateTime(DateTime.now().year - _defAge),
      sex: _sex,
      weightKg: double.tryParse(_weightCtrl.text.replaceAll(',', '.')) ?? 0.0,
      heightCm: double.tryParse(_heightCtrl.text.replaceAll(',', '.')) ?? 0.0,
      lifestyle: _lifestyle,
      dietType: _dietType,
    );

    if (bloc.isProfileNotEmpty) {
      await bloc.createProfile(profile);
    } else {
      await bloc.saveProfile(profile);
    }
  }

  void _initFields(ProfileState state) {
    final profile = state.profile;
    if (profile != null) {
      final Profile(
        :nickname,
        :birthdate,
        :sex,
        :weightKg,
        :heightCm,
        :lifestyle,
        :dietType,
      ) = profile;
      _nicknameCtrl.text = nickname;
      _birthdate = birthdate;
      _birthdateCtrl.text = _birthdate != null
          ? DateFormat('dd.MM.yyyy').format(_birthdate!)
          : '';
      _sex = sex;
      _weightCtrl.text = weightKg.toString();
      _heightCtrl.text = heightCm.toString();
      _lifestyle = lifestyle;
      _dietType = dietType;
    }
    if (state.status == ProfileStatus.error) {
      _showError(state.error);
    }
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime(now.year - _defAge),
      firstDate: DateTime(_defFirstYear),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthdate = picked;
        _birthdateCtrl.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  Future<void> _openPreferences() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PreferencesScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showError(String? err) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${err ?? 'unknown'}')),
  );

  void _showSaved() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Profile saved')),
  );
}
