import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/list_detail_provider.dart';
import '../models/grocery_item.dart';
import '../models/category.dart';
import '../utils/category_utils.dart';

class ListDetailScreen extends StatefulWidget {
  final int listId;
  const ListDetailScreen({super.key, required this.listId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  Category _selectedCategory = Category.others;
  // filter and sort state
  _FilterMode _filterMode = _FilterMode.all;
  _SortMode _sortMode = _SortMode.category;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    final prov = Provider.of<ListDetailProvider>(context, listen: false);
    await prov.loadList(widget.listId);
    if (!mounted) return;
    if (prov.errorMessage != null) {
      // analyzer: guarded by mounted above; context use is safe
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(prov.errorMessage!)));
    }
  }

  void _addItemInline() async {
    final name = _nameController.text.trim();
    final qty = int.tryParse(_qtyController.text) ?? 1;
    if (name.isNotEmpty) {
      final item = GroceryItem(
        id: 0,
        name: name,
        quantity: qty,
        category: _selectedCategory,
      );
      final prov = Provider.of<ListDetailProvider>(context, listen: false);
      final messenger = ScaffoldMessenger.of(context);
      try {
        await prov.addItem(item);
        if (!mounted) return;
        _nameController.clear();
        _qtyController.text = '1';
        setState(() => _selectedCategory = Category.others);
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _showEditBottomSheet(GroceryItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    Category editCategory = item.category;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: MediaQuery.of(
              context,
            ).viewInsets.add(const EdgeInsets.all(16.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  'Edit item',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: qtyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<Category>(
                        initialValue: editCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items:
                            Category.values
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Row(
                                      children: [
                                        Icon(
                                          iconForCategory(c),
                                          color: colorForCategory(c),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(categoryToLabel(c)),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => editCategory = v ?? editCategory,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final newName = nameCtrl.text.trim();
                        final newQty =
                            int.tryParse(qtyCtrl.text) ?? item.quantity;
                        if (newName.isNotEmpty) {
                          final updated = item.copyWith(
                            name: newName,
                            quantity: newQty,
                            category: editCategory,
                          );
                          final prov = Provider.of<ListDetailProvider>(
                            context,
                            listen: false,
                          );
                          final navigator = Navigator.of(context);
                          await prov.updateItem(updated);
                          navigator.pop();
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ListDetailProvider>(context);
    final items = provider.list?.items ?? [];

    final completed = items.where((i) => i.isChecked).length;
    final total = items.length;

    // group by category preserving enum order
    final Map<Category, List<GroceryItem>> groups = {
      for (var c in Category.values) c: [],
    };
    for (final it in items) groups[it.category]!.add(it);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.list?.name ?? 'List',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              '$completed of $total items',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 1,
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 10,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Single row: name and qty
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      hintText: 'Add new item...',
                                      filled: true,
                                      fillColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.surfaceVariant,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 72,
                                  child: TextField(
                                    controller: _qtyController,
                                    decoration: InputDecoration(
                                      hintText: 'Qty',
                                      filled: true,
                                      fillColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.surfaceVariant,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 12,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Second row: category (expanded to avoid overflow) and Add
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<Category>(
                                    initialValue: _selectedCategory,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.surfaceVariant,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    items:
                                        Category.values
                                            .map(
                                              (c) => DropdownMenuItem(
                                                value: c,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      iconForCategory(c),
                                                      color: colorForCategory(
                                                        c,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Flexible(
                                                      child: Text(
                                                        categoryToLabel(c),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    // ensure the closed state also shows icon + label
                                    selectedItemBuilder:
                                        (context) =>
                                            Category.values
                                                .map(
                                                  (c) => Row(
                                                    children: [
                                                      Icon(
                                                        iconForCategory(c),
                                                        color: colorForCategory(
                                                          c,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Flexible(
                                                        child: Text(
                                                          categoryToLabel(c),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                .toList(),
                                    onChanged:
                                        (v) => setState(
                                          () =>
                                              _selectedCategory =
                                                  v ?? Category.others,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _addItemInline,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add'),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    minimumSize: const Size(64, 44),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Filter & Sort row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ToggleButtons(
                              borderRadius: BorderRadius.circular(8),
                              isSelected: [
                                _filterMode == _FilterMode.all,
                                _filterMode == _FilterMode.incomplete,
                                _filterMode == _FilterMode.complete,
                              ],
                              onPressed: (index) {
                                setState(() {
                                  _filterMode = _FilterMode.values[index];
                                });
                              },
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('All'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('To buy'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('Bought'),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.sort, size: 18),
                            const SizedBox(width: 8),
                            DropdownButton<_SortMode>(
                              value: _sortMode,
                              underline: const SizedBox.shrink(),
                              items: [
                                DropdownMenuItem(
                                  value: _SortMode.category,
                                  child: Text('Category'),
                                ),
                                DropdownMenuItem(
                                  value: _SortMode.name,
                                  child: Text('Name'),
                                ),
                                DropdownMenuItem(
                                  value: _SortMode.quantity,
                                  child: Text('Quantity'),
                                ),
                              ],
                              onChanged:
                                  (v) => setState(
                                    () => _sortMode = v ?? _SortMode.category,
                                  ),
                            ),
                            const Spacer(),
                            Text('${completed}/${total}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        // apply filter
                        List<GroceryItem> filtered = List.from(items);
                        if (_filterMode == _FilterMode.incomplete)
                          filtered =
                              filtered.where((i) => !i.isChecked).toList();
                        if (_filterMode == _FilterMode.complete)
                          filtered =
                              filtered.where((i) => i.isChecked).toList();

                        // Show empty state if no items
                        if (items.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 80,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No items yet',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first item using the form above',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Show empty state for filtered results
                        if (filtered.isEmpty) {
                          String emptyMessage;
                          IconData emptyIcon;

                          switch (_filterMode) {
                            case _FilterMode.incomplete:
                              emptyMessage = 'All items are completed!';
                              emptyIcon = Icons.check_circle_outline;
                              break;
                            case _FilterMode.complete:
                              emptyMessage = 'No completed items yet';
                              emptyIcon = Icons.radio_button_unchecked;
                              break;
                            default:
                              emptyMessage =
                                  'No items match your current filter';
                              emptyIcon = Icons.filter_list_off;
                          }

                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    emptyIcon,
                                    size: 64,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    emptyMessage,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (_sortMode == _SortMode.category) {
                          // group by category
                          final Map<Category, List<GroceryItem>> displayGroups =
                              {for (var c in Category.values) c: []};
                          for (final it in filtered)
                            displayGroups[it.category]!.add(it);
                          return ListView(
                            children:
                                Category.values.expand((cat) {
                                  final group = displayGroups[cat]!;
                                  if (group.isEmpty) return <Widget>[];
                                  return [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            iconForCategory(cat),
                                            color: colorForCategory(cat),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            categoryToLabel(cat),
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...group
                                        .map(
                                          (it) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                              vertical: 6.0,
                                            ),
                                            child: Dismissible(
                                              key: ValueKey('item-${it.id}'),
                                              direction:
                                                  DismissDirection.endToStart,
                                              background: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                                padding: const EdgeInsets.only(
                                                  right: 16.0,
                                                ),
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onDismissed: (_) async {
                                                final messenger =
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    );
                                                try {
                                                  await provider.removeItem(
                                                    it.id,
                                                  );
                                                } catch (e) {
                                                  if (!mounted) return;
                                                  messenger.showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        e.toString(),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: ListTile(
                                                  onLongPress:
                                                      () =>
                                                          _showEditBottomSheet(
                                                            it,
                                                          ),
                                                  leading: Checkbox(
                                                    value: it.isChecked,
                                                    onChanged:
                                                        (_) async =>
                                                            await provider
                                                                .toggleItem(
                                                                  it.id,
                                                                ),
                                                  ),
                                                  title: Text(
                                                    it.name,
                                                    style:
                                                        it.isChecked
                                                            ? TextStyle(
                                                              color:
                                                                  Theme.of(
                                                                    context,
                                                                  ).disabledColor,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                            )
                                                            : null,
                                                  ),
                                                  subtitle: Text(
                                                    'Qty: ${it.quantity}',
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              colorForCategory(
                                                                it.category,
                                                              ).withOpacity(
                                                                0.12,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          categoryToLabel(
                                                            it.category,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      IconButton(
                                                        onPressed: () async {
                                                          final messenger =
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              );
                                                          try {
                                                            await provider
                                                                .removeItem(
                                                                  it.id,
                                                                );
                                                          } catch (e) {
                                                            if (!mounted)
                                                              return;
                                                            messenger.showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  e.toString(),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        icon: const Icon(
                                                          Icons.delete,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ];
                                }).toList(),
                          );
                        } else {
                          // sort flat list
                          if (_sortMode == _SortMode.name) {
                            filtered.sort(
                              (a, b) => a.name.toLowerCase().compareTo(
                                b.name.toLowerCase(),
                              ),
                            );
                          } else if (_sortMode == _SortMode.quantity) {
                            filtered.sort(
                              (a, b) => a.quantity.compareTo(b.quantity),
                            );
                          }
                          return ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.sort),
                                    const SizedBox(width: 8),
                                    Text(
                                      _sortMode == _SortMode.name
                                          ? 'Sorted by Name'
                                          : 'Sorted by Quantity',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                              ...filtered.map(
                                (it) => Dismissible(
                                  key: ValueKey('item-${it.id}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) async {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    try {
                                      await provider.removeItem(it.id);
                                    } catch (e) {
                                      if (!mounted) return;
                                      messenger.showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 6.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      onLongPress:
                                          () => _showEditBottomSheet(it),
                                      leading: Checkbox(
                                        value: it.isChecked,
                                        onChanged:
                                            (_) async => await provider
                                                .toggleItem(it.id),
                                      ),
                                      title: Text(it.name),
                                      subtitle: Text('Qty: ${it.quantity}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorForCategory(
                                                it.category,
                                              ).withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              categoryToLabel(it.category),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed:
                                                () async => await provider
                                                    .removeItem(it.id),
                                            icon: const Icon(Icons.delete),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}

enum _FilterMode { all, incomplete, complete }

enum _SortMode { category, name, quantity }
