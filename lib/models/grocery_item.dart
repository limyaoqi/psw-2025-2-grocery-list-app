import 'category.dart';

class GroceryItem {
  final int id;
  final String name;
  final int quantity;
  final Category category;
  final bool isChecked;

  GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.isChecked = false,
  });

  GroceryItem copyWith({
    int? id,
    String? name,
    int? quantity,
    Category? category,
    bool? isChecked,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category.name,
      'isChecked': isChecked,
    };
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    final catString = (json['category'] ?? 'others').toString();
    Category parsedCategory = Category.values.firstWhere(
      (e) => e.name == catString,
      orElse: () => Category.others,
    );

    return GroceryItem(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      category: parsedCategory,
      isChecked: json['isChecked'] == true,
    );
  }
}
