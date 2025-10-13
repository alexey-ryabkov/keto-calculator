import 'package:keto_calculator/core/data/firestore.dart';
import 'package:keto_calculator/core/models/app_user.dart';

abstract final class FirestorePaths {
  static const _users = 'users';
  static const _journal = 'journal';
  static const _meals = 'meals';
  static const _products = 'products';

  static String get _curUserRoot => '$_users/${AppUser.instance.id}';

  static String userProfile() => '$_curUserRoot/';
  static String userJournal([String? entryId]) =>
      entryId != null && entryId.isNotEmpty
      ? '$_curUserRoot/$_journal/$entryId'
      : '$_curUserRoot/$_journal';
  static String userMeal([String? mealId]) =>
      mealId != null && mealId.isNotEmpty
      ? '$_curUserRoot/$_meals/$mealId'
      : '$_curUserRoot/$_meals';
  static String userProduct([String? productId]) =>
      productId != null && productId.isNotEmpty
      ? '$_curUserRoot/$_products/$productId'
      : '$_curUserRoot/$_products';
}

class FirestoreProfile extends SingleDocFirestoreSource {
  FirestoreProfile(super._fs);

  @override
  String get docPath => FirestorePaths.userProfile();
}

class FirestoreJournal extends CollectionDocsFirestoreSource {
  FirestoreJournal(super._fs);

  @override
  String get collectionPath => FirestorePaths.userJournal();

  @override
  String getDocPath(String itemId) => FirestorePaths.userJournal(itemId);
}

class FirestoreMeal extends CollectionDocsFirestoreSource {
  FirestoreMeal(super._fs);

  @override
  String get collectionPath => FirestorePaths.userMeal();

  @override
  String getDocPath(String itemId) => FirestorePaths.userMeal(itemId);
}

class FirestoreProduct extends CollectionDocsFirestoreSource {
  FirestoreProduct(super._fs);

  @override
  String get collectionPath => FirestorePaths.userProduct();

  @override
  String getDocPath(String itemId) => FirestorePaths.userProduct(itemId);
}
