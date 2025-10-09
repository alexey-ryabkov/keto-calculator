import 'package:cloud_firestore/cloud_firestore.dart';

enum Sex { male, female }

enum Lifestyle { sedentary, lightlyActive, active, veryActive }

enum DietType { notKeto, keto, strictKeto }

class Profile {
  Profile({
    required this.userId,
    required this.nickname,
    required this.sex,
    required this.weightKg,
    required this.heightCm,
    required this.lifestyle,
    required this.dietType,
    required this.birthdate,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    DateTime? bd;
    final bdt = json['birthdate'];
    if (bdt is Timestamp) {
      bd = bdt.toDate();
    } else if (bdt is String) {
      bd = DateTime.tryParse(bdt);
    }

    var sex = Sex.male;
    final s = json['sex'] as String?;
    if (s != null) {
      sex = Sex.values.firstWhere((e) => e.name == s, orElse: () => Sex.male);
    }

    var lifestyle = Lifestyle.sedentary;
    final ls = json['lifestyle'] as String?;
    if (ls != null) {
      lifestyle = Lifestyle.values.firstWhere(
        (e) => e.name == ls,
        orElse: () => Lifestyle.sedentary,
      );
    }

    DietType _diet = DietType.notKeto;
    final dt = json['dietType'] as String?;
    if (dt != null)
      _diet = DietType.values.firstWhere(
        (e) => e.name == dt,
        orElse: () => DietType.notKeto,
      );

    return Profile(
      userId: (json['userId'] as String?) ?? '',
      nickname: (json['nickname'] as String?) ?? '',
      birthdate: bd,
      sex: sex,
      weightKg: (json['weightKg'] is num)
          ? (json['weightKg'] as num).toDouble()
          : double.tryParse((json['weightKg'] ?? '0').toString()) ?? 0.0,
      heightCm: (json['heightCm'] is num)
          ? (json['heightCm'] as num).toDouble()
          : double.tryParse((json['heightCm'] ?? '0').toString()) ?? 0.0,
      lifestyle: lifestyle,
      dietType: _diet,
    );
  }

  final String userId;
  final String nickname;
  final DateTime? birthdate;
  final Sex sex;
  final double weightKg;
  final double heightCm;
  final Lifestyle lifestyle;
  final DietType dietType;

  Profile copyWith({
    String? nickname,
    DateTime? birthdate,
    Sex? sex,
    double? weightKg,
    double? heightCm,
    Lifestyle? lifestyle,
    DietType? dietType,
  }) {
    return Profile(
      userId: userId,
      nickname: nickname ?? this.nickname,
      birthdate: birthdate ?? this.birthdate,
      sex: sex ?? this.sex,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      lifestyle: lifestyle ?? this.lifestyle,
      dietType: dietType ?? this.dietType,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'nickname': nickname,
    'birthdate': birthdate == null ? null : Timestamp.fromDate(birthdate!),
    'sex': sex.name,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'lifestyle': lifestyle.name,
    'dietType': dietType.name,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
