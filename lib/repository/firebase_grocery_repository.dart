import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/grocery_list.dart';
import '../models/grocery_item.dart';
import '../models/category.dart';
import 'grocery_repository.dart';

class FirebaseGroceryRepository implements GroceryRepository {
  final FirebaseFirestore _firestore;
  final CollectionReference _listsRef;

  FirebaseGroceryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _listsRef = (firestore ?? FirebaseFirestore.instance).collection('lists');

  int _makeIdFromNow() => DateTime.now().millisecondsSinceEpoch;

  Category _categoryFromString(dynamic input) {
    if (input == null) return Category.others;
    final s = input.toString();
    try {
      return Category.values.firstWhere((e) => e.name == s);
    } catch (_) {
      // try loose matching
      final low = s.toLowerCase();
      if (low.contains('fruit')) return Category.fruits;
      if (low.contains('vegetable')) return Category.vegetables;
      if (low.contains('dairy')) return Category.dairy;
      if (low.contains('snack')) return Category.snacks;
      if (low.contains('bakery')) return Category.bakery;
      if (low.contains('meat')) return Category.meat;
      if (low.contains('beverage') || low.contains('drink')) {
        return Category.beverages;
      }
      return Category.others;
    }
  }

  Future<DocumentSnapshot?> _findListDocById(int listId) async {
    final q = await _listsRef.where('id', isEqualTo: listId).limit(1).get();
    if (q.docs.isEmpty) return null;
    return q.docs.first;
  }

  Future<DocumentSnapshot?> _findItemDocById(
    DocumentReference listDocRef,
    int itemId,
  ) async {
    final itemsRef = listDocRef.collection('items') as CollectionReference;
    final q = await itemsRef.where('id', isEqualTo: itemId).limit(1).get();
    if (q.docs.isEmpty) return null;
    return q.docs.first;
  }

  @override
  Future<List<GroceryList>> getLists() async {
    final snapshot = await _listsRef.get();
    final result = <GroceryList>[];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final id =
          data['id'] is int
              ? data['id'] as int
              : (data['id'] is num
                  ? (data['id'] as num).toInt()
                  : int.tryParse(doc.id) ?? doc.id.hashCode);
      final name = data['name'] as String? ?? '';

      final itemsSnap = await _listsRef.doc(doc.id).collection('items').get();
      final items =
          itemsSnap.docs.map((d) {
            final m = d.data() as Map<String, dynamic>? ?? {};
            final itemId =
                m['id'] is int
                    ? m['id'] as int
                    : (m['id'] is num
                        ? (m['id'] as num).toInt()
                        : int.tryParse(d.id) ?? d.id.hashCode);
            return GroceryItem(
              id: itemId,
              name: m['name'] as String? ?? '',
              quantity: (m['quantity'] as num?)?.toInt() ?? 0,
              category: _categoryFromString(m['category']),
              isChecked: m['isChecked'] == true,
            );
          }).toList();

      result.add(GroceryList(id: id, name: name, items: items));
    }
    return result;
  }

  @override
  Future<GroceryList> createList(String name) async {
    final id = _makeIdFromNow();
    final docRef = await _listsRef.add({'id': id, 'name': name});
    // debug log
    // ignore: avoid_print
    print(
      '[FirebaseGroceryRepository] createList -> doc:${docRef.id} id:$id name:$name',
    );
    return GroceryList(id: id, name: name, items: []);
  }

  @override
  Future<void> deleteList(int listId) async {
    final found = await _findListDocById(listId);
    if (found == null) return;

    final listDocRef = _listsRef.doc(found.id);
    // delete subcollection items
    final items = await listDocRef.collection('items').get();
    final batch = _firestore.batch();
    for (final d in items.docs) {
      batch.delete(d.reference);
    }
    batch.delete(listDocRef);
    await batch.commit();
  }

  @override
  Future<GroceryList?> getListById(int listId) async {
    final found = await _findListDocById(listId);
    if (found == null) return null;
    final data = found.data() as Map<String, dynamic>? ?? {};
    final id =
        data['id'] is int
            ? data['id'] as int
            : (data['id'] is num
                ? (data['id'] as num).toInt()
                : int.tryParse(found.id) ?? found.id.hashCode);
    final name = data['name'] as String? ?? '';
    final itemsSnap = await _listsRef.doc(found.id).collection('items').get();
    final items =
        itemsSnap.docs.map((d) {
          final m = d.data() as Map<String, dynamic>? ?? {};
          final itemId =
              m['id'] is int
                  ? m['id'] as int
                  : (m['id'] is num
                      ? (m['id'] as num).toInt()
                      : int.tryParse(d.id) ?? d.id.hashCode);
          return GroceryItem(
            id: itemId,
            name: m['name'] as String? ?? '',
            quantity: (m['quantity'] as num?)?.toInt() ?? 0,
            category: _categoryFromString(m['category']),
            isChecked: m['isChecked'] == true,
          );
        }).toList();
    return GroceryList(id: id, name: name, items: items);
  }

  @override
  Future<GroceryItem> addItem(int listId, GroceryItem item) async {
    final found = await _findListDocById(listId);
    if (found == null) throw StateError('List $listId not found');
    final listDocRef = _listsRef.doc(found.id);
    final id = _makeIdFromNow();
    final itemData = {
      'id': id,
      'name': item.name,
      'quantity': item.quantity,
      'category': item.category.name,
      'isChecked': item.isChecked,
    };
    final docRef = await listDocRef.collection('items').add(itemData);
    // debug log
    // ignore: avoid_print
    print(
      '[FirebaseGroceryRepository] addItem -> listDoc:${found.id} itemDoc:${docRef.id} id:$id name:${item.name}',
    );
    return item.copyWith(id: id);
  }

  @override
  Future<void> updateItem(int listId, GroceryItem item) async {
    final found = await _findListDocById(listId);
    if (found == null) throw StateError('List $listId not found');
    final listDocRef = _listsRef.doc(found.id);
    final itemDoc = await _findItemDocById(listDocRef, item.id);
    if (itemDoc == null) {
      throw StateError('Item ${item.id} not found in list $listId');
    }
    await listDocRef.collection('items').doc(itemDoc.id).set({
      'id': item.id,
      'name': item.name,
      'quantity': item.quantity,
      'category': item.category.name,
      'isChecked': item.isChecked,
    });
  }

  @override
  Future<void> toggleItem(int listId, int itemId) async {
    final found = await _findListDocById(listId);
    if (found == null) throw StateError('List $listId not found');
    final listDocRef = _listsRef.doc(found.id);
    final itemDoc = await _findItemDocById(listDocRef, itemId);
    if (itemDoc == null) {
      throw StateError('Item $itemId not found in list $listId');
    }
    final data = itemDoc.data() as Map<String, dynamic>? ?? {};
    final current = data['isChecked'] == true;
    await listDocRef.collection('items').doc(itemDoc.id).update({
      'isChecked': !current,
    });
  }

  @override
  Future<void> removeItem(int listId, int itemId) async {
    final found = await _findListDocById(listId);
    if (found == null) throw StateError('List $listId not found');
    final listDocRef = _listsRef.doc(found.id);
    final itemDoc = await _findItemDocById(listDocRef, itemId);
    if (itemDoc == null) {
      return;
    }
    await listDocRef.collection('items').doc(itemDoc.id).delete();
  }
}
