import 'grocery_repository.dart';
import 'in_memory_grocery_repository.dart';
import 'firebase_grocery_repository.dart';
import '../utils/app_config.dart';

class RepositoryFactory {
  static GroceryRepository create() {
    if (useFirebase) return FirebaseGroceryRepository();
    return InMemoryGroceryRepository();
  }
}
