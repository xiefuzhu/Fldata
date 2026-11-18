import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'app_shell.dart';

/// Keeps each engine pane alive while the window changes its arrangement.
class LabWorkspaceLayout extends StatefulWidget {
  const LabWorkspaceLayout({
    super.key,
    required this.toolbar,
    required this.stage,
    required this.code,
    required this.callStack,
    required this.memory,
    required this.theory,
    required this.miniCode,
    required this.transport,
  });
  final Widget toolbar,
      stage,
      code,
      callStack,
      memory,
      theory,
      miniCode,
      transport;
  @override
  State<LabWorkspaceLayout> createState() => _LabWorkspaceLayoutState();
}

class _LabWorkspaceLayoutState extends State<LabWorkspaceLayout>
    with TickerProviderStateMixin {
  final stageKey = GlobalKey();
  final codeKey = GlobalKey();
  final callStackKey = GlobalKey();
  final memoryKey = GlobalKey();
  final theoryKey = GlobalKey();
  final sheet = DraggableScrollableController();
  late final panels = TabController(length: 3, vsync: this)
    ..addListener(refresh);
  late final details = TabController(length: 3, vsync: this)
    ..addListener(refresh);
  late final inspectorTabs = TabController(length: 2, vsync: this)
    ..addListener(refresh);
  double stageFraction = .55;
  double codeFraction = .6;
  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    panels.dispose();
    details.dispose();
    inspectorTabs.dispose();
    sheet.dispose();
    super.dispose();
  }

  void openCode() {
    panels.index = 0;
    sheet.animateTo(
      .85,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Widget surface(Widget child, {Key? key}) => Material(
    key: key,
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(20),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: const EdgeInsets.all(8), child: child),
  );
  Widget tabs(
    TabController controller,
    List<String> labels,
    List<Widget> children,
  ) => Column(
    children: [
      SizedBox(
        height: 48,
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [for (final label in labels) Tab(text: label)],
        ),
      ),
      Expanded(
        child: IndexedStack(index: controller.index, children: children),
      ),
    ],
  );
  Widget divider({
    required bool horizontal,
    required double fraction,
    required ValueChanged<double> onChanged,
    required double extent,
    required String label,
  }) {
    void change(double delta) => onChanged((fraction + delta).clamp(.3, .75));
    return Semantics(
      label: label,
      value: '${(fraction * 100).round()}%',
      increasedValue: '${((fraction + .05).clamp(.3, .75) * 100).round()}%',
      decreasedValue: '${((fraction - .05).clamp(.3, .75) * 100).round()}%',
      onIncrease: () => change(.05),
      onDecrease: () => change(-.05),
      child: MouseRegion(
        cursor: horizontal
            ? SystemMouseCursors.resizeColumn
            : SystemMouseCursors.resizeRow,
        child: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          key: ValueKey(horizontal ? 'stage-divider' : 'code-divider'),
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: horizontal
              ? (d) => change(d.delta.dx / extent)
              : null,
          onVerticalDragUpdate: horizontal
              ? null
              : (d) => change(d.delta.dy / extent),
          onDoubleTap: () => onChanged(horizontal ? .55 : .6),
          child: SizedBox(
            width: horizontal ? 12 : null,
            height: horizontal ? null : 12,
            child: Center(
              child: Container(
                width: horizontal ? 4 : 36,
                height: horizontal ? 36 : 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = LayoutBreakpointScope.of(context);
    final stage = KeyedSubtree(key: stageKey, child: widget.stage);
    final code = KeyedSubtree(key: codeKey, child: widget.code);
    final callStack = KeyedSubtree(key: callStackKey, child: widget.callStack);
    final memory = KeyedSubtree(key: memoryKey, child: widget.memory);
    final inspectors = tabs(
      inspectorTabs,
      ['调用栈', '内存与辅助表'],
      [callStack, memory],
    );
    final theory = KeyedSubtree(key: theoryKey, child: widget.theory);
    Widget content;
    switch (breakpoint) {
      case LayoutBreakpoint.expanded:
        content = LayoutBuilder(
          builder: (context, c) {
            final usableWidth = c.maxWidth - 12;
            // The right pane must still fit the three language controls.
            final left = (usableWidth * stageFraction).clamp(
              240.0,
              usableWidth - 300,
            );
            return Row(
              key: const ValueKey('workspace-expanded'),
              children: [
                SizedBox(width: left, child: surface(stage)),
                divider(
                  horizontal: true,
                  fraction: left / usableWidth,
                  extent: usableWidth,
                  label: '调整舞台宽度',
                  onChanged: (v) => setState(() => stageFraction = v),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, right) {
                      final usableHeight = right.maxHeight - 12;
                      final codeHeight = (usableHeight * codeFraction).clamp(
                        usableHeight * .3,
                        usableHeight - math.min(160, usableHeight * .5),
                      );
                      return Column(
                        children: [
                          SizedBox(height: codeHeight, child: surface(code)),
                          divider(
                            horizontal: false,
                            fraction: codeHeight / usableHeight,
                            extent: usableHeight,
                            label: '调整代码面板高度',
                            onChanged: (v) => setState(() => codeFraction = v),
                          ),
                          Expanded(
                            child: surface(
                              tabs(
                                details,
                                ['调用栈', '内存与辅助表', '原理与复杂度'],
                                [callStack, memory, theory],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      case LayoutBreakpoint.medium:
        content = Column(
          key: const ValueKey('workspace-medium'),
          children: [
            Expanded(flex: 55, child: surface(stage)),
            const SizedBox(height: 12),
            Expanded(
              flex: 45,
              child: surface(
                tabs(
                  panels,
                  ['代码调试', '调用栈与内存表', '原理与复杂度'],
                  [code, inspectors, theory],
                ),
              ),
            ),
          ],
        );
      case LayoutBreakpoint.compact:
        content = LayoutBuilder(
          builder: (context, c) => Stack(
            key: const ValueKey('workspace-compact'),
            children: [
              Positioned.fill(
                child: surface(
                  Padding(
                    padding: EdgeInsets.only(
                      top: 32 + 40 * MediaQuery.textScalerOf(context).scale(1),
                      bottom: c.maxHeight * .12,
                    ),
                    child: stage,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: Material(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHigh.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    key: const ValueKey('mini-code-open'),
                    onTap: openCode,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: widget.miniCode,
                    ),
                  ),
                ),
              ),
              DraggableScrollableSheet(
                key: const ValueKey('workspace-sheet'),
                controller: sheet,
                initialChildSize: .12,
                minChildSize: .12,
                maxChildSize: .85,
                snap: true,
                snapSizes: const [.12, .45, .85],
                shouldCloseOnMinExtent: false,
                builder: (context, scroll) => Material(
                  elevation: 8,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CustomScrollView(
                    controller: scroll,
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 48,
                          child: InkWell(
                            key: const ValueKey('sheet-handle'),
                            onTap: () => sheet.animateTo(
                              sheet.size < .8 ? .85 : .12,
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.drag_handle),
                                SizedBox(width: 8),
                                Text('代码与检查器'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: c.maxHeight * .85 - 48,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: tabs(
                              panels,
                              ['代码调试', '调用栈与内存表', '原理与复杂度'],
                              [code, inspectors, theory],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
    }
    return Padding(
      padding: EdgeInsets.all(breakpoint == LayoutBreakpoint.compact ? 8 : 16),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: widget.toolbar,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: content),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: widget.transport,
            ),
          ),
        ],
      ),
    );
  }
}
