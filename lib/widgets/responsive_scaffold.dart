import 'package:flutter/material.dart';

/// A responsive scaffold that shows a single column on small screens (phone)
/// and a two-pane layout on wide screens (web/desktop) with a left list pane
/// and right detail pane.
///
/// Usage:
/// ResponsiveScaffold(
///   listPane: MyListWidget(onSelect: ...),
///   detailPane: MyDetailWidget(...),
/// )
class ResponsiveScaffold extends StatelessWidget {
  final Widget listPane;
  final Widget detailPane;
  final String title;

  /// breakpoint in logical pixels where layout switches to two-pane
  final double breakpoint;

  const ResponsiveScaffold({
    super.key,
    required this.listPane,
    required this.detailPane,
    this.title = 'App',
    this.breakpoint = 800,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= breakpoint;

    if (!isWide) {
      // Small screen: single column scaffold. The listPane is expected to
      // navigate to detail screen using Navigator.
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ScrollConfiguration(
              behavior: _SmoothScrollBehavior(),
              child: listPane,
            ),
          ),
        ),
      );
    }

    // Wide screen: two panes
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Left pane - list
            Container(
              width: 360,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                border: Border(
                  right: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withAlpha((0.08 * 255).round()),
                  ),
                ),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 24,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodyMedium!,
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            // ignore: deprecated_member_use
                            textScaleFactor: MediaQuery.of(
                              context,
                            ).textScaleFactor.clamp(1.0, 1.2),
                          ),
                          child: listPane,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Divider
            const VerticalDivider(width: 1, thickness: 1),

            // Right pane - detail
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: ScrollConfiguration(
                  behavior: _SmoothScrollBehavior(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 24,
                      ),
                      child: detailPane,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmoothScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();
}
