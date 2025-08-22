import 'package:flutter/material.dart';
import '../models/category.dart';

String categoryToLabel(Category c) {
  switch (c) {
    case Category.fruits:
      return 'Fruits';
    case Category.vegetables:
      return 'Vegetables';
    case Category.dairy:
      return 'Dairy';
    case Category.snacks:
      return 'Snacks';
    case Category.bakery:
      return 'Bakery';
    case Category.meat:
      return 'Meat';
    case Category.beverages:
      return 'Beverages';
    case Category.others:
      return 'Others';
  }
}

Category categoryFromLabel(String label) {
  final l = label.toLowerCase();
  if (l.contains('fruit')) return Category.fruits;
  if (l.contains('vegetable')) return Category.vegetables;
  if (l.contains('dairy')) return Category.dairy;
  if (l.contains('snack')) return Category.snacks;
  if (l.contains('bakery')) return Category.bakery;
  if (l.contains('meat')) return Category.meat;
  if (l.contains('beverage') || l.contains('drink')) return Category.beverages;
  return Category.others;
}

Color colorForCategory(Category c) {
  switch (c) {
    case Category.fruits:
      return const Color(0xFFFF7043); // orange-ish
    case Category.vegetables:
      return const Color(0xFF66BB6A); // green
    case Category.dairy:
      return const Color(0xFF90CAF9); // light blue
    case Category.snacks:
      return const Color(0xFFFFCA28); // yellow
    case Category.bakery:
      return const Color(0xFFD7A17A); // brownish
    case Category.meat:
      return const Color(0xFFEF5350); // red
    case Category.beverages:
      return const Color(0xFF5C6BC0); // indigo
    case Category.others:
      return const Color(0xFFBDBDBD); // grey
  }
}

IconData iconForCategory(Category c) {
  switch (c) {
    case Category.fruits:
      return Icons
          .apple; // Note: apple icon is available in newer icon sets; fallback below if needed
    case Category.vegetables:
      return Icons.grass; // representative
    case Category.dairy:
      return Icons.icecream;
    case Category.snacks:
      return Icons.fastfood;
    case Category.bakery:
      return Icons.bakery_dining;
    case Category.meat:
      return Icons.set_meal;
    case Category.beverages:
      return Icons.local_cafe;
    case Category.others:
      return Icons.category;
  }
}
