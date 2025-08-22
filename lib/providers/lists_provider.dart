import 'package:flutter/foundation.dart';

import '../models/grocery_list.dart';
import '../repository/grocery_repository.dart';
import 'repository_provider.dart';

class ListsProvider extends ChangeNotifier {
  final GroceryRepository _repo;
  List<GroceryList> lists = [];
  bool isLoading = false;
  String? errorMessage;

  ListsProvider({GroceryRepository? repository})
    : _repo = repository ?? RepositoryProvider.instance;

  Future<void> loadLists() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      lists = await _repo.getLists();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<GroceryList> create(String name) async {
    errorMessage = null;
    try {
      final created = await _repo.createList(name);
      // Avoid adding duplicates in case `lists` references the repository's
      // internal storage (some repo implementations return the same list
      // instance). Only add when an entry with the same id doesn't exist.
      if (!lists.any((l) => l.id == created.id)) {
        lists.add(created);
      }
      notifyListeners();
      return created;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> delete(int listId) async {
    errorMessage = null;
    try {
      await _repo.deleteList(listId);
      lists.removeWhere((l) => l.id == listId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
