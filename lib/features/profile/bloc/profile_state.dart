import 'package:keto_calculator/core/models/profile.dart';
import 'package:meta/meta.dart';

enum ProfileStatus { initial, loading, none, ready, saving, error }

@immutable
class ProfileState {
  const ProfileState({
    required this.profile,
    required this.status,
    this.error,
  });

  factory ProfileState.initial() =>
      const ProfileState(profile: null, status: ProfileStatus.initial);
  final Profile? profile;
  final ProfileStatus status;
  final String? error;

  ProfileState copyWith({
    Profile? profile,
    ProfileStatus? status,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  String toString() => 'ProfileState(status=$status, $profile)';
}
