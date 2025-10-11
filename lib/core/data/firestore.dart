import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keto_calculator/core/data/repository.dart';

class FirestoreSourse {
  FirestoreSourse(this._fs);
  final FirebaseFirestore _fs;

  DocumentReference<Map<String, dynamic>> _getDocRef(String path) => _fs
      .doc(path)
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
        toFirestore: (map, _) => map,
      );

  CollectionReference<Map<String, dynamic>> _getCollectionRef(String path) =>
      _fs
          .collection(path)
          .withConverter<Map<String, dynamic>>(
            fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
            toFirestore: (map, _) => map,
          );

  Future<List<Map<String, dynamic>>> getAll(String collectionPath) async {
    final snap = await _getCollectionRef(collectionPath).get();
    return snap.docs.map((snapDoc) {
      final data = Map<String, dynamic>.from(snapDoc.data());
      data['id'] = snapDoc.id;
      return data;
    }).toList();
  }

  Future<PaginatedItems> getList(
    String collectionPath, {
    int size = 0,
    String? afterId,
    // bool includeId = true,
  }) async {
    Query<Map<String, dynamic>> collectionRef = _getCollectionRef(
      collectionPath,
    );
    collectionRef = collectionRef.orderBy(FieldPath.documentId);
    if (size > 0) collectionRef = collectionRef.limit(size);
    if (afterId != null && afterId.isNotEmpty) {
      collectionRef = collectionRef.startAfter([afterId]);
    }
    final snap = await collectionRef.get();
    final items = snap.docs.map((
      snapDoc,
    ) {
      final data = Map<String, dynamic>.from(
        snapDoc.data(),
      );
      data['id'] = snapDoc.id;
      // if (includeId && !fields.containsKey('id')) {
      //   fields['id'] = snapDoc.id;
      // }
      return data;
    }).toList();
    // return Future.sync(() => PaginatedItems([]));
    return PaginatedItems(
      items,
      lastItemId: snap.docs.isNotEmpty ? snap.docs.last.id : null,
    );
  }

  Future<Map<String, dynamic>> addItem(
    String collectionPath,
    Map<String, dynamic> data, {
    String? id,
  }) async {
    final collectionRef = _getCollectionRef(collectionPath);
    if (id != null && id.isNotEmpty) {
      await collectionRef.doc(id).set(data);
      final result = Map<String, dynamic>.from(data);
      result['id'] = id;
      return result;
    } else {
      final docRef = await collectionRef.add(data);
      final result = Map<String, dynamic>.from(data);
      result['id'] = docRef.id;
      return result;
    }
  }

  Future<Map<String, dynamic>?> getItem(String itemPath) async {
    final snap = await _getDocRef(itemPath).get();
    if (!snap.exists) return null;
    final data = snap.data();
    return data;
  }

  Future<void> setItem(
    String itemPath,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    return _getDocRef(itemPath).set(data, SetOptions(merge: merge));
  }

  Future<void> updateItem(String itemPath, Map<String, dynamic> data) async {
    await _getDocRef(itemPath).update(data);
  }

  Future<void> deleteItem(String itemPath) async {
    await _getDocRef(itemPath).delete();
  }

  Future<bool> isItemExists(String itemPath) async {
    final snap = await _getDocRef(itemPath).get();
    return snap.exists && (snap.data()?.isNotEmpty ?? false);
  }

  Future<void> clear(String collectionPath) async {
    const batchSize = 500;
    final collectionRef = _getCollectionRef(collectionPath);
    while (true) {
      final snap = await collectionRef.limit(batchSize).get();
      if (snap.docs.isEmpty) break;
      final batch = _fs.batch();
      for (final doc in snap.docs) {
        batch.delete(collectionRef.doc(doc.id));
      }
      await batch.commit();
      if (snap.docs.length < batchSize) break;
    }
  }
}

abstract class SingleDocFirestoreSource implements SingleItemSource {
  SingleDocFirestoreSource(FirebaseFirestore fs)
    : _docRef = FirestoreSourse(fs);
  final FirestoreSourse _docRef;

  String get docPath;

  @override
  Future<Map<String, dynamic>?> get() => _docRef.getItem(docPath);

  @override
  Future<void> set(
    Map<String, dynamic> data, {
    bool merge = false,
  }) => _docRef.setItem(docPath, data, merge: merge);

  @override
  Future<void> delete() => _docRef.deleteItem(docPath);

  @override
  Future<bool> isExists() => _docRef.isItemExists(docPath);
}

abstract class CollectionDocsFirestoreSource extends FirestoreSourse
    implements MultiItemsSource {
  CollectionDocsFirestoreSource(super._fs);

  String get collectionPath;
  String getDocPath(String item);

  @override
  // ignore: avoid_renaming_method_parameters, cause now we need to pass only item part of path
  DocumentReference<Map<String, dynamic>> _getDocRef(String item) =>
      super._getDocRef(getDocPath(item));

  @override
  CollectionReference<Map<String, dynamic>> _getCollectionRef([String? _]) =>
      super._getCollectionRef(collectionPath);
}
