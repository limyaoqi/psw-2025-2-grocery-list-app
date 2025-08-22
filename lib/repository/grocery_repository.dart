import '../models/grocery_list.dart';
import '../models/grocery_item.dart';

abstract class GroceryRepository {
  Future<List<GroceryList>> getLists();
  Future<GroceryList> createList(String name);
  Future<void> deleteList(int listId);
  Future<GroceryList?> getListById(int listId);
  Future<GroceryItem> addItem(int listId, GroceryItem item);
  Future<void> updateItem(int listId, GroceryItem item);
  Future<void> toggleItem(int listId, int itemId);
  Future<void> removeItem(int listId, int itemId);
}
