import 'package:flutter/foundation.dart';

import '../models/grocery_list.dart';
import '../models/grocery_item.dart';
import '../models/category.dart' as model_category;
import '../repository/grocery_repository.dart';
import 'repository_provider.dart';

class ListDetailProvider extends ChangeNotifier {
  final GroceryRepository _repo;
  GroceryList? list;
  bool isLoading = false;
  String? errorMessage;

  ListDetailProvider({GroceryRepository? repository})
    : _repo = repository ?? RepositoryProvider.instance;

  Future<void> loadList(int listId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      list = await _repo.getListById(listId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<GroceryItem> addItem(GroceryItem item) async {
    if (list == null) throw StateError('No list loaded');
    errorMessage = null;
    try {
      final added = await _repo.addItem(list!.id, item);
      // Some repository implementations (e.g. in-memory) mutate the
      // supplied list instance and already add the item. Guard against
      // adding duplicates by checking the item id first.
      if (!list!.items.any((i) => i.id == added.id)) {
        list!.items.add(added);
      }
      notifyListeners();
      return added;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateItem(GroceryItem item) async {
    if (list == null) throw StateError('No list loaded');
    errorMessage = null;
    try {
      await _repo.updateItem(list!.id, item);
      final idx = list!.items.indexWhere((i) => i.id == item.id);
      if (idx != -1) list!.items[idx] = item;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleItem(int itemId) async {
    if (list == null) throw StateError('No list loaded');
    errorMessage = null;
    try {
      await _repo.toggleItem(list!.id, itemId);
      final idx = list!.items.indexWhere((i) => i.id == itemId);
      if (idx != -1) {
        final current = list!.items[idx];
        list!.items[idx] = current.copyWith(isChecked: !current.isChecked);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeItem(int itemId) async {
    if (list == null) throw StateError('No list loaded');
    errorMessage = null;
    try {
      await _repo.removeItem(list!.id, itemId);
      list!.items.removeWhere((i) => i.id == itemId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Simple filtering by category
  List<GroceryItem> itemsForCategory(model_category.Category? category) {
    if (list == null) return [];
    if (category == null) return list!.items;
    return list!.items.where((i) => i.category == category).toList();
  }
}
