import 'dart:async';

import '../models/grocery_list.dart';
import '../models/grocery_item.dart';
import 'grocery_repository.dart';

/// In-memory implementation of [GroceryRepository].
/// Keeps state for the lifetime of the app process.
class InMemoryGroceryRepository implements GroceryRepository {
  final List<GroceryList> _lists = [];
  int _nextListId = 1;
  int _nextItemId = 1;

  InMemoryGroceryRepository();

  @override
  Future<List<GroceryList>> getLists() async {
    // Return references (lightweight). If you need immutability, clone here.
    return Future.value(_lists);
  }

  @override
  Future<GroceryList> createList(String name) async {
    final list = GroceryList(id: _nextListId++, name: name);
    _lists.add(list);
    return Future.value(list);
  }

  @override
  Future<void> deleteList(int listId) async {
    _lists.removeWhere((l) => l.id == listId);
    return Future.value();
  }

  @override
  Future<GroceryList?> getListById(int listId) async {
    for (final l in _lists) {
      if (l.id == listId) return Future.value(l);
    }
    return Future.value(null);
  }

  @override
  Future<GroceryItem> addItem(int listId, GroceryItem item) async {
    final list = _lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => throw StateError('List $listId not found'),
    );

    // assign id if not provided or <= 0
    final int assignedId = (item.id <= 0) ? _nextItemId++ : item.id;
    final newItem = item.copyWith(id: assignedId);
    list.items.add(newItem);
    return Future.value(newItem);
  }

  @override
  Future<void> updateItem(int listId, GroceryItem item) async {
    final list = _lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => throw StateError('List $listId not found'),
    );
    final idx = list.items.indexWhere((i) => i.id == item.id);
    if (idx == -1) {
      throw StateError('Item ${item.id} not found in list $listId');
    }
    list.items[idx] = item;
    return Future.value();
  }

  @override
  Future<void> toggleItem(int listId, int itemId) async {
    final list = _lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => throw StateError('List $listId not found'),
    );
    final idx = list.items.indexWhere((i) => i.id == itemId);
    if (idx == -1) {
      throw StateError('Item $itemId not found in list $listId');
    }
    final current = list.items[idx];
    list.items[idx] = current.copyWith(isChecked: !current.isChecked);
    return Future.value();
  }

  @override
  Future<void> removeItem(int listId, int itemId) async {
    final list = _lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => throw StateError('List $listId not found'),
    );
    list.items.removeWhere((i) => i.id == itemId);
    return Future.value();
  }
}
