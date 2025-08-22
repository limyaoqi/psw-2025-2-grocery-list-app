# 🛒 Grocery List App

A modern Flutter application for managing grocery shopping lists with intuitive design and real-time synchronization. This project fulfills all requirements for the PSW-2025-2 Individual Assignment Level 2.

## 🎯 Project Requirements Compliance

### ✅ Core Requirements Met

- **List Creation**: Users can create new grocery lists with custom names
- **Item Entry**: Simple text input field with add button for adding items
- **Quantity Input**: Quantity specification for each item
- **Check Off Functionality**: Mark items as purchased during shopping
- **Categorisation Feature**: Assign categories and display items by category
- **Extra Points**: Firebase Firestore database integration with Repository pattern

## ✨ Features

### Core Functionality

- **Multiple Lists**: Create and manage multiple grocery lists
- **Smart Categories**: Organize items by categories (Fruits, Vegetables, Dairy, Meat, etc.)
- **Item Management**: Add, delete, and check off items
- **Quantity Tracking**: Specify quantities for each item
- **Visual Categories**: Color-coded icons for different item categories
- **Empty State**: Friendly messages when no items exist yet

### User Interface

- **Responsive Design**: Works seamlessly on mobile and web
- **Modern Material Design 3**: Clean, intuitive interface with proper theming
- **Input Validation**: Bordered input fields for better user experience
- **Smooth Animations**: Enhanced user experience with transitions

### Advanced Features

- **Smart Sorting**: Sort by category, name, or quantity
- **Filtering Options**: View all items, pending items, or completed items
- **Swipe to Delete**: Quick item removal with swipe gestures
- **Long Press to Edit**: Easy editing with long press interaction
- **Real-time Updates**: Changes sync across all instances
- **Dual Storage**: Firebase Firestore with In-Memory fallback

## 📱 Screenshots

| Home Screen                   | List Detail                   | Add Item                         | Empty State                           |
| ----------------------------- | ----------------------------- | -------------------------------- | ------------------------------------- |
| ![Home](screenshots/home.png) | ![List](screenshots/list.png) | ![Add](screenshots/add_item.png) | ![Empty](screenshots/empty_state.png) |

## 🏗️ Architecture

### Technical Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider pattern
- **Database**: Firebase Firestore (with In-Memory fallback)
- **Storage**: Cloud Firestore for persistence
- **Platforms**: Android, iOS, Web
- **Pattern**: Repository Pattern for data abstraction

### Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase setup
├── firebase_options.dart     # Firebase configuration
├── theme.dart               # Material Design 3 theming
├── models/                  # Data models
│   ├── category.dart        # Category enum and utilities
│   ├── grocery_item.dart    # GroceryItem model
│   └── grocery_list.dart    # GroceryList model
├── providers/               # State management
│   ├── lists_provider.dart         # Home screen state management
│   ├── list_detail_provider.dart   # List detail state management
│   └── repository_provider.dart    # Repository factory
├── repository/              # Data access layer (Repository Pattern)
│   ├── grocery_repository.dart         # Abstract repository interface
│   ├── firebase_grocery_repository.dart # Firebase implementation
│   ├── in_memory_grocery_repository.dart # In-memory implementation
│   └── repository_factory.dart         # Repository factory
├── screens/                 # UI screens
│   ├── home_screen.dart            # Lists overview
│   └── list_detail_screen.dart     # List items management
├── widgets/                 # Reusable components
│   ├── list_card.dart             # List display card
│   └── responsive_scaffold.dart   # Responsive layout
└── utils/                   # Utilities and helpers
    ├── app_config.dart            # Firebase toggle configuration
    └── category_utils.dart        # Category icons and colors
```

### Data Flow

1. **UI Layer** (Screens/Widgets) → **Provider** (State Management)
2. **Provider** → **Repository** (Data Access)
3. **Repository** → **Firebase/Memory** (Data Storage)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Firebase account (for cloud features)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/limyaoqi/psw-2025-2-grocery-list-app.git
   cd grocery_list_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (Optional - app works with in-memory storage)

   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Firestore Database
   - Add your Firebase configuration files:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`
     - Web: Update `web/index.html` with Firebase config

4. **Run the application**

   ```bash
   # Android
   flutter run

   # Web
   flutter run -d chrome

   # iOS (macOS only)
   flutter run -d ios
   ```

## 🔄 Switching Between Storage Options

The app supports two storage backends:

### Firebase (Default - Cloud Storage)

