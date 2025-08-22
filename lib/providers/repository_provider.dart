import '../repository/repository_factory.dart';
import '../repository/grocery_repository.dart';

class RepositoryProvider {
  static final GroceryRepository _instance = RepositoryFactory.create();

  static GroceryRepository get instance => _instance;
}
