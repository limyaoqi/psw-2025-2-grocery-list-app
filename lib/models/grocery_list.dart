import 'grocery_item.dart';

class GroceryList {
  final int id;
  String name;
  List<GroceryItem> items;

  GroceryList({required this.id, required this.name, List<GroceryItem>? items})
    : items = items ?? [];

  void addItem(GroceryItem item) {
    items.add(item);
  }

  void updateItem(GroceryItem updated) {
    final idx = items.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      items[idx] = updated;
    }
  }

  void toggleItem(int itemId) {
    final idx = items.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      final current = items[idx];
      items[idx] = current.copyWith(isChecked: !current.isChecked);
    }
  }

  void removeItem(int itemId) {
    items.removeWhere((i) => i.id == itemId);
  }
}
