import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _kUserIdPrefKey = 'k_user_id';
const _uuid = Uuid();

final class AppUser {
  AppUser._(this._id);

  final String _id;
  String get id => _id;

  static AppUser? _instance;
  static AppUser get instance {
    if (_instance == null) {
      throw StateError(
        'AppUser not initialized. Call AppUser.init(...) first.',
      );
    }
    return _instance!;
  }

  static Future<AppUser> init() async {
    if (_instance != null) {
      return _instance!;
    }
    final String userId;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kUserIdPrefKey);
    if (stored != null && stored.isNotEmpty) {
      userId = stored;
    } else {
      final newId = _uuid.v4();
      await prefs.setString(_kUserIdPrefKey, newId);
      userId = newId;
    }
    _instance = AppUser._(userId);
    return _instance!;
  }
}
