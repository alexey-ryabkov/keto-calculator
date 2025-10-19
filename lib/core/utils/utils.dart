import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

export 'compute_daily_nutrition_targets.dart';
export 'date_change_watcher.dart';
export 'env.dart';

String formatDate(DateTime dt) => DateFormat('dd.MM.yyyy').format(dt);

DateTime? parseDateTime(Object? v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is String) {
    final parsed = DateTime.tryParse(v);
    if (parsed != null) return parsed;
    final maybeInt = int.tryParse(v);
    if (maybeInt != null) {
      return DateTime.fromMillisecondsSinceEpoch(maybeInt);
    }
  }
  return null;
}

bool? parseBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
  }
  return null;
}

double toDouble(Object? v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
  return 0.0;
}

int toInt(Object? v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    // if (RegExp(r'^[+-]?\d+(\.\d+)?$').hasMatch(v.trim())) {
    final i = int.tryParse(v);
    if (i != null) return i;
    final d = double.tryParse(v);
    if (d != null) return d.toInt();
  }
  return 0;
}

T? tryOrNull<T>(T Function() fn) {
  try {
    return fn();
  } catch (_) {
    return null;
  }
}

extension StringExtensions on String {
  String capitalize() {
    return '${toUpperCase()}${substring(1)}';
  }
}
