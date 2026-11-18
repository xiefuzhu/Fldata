import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../curriculum/catalog.dart';
import '../layout/app_shell.dart';

Future<void> showCommandPalette(BuildContext context) async {
  final router = GoRouter.of(context);
  final selection = await showDialog<String>(
    context: context,
    builder: (_) => const _CommandPalette(),
  );
  if (selection != null) router.go(selection);
}

class _CommandPalette extends StatefulWidget {
  const _CommandPalette();
  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<_CommandPalette> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final items =
        [
              ...destinations.map(
                (d) => (label: d.label, path: d.path, icon: d.icon),
              ),
              ...modules.map(
                (m) => (
                  label: m.title,
                  path: '/lab/${m.id}',
                  icon: Icons.science_outlined,
                ),
              ),
              ...chapters.map(
                (c) => (
                  label: '${c.title} · 第 ${c.id.index + 1} 章',
                  path: '/catalog?chapter=${c.id.name}',
                  icon: Icons.menu_book_outlined,
                ),
              ),
            ]
            .where(
              (item) => item.label.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                onChanged: (value) => setState(() => query = value),
                onSubmitted: (_) {
                  if (items.isNotEmpty) {
                    Navigator.of(context).pop(items.first.path);
                  }
                },
                decoration: const InputDecoration(
                  hintText: '搜索页面、章节或实验…',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
              const Divider(),
              Flexible(
                child: items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('没有匹配结果'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (_, i) => ListTile(
                          leading: Icon(items[i].icon),
                          title: Text(items[i].label),
                          onTap: () => Navigator.of(context).pop(items[i].path),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
