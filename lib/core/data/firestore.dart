import 'package:keto_calculator/core/models/app_user.dart';

abstract final class FirestorePaths {
  static const _users = 'users';
  // static const _profiles = 'profiles';
  static const _journal = 'journal';
  static const _meals = 'meals';
  static const _products = 'products';

  // static late final _curUserId = AppUser.instance.id;
  // static String get _curUserId => AppUser.instance.id;
  static String get _curUserRoot => '$_users/${AppUser.instance.id}';

  static String userProfile() => '$_curUserRoot/';
  static String userEntry(String entryId) => '$_curUserRoot/$_journal/$entryId';
  static String userMeal(String mealId) => '$_curUserRoot/$_meals/$mealId';
  static String userProduct(String productId) =>
      '$_curUserRoot/$_products/$productId';
}
