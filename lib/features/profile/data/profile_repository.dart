import 'package:keto_calculator/core/data/repository.dart';
import 'package:keto_calculator/core/models/profile.dart';

class ProfileRepository extends SingleItemRepository<ProfileRepository> {
  ProfileRepository._(super.source) : _source = source;
  final SingleItemSource _source;

  static Future<ProfileRepository> init(SingleItemSource source) =>
      DataRepository.init<ProfileRepository, SingleItemSource>(
        ProfileRepository._,
        source,
      );

  static ProfileRepository get instance =>
      DataRepository.getInstance<ProfileRepository, SingleItemSource>();

  Future<bool> isExists() async => _source.isExists();

  Future<Profile?> get() async {
    final data = await _source.get();
    return data != null && data.isNotEmpty ? Profile.fromJson(data) : null;
  }

  Future<void> create(Profile profile) async {
    final existsProfile = await get();
    if (existsProfile != null) {
      throw StateError('Profile already exists for current user');
    }
    await _source.set(profile.toJson());
  }

  Future<void> save(Profile profile) async {
    await _source.set(profile.toJson(), merge: true);
  }

  Future<void> delete() async {
    await _source.delete();
  }
}
