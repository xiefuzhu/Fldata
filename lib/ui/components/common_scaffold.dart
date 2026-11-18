import 'package:flutter/material.dart';
import '../../common/platform_detector.dart';
import '../managers/build_manager_stack.dart';
import '../tokens/m3e_springs.dart';

class CommonScaffold extends StatefulWidget {
  const CommonScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onSearch,
  });
  final String title;
  final String subtitle;
  final Widget child;
  final ValueChanged<String>? onSearch;
  @override
  State<CommonScaffold> createState() => _CommonScaffoldState();
}

class _CommonScaffoldState extends State<CommonScaffold> {
  bool searching = false;
  final focus = FocusNode();
  final text = TextEditingController();
  void openSearch() {
    if (widget.onSearch == null) return;
    setState(() => searching = true);
    focus.requestFocus();
  }

  @override
  void dispose() {
    focus.dispose();
    text.dispose();
    super.dispose();
  }

  Widget searchBox() => TextField(
    controller: text,
    onTap: PlatformDetector.selectionFeedback,
    focusNode: focus,
    onChanged: widget.onSearch,
    decoration: InputDecoration(
      hintText: '搜索章节与关键词',
      constraints: const BoxConstraints(minHeight: 48),
      prefixIcon: const Icon(Icons.search),
      suffixIcon: IconButton(
        tooltip: '清除搜索',
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        onPressed: () {
          PlatformDetector.selectionFeedback();
          text.clear();
          widget.onSearch?.call('');
          setState(() => searching = false);
        },
        icon: const Icon(Icons.close),
      ),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Actions(
    actions: {
      PageSearchIntent: CallbackAction<PageSearchIntent>(
        onInvoke: (_) {
          openSearch();
          return null;
        },
      ),
    },
    child: Focus(
      autofocus: true,
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = MediaQuery.sizeOf(context).width < 600;
          return Padding(
            padding: EdgeInsets.all(compact ? 16 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AnimatedSize(
                        duration: context.motionDuration,
                        curve: SpringCurve(M3eSprings.standardSpatial),
                        alignment: Alignment.centerLeft,
                        child: searching && !compact
                            ? searchBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.subtitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (widget.onSearch != null && !searching && !compact)
                      IconButton(
                        tooltip: '搜索当前页',
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        onPressed: () {
                          PlatformDetector.selectionFeedback();
                          openSearch();
                        },
                        icon: const Icon(Icons.search),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(child: widget.child),
                if (compact && widget.onSearch != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: searchBox(),
                  ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