- Real-time synchronization
- Persistent across devices
- Requires internet connection

### In-Memory (Local Storage)

- Works offline
- Data resets on app restart
- No setup required

To switch storage mode, modify `lib/utils/app_config.dart`:

```dart
// For Firebase (default)
const bool useFirebase = true;

// For In-Memory testing
const bool useFirebase = false;
```

## 📦 Building for Production

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
# Copy to distribution: APK/app-release.apk
```

**📱 Ready-to-Install APK**: Download `APK/app-release.apk` (45.9MB) for direct Android installation.

### Web Build

```bash
flutter build web --release
# Output: build/web/
```

### iOS (macOS only)

```bash
flutter build ios --release
```

## 📋 Assignment Submission

This project meets all PSW-2025-2 Individual Assignment Level 2 requirements:

### ✅ Submission Criteria Met

- **GitHub Repository**: https://github.com/limyaoqi/psw-2025-2-grocery-list-app
- **README with Screenshots**: Comprehensive documentation with feature screenshots
- **APK Folder**: Contains `app-release.apk` for direct installation
- **Database Integration**: Firebase Firestore with Repository pattern (Extra Points)

### 📂 Submission Structure

```
grocery_list_app/
├── APK/
│   ├── app-release.apk     # Ready-to-install Android APK
│   └── README.md           # Installation instructions
├── screenshots/
│   ├── home.png           # Home screen showing lists
│   ├── list.png           # List detail with items
│   ├── add_item.png       # Adding new item interface
│   └── empty_state.png    # Empty state display
├── lib/                   # Flutter source code
├── README.md              # This comprehensive documentation
└── ...                    # Other project files
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📝 Usage Guide

### Creating Your First List

1. Tap the **+** button on the home screen
2. Enter a name for your grocery list
3. Tap **Create**

### Adding Items

1. Open a grocery list
2. **First Line**: Type the item name and set quantity (default: 1)
3. **Second Line**: Select a category from the dropdown and tap **Add**
4. Items appear instantly with checkboxes for completion tracking

### Managing Items

- **Check off items**: Tap the checkbox when shopping
- **Edit items**: Long press on any item to modify name, quantity, or category
- **Delete items**: Swipe left or tap the delete button
- **Sort items**: Use the sort dropdown (Category/Name/Quantity)
- **Filter items**: Toggle between All/To Buy/Bought

### User-Friendly Features

- **Empty State**: When no items exist, see helpful guidance to add your first item
- **Filtered Empty State**: Different messages for various filter states
- **Visual Feedback**: Bordered input fields with focus states
- **Category Icons**: Color-coded categories for easy identification
- **Real-time Count**: See completed vs total items in the app bar

### Categories Available

- 🍎 Fruits
- 🥬 Vegetables
- 🥛 Dairy
- 🥩 Meat & Fish
- 🍞 Bakery
- 🥫 Canned Goods
- 🧴 Health & Beauty
- 🧽 Household
- 🍪 Snacks
- 🥤 Beverages
- ❄️ Frozen
- 📦 Others

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔧 Development Notes

### Implemented Features

- ✅ Repository Pattern with Firebase integration
- ✅ Provider state management
- ✅ Material Design 3 theming
- ✅ Responsive UI design
- ✅ Empty state handling
- ✅ Input validation with borders
- ✅ Real-time data synchronization
- ✅ Cross-platform compatibility (Android, iOS, Web)

### Performance Optimizations

- Efficient state management with Provider
- Optimized rebuilds with proper widget keys
- Lazy loading for large lists
- Memory-efficient Firebase queries
- Tree-shaken icon fonts (99.8% reduction)

### Known Issues

- None currently reported

### Future Enhancements

- [ ] Shopping list sharing between users
- [ ] Barcode scanning for quick item addition
- [ ] Price tracking and budget management
- [ ] Recipe integration
- [ ] Voice input for hands-free adding
- [ ] Offline synchronization improvements
- [ ] Push notifications for shared lists

### Technical Achievements

- **Database Integration**: Successfully implemented Firebase Firestore with fallback
- **Repository Pattern**: Clean separation of data access concerns
- **State Management**: Efficient Provider pattern implementation
- **UI/UX**: Modern Material Design 3 with accessibility considerations
- **Cross-Platform**: Single codebase for Android, iOS, and Web

---

**🎓 PSW-2025-2 Individual Assignment Level 2 - Complete**  
**Happy Shopping! 🛍️**
