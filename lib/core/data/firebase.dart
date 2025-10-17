import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    List<SourceItemsFilter>? filters,
    List<SourceItemsOrder>? orderBy,
    // bool includeId = true,
  }) async {
    Query<Map<String, dynamic>> collectionRef = _getCollectionRef(
      collectionPath,
    );
    collectionRef = collectionRef.applyFilters(filters, orderBy);
    // collectionRef = collectionRef.orderBy(FieldPath.documentId);
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
    : _fsSource = FirestoreSourse(fs);
  final FirestoreSourse _fsSource;

  String get docPath;

  @override
  Future<Map<String, dynamic>?> get() => _fsSource.getItem(docPath);

  @override
  Future<void> set(
    Map<String, dynamic> data, {
    bool merge = false,
  }) => _fsSource.setItem(docPath, data, merge: merge);

  @override
  Future<void> delete() => _fsSource.deleteItem(docPath);

  @override
  Future<bool> isExists() => _fsSource.isItemExists(docPath);
}

abstract class CollectionDocsFirestoreSource implements MultiItemsSource {
  CollectionDocsFirestoreSource(FirebaseFirestore fs)
    : _fsSource = FirestoreSourse(fs);
  final FirestoreSourse _fsSource;

  String get collectionPath;
  String getDocPath(String itemId);

  @override
  Future<List<Map<String, dynamic>>> getAll() =>
      _fsSource.getAll(collectionPath);

  @override
  Future<PaginatedItems> getList({
    int size = 0,
    String? afterId,
    List<SourceItemsFilter>? filters,
    List<SourceItemsOrder>? orderBy,
  }) => _fsSource.getList(
    collectionPath,
    size: size,
    afterId: afterId,
    filters: filters,
    orderBy: orderBy,
  );

  @override
  Future<Map<String, dynamic>> addItem(
    Map<String, dynamic> data, {
    String? id,
  }) => _fsSource.addItem(collectionPath, data, id: id);

  @override
  Future<Map<String, dynamic>?> getItem(String itemId) =>
      _fsSource.getItem(getDocPath(itemId));

  @override
  Future<void> updateItem(String itemId, Map<String, dynamic> data) =>
      _fsSource.updateItem(getDocPath(itemId), data);

  @override
  Future<void> deleteItem(String itemId) =>
      _fsSource.deleteItem(getDocPath(itemId));

  @override
  Future<bool> isItemExists(String itemId) =>
      _fsSource.isItemExists(getDocPath(itemId));

  @override
  Future<void> clear() => _fsSource.clear(collectionPath);
}

extension FirestoreQueryBuilder on Query<Map<String, dynamic>> {
  Query<Map<String, dynamic>> applyFilters(
    List<SourceItemsFilter>? filters,
    List<SourceItemsOrder>? orderBy,
  ) {
    var q = this;

    if (filters != null && filters.isNotEmpty) {
      for (final f in filters) {
        q = q.where(
          f.field,
          isEqualTo: f.isEqualTo,
          isNotEqualTo: f.isNotEqualTo,
          isLessThan: f.isLessThan,
          isLessThanOrEqualTo: f.isLessThanOrEqualTo,
          isGreaterThan: f.isGreaterThan,
          isGreaterThanOrEqualTo: f.isGreaterThanOrEqualTo,
          arrayContains: f.arrayContains,
          arrayContainsAny: f.arrayContainsAny,
          whereIn: f.whereIn,
          whereNotIn: f.whereNotIn,
        );
      }
    }

    if (orderBy != null && orderBy.isNotEmpty) {
      for (final o in orderBy) {
        q = q.orderBy(o.field, descending: o.descending);
      }
    }

    return q;
  }
}

Future<String> getSavedFileUrl(String? filePath) =>
    FirebaseStorage.instance.ref(filePath).getDownloadURL();

Future<String?> saveFile(String filePath) async {
  try {
    final fileExt = filePath.split('.').last;
    final storageRef = FirebaseStorage.instance.ref();
    final photoRef = storageRef.child(
      'files/${DateTime.now().millisecondsSinceEpoch}.$fileExt',
    );
    final uploadTask = await photoRef.putFile(File(filePath));
    return await uploadTask.ref.getDownloadURL();
  } catch (e) {
    print('cant upload photo: $e');
  }
  return null;
}
