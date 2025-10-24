import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/app/models/models.dart';
import 'package:keto_calculator/core/models/nutrition.dart';
import 'package:keto_calculator/core/models/profile.dart';
import 'package:keto_calculator/core/utils/utils.dart';
import 'package:keto_calculator/features/profile/bloc/profile_state.dart';
import 'package:keto_calculator/features/profile/data/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefThemeModeKey = 'theme_mode';
const _prefLanguageKey = 'language';

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc() : super(ProfileState.initial());

  bool get isProfileDefined => ![
    ProfileStatus.initial,
    ProfileStatus.saving,
    ProfileStatus.loading,
  ].contains(state.status);
  bool get isProfileNotEmpty => state.profile != null;
  // status: ProfileStatus.none

  NutritionTarget? get nutritionTarget =>
      isProfileNotEmpty ? computeDailyNutritionTargets(state.profile!) : null;

  ThemeMode _prefThemeMode = defThemeMode;
  AppLanguage _prefLang = defLang;

  Future<void> init() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    await _loadPrefs();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    try {
      final profile = await ProfileRepository.instance.get();
      if (profile == null) {
        emit(state.copyWith(status: ProfileStatus.none));
      } else {
        emit(state.copyWith(profile: profile, status: ProfileStatus.ready));
      }
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  Future<void> createProfile(Profile profile) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      await ProfileRepository.instance.create(profile);
      emit(state.copyWith(profile: profile, status: ProfileStatus.ready));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  Future<void> saveProfile(Profile profile) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      await ProfileRepository.instance.save(profile);
      emit(state.copyWith(profile: profile, status: ProfileStatus.ready));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  Future<void> reloadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await ProfileRepository.instance.get();
      if (profile == null) {
        emit(state.copyWith(status: ProfileStatus.none));
      } else {
        emit(state.copyWith(profile: profile, status: ProfileStatus.ready));
      }
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  Future<void> updatePrefs({
    ThemeMode? themeMode,
    AppLanguage? language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (themeMode != null) {
      _prefThemeMode = themeMode;
      await prefs.setString(_prefThemeModeKey, themeMode.name);
    }
    if (language != null) {
      _prefLang = language;
      await prefs.setString(_prefLanguageKey, _prefLang.name);
    }
    _refresh();
  }

  ThemeMode get prefThemeMode => _prefThemeMode;
  AppLanguage get prefLanguage => _prefLang;

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _prefThemeMode = ThemeMode.values.byName(
      prefs.getString(_prefThemeModeKey) ?? defThemeMode.name,
    );
    _prefLang = AppLanguage.values.byName(
      prefs.getString(_prefLanguageKey) ?? defLang.name,
    );
    _refresh();
  }

  void _refresh() => emit(state.copyWith());
}
