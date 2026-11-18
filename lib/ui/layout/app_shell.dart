import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum LayoutBreakpoint {
  compact,
  medium,
  expanded;

  static LayoutBreakpoint fromWidth(double width) => width < 600
      ? compact
      : width < 1100
      ? medium
      : expanded;
}

class LayoutBreakpointScope extends InheritedWidget {
  const LayoutBreakpointScope({
    super.key,
    required this.breakpoint,
    required super.child,
  });
  final LayoutBreakpoint breakpoint;
  static LayoutBreakpoint of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<LayoutBreakpointScope>()
          ?.breakpoint ??
      LayoutBreakpoint.fromWidth(MediaQuery.sizeOf(context).width);
  @override
  bool updateShouldNotify(LayoutBreakpointScope oldWidget) =>
      oldWidget.breakpoint != breakpoint;
}

const destinations = [
  (path: '/dashboard', label: '学习总览', icon: Icons.space_dashboard_outlined),
  (path: '/catalog', label: '课程目录', icon: Icons.menu_book_outlined),
  (path: '/lab/overview', label: '实验室', icon: Icons.science_outlined),
  (path: '/assessment', label: '评测中心', icon: Icons.fact_check_outlined),
  (path: '/settings', label: '设置', icon: Icons.tune),
];

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selected = destinations.indexWhere(
      (d) => location.startsWith(d.path.split('/').take(2).join('/')),
    );
    final index = selected < 0 ? 0 : selected;
    void select(int value) => context.go(destinations[value].path);
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = LayoutBreakpoint.fromWidth(constraints.maxWidth);
        final workspace = LayoutBreakpointScope(
          breakpoint: breakpoint,
          child: child,
        );
        if (breakpoint == LayoutBreakpoint.compact) {
          return Scaffold(
            body: SafeArea(child: workspace),
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: select,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(icon: Icon(d.icon), label: d.label),
              ],
            ),
          );
        }
        final expanded = breakpoint == LayoutBreakpoint.expanded;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                SizedBox(
                  width: expanded ? 220 : 76,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: expanded ? 24 : 8,
                          vertical: 32,
                        ),
                        child: expanded
                            ? const Row(
                                children: [
                                  Icon(Icons.account_tree, size: 28),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Fldata',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const Icon(Icons.account_tree, size: 28),
                      ),
                      Expanded(
                        child: NavigationRail(
                          extended: expanded,
                          minExtendedWidth: 220,
                          minWidth: 76,
                          selectedIndex: index,
                          onDestinationSelected: select,
                          labelType: NavigationRailLabelType.none,
                          destinations: [
                            for (final d in destinations)
                              NavigationRailDestination(
                                icon: Icon(d.icon),
                                label: Text(d.label),
                              ),
                          ],
                        ),
                      ),
                      if (expanded)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            '数据结构 · 从原理到实践 / 第 2 版',
                            style: TextStyle(fontSize: 12, height: 1.8),
                          ),
                        ),
                    ],
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                Expanded(child: workspace),
              ],
            ),
          ),
        );
      },
    );
  }
}
