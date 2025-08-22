# Screenshots

Please add the following screenshots to this directory:

1. **home.png** - Home screen showing list of grocery lists
2. **list.png** - List detail screen with items
3. **add_item.png** - Adding new item interface
4. **filter.png** - Filtering and sorting options

## How to take screenshots

### Android

```bash
flutter run
# Use device screenshot or adb
adb exec-out screencap -p > screenshots/home.png
```

### Web

```bash
flutter run -d chrome
# Use browser developer tools to take screenshots at mobile resolution
```

### Recommended Resolution

- Mobile: 375x812 (iPhone X dimensions)
- Web: 1200x800 (Desktop view)

## Image Guidelines

- Use PNG format for quality
- Show realistic data (not just test data)
- Ensure good lighting/contrast
- Include various states (empty lists, filled lists, checked items)
