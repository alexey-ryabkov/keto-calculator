import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/core/models/profile.dart';
import 'package:keto_calculator/features/profile/bloc/profile_state.dart';
import 'package:keto_calculator/features/profile/data/profile_repository.dart';

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc() : super(ProfileState.initial());

  Future<void> init() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await ProfileRepository.instance.getProfileOnce();
      if (profile == null) {
        emit(state.copyWith(status: ProfileStatus.none));
      } else {
        emit(state.copyWith(profile: profile, status: ProfileStatus.ready));
      }
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  Future<void> create(Profile profile) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      await ProfileRepository.instance.createProfile(profile);
      emit(state.copyWith(profile: profile, status: ProfileStatus.ready));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  Future<void> save(Profile profile) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      await ProfileRepository.instance.saveProfile(profile);
      emit(state.copyWith(profile: profile, status: ProfileStatus.ready));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  Future<void> reload() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await ProfileRepository.instance.getProfileOnce();
      if (profile == null) {
        emit(state.copyWith(status: ProfileStatus.none));
      } else {
        emit(state.copyWith(profile: profile, status: ProfileStatus.ready));
      }
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }
}
