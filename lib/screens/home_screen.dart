import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/lists_provider.dart';
import '../widgets/list_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    final prov = Provider.of<ListsProvider>(context, listen: false);
    await prov.loadLists();
    if (!mounted) return;
    if (prov.errorMessage != null) {
      // analyzer: this use of BuildContext is guarded by mounted and is safe here
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(prov.errorMessage!)));
    }
  }

  void _showCreateDialog() {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create List'),
            content: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'List name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = _controller.text.trim();
                  if (name.isNotEmpty) {
                    final prov = Provider.of<ListsProvider>(
                      context,
                      listen: false,
                    );
                    final navigator = Navigator.of(context);
                    await prov.create(name);
                    _controller.clear();
                    navigator.pop();
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listsProv = Provider.of<ListsProvider>(context);
    if (listsProv.isLoading && listsProv.lists.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!listsProv.isLoading && listsProv.lists.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grocery Lists')),
        body: Center(child: Text('No lists yet. Tap + to create one.')),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateDialog,
          child: const Icon(Icons.add),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Lists'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body:
          listsProv.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: listsProv.lists.length,
                itemBuilder: (context, index) {
                  final l = listsProv.lists[index];
                  return ListCard(
                    name: l.name,
                    itemCount: l.items.length,
                    onTap: () async {
                      await Navigator.of(
                        context,
                      ).pushNamed('/list', arguments: {'id': l.id});
                      // Reload data when returning from list detail
                      _load();
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
