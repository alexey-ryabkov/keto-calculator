import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keto_calculator/core/data/firestore.dart';
import 'package:keto_calculator/core/models/profile.dart';

class ProfileRepository {
  ProfileRepository._(this._firestore);
  final FirebaseFirestore _firestore;

  static ProfileRepository? _instance;
  static Future<ProfileRepository> init(FirebaseFirestore firestore) async {
    _instance ??= ProfileRepository._(firestore);
    return _instance!;
  }

  static ProfileRepository get instance {
    if (_instance == null) {
      throw StateError(
        'ProfileRepository not initialized. Call ProfileRepository.init(...)'
        ' first.',
      );
    }
    return _instance!;
  }

  String get _docPath => FirestorePaths.userProfile();
  DocumentReference<Map<String, dynamic>> get _docRef {
    // print('_docPath $_docPath');
    return _firestore
        .doc(_docPath)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
          toFirestore: (map, _) => map,
        );
  }

  Future<bool> profileExists({String? forUserId}) async {
    final doc = await _docRef.get();
    return doc.exists && (doc.data()?.isNotEmpty ?? false);
  }

  Future<Profile?> getProfileOnce() async {
    final doc = await _docRef.get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null || data.isEmpty) return null;
    return Profile.fromJson(data);
  }

  Future<void> createProfile(Profile profile) async {
    final uid = profile.userId;
    final docRef = _docRef;
    final snapshot = await docRef.get();
    if (snapshot.exists && (snapshot.data()?.isNotEmpty ?? false)) {
      throw StateError('Profile already exists for user $uid');
    }
    await docRef.set(profile.toJson());
  }

  Future<void> saveProfile(Profile profile) async {
    await _docRef.set(profile.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteProfile({String? forUserId}) async {
    await _docRef.delete();
  }
}
