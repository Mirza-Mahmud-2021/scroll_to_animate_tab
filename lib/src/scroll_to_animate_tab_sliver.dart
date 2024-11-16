import 'package:flutter/material.dart';
import 'package:scroll_to_animate_tab/scroll_to_animate_tab.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:rect_getter/rect_getter.dart';
const Duration _kScrollDuration = Duration(milliseconds: 200);
const EdgeInsetsGeometry _kTabMargin = EdgeInsets.symmetric(
  vertical: 5,
  horizontal: 8,
);
const EdgeInsetsGeometry _kTabPadding = EdgeInsets.symmetric(
  vertical: 5,
  horizontal: 12,
);
class ScrollToAnimateTabSliver extends StatefulWidget {
  const ScrollToAnimateTabSliver({
    Key? key,
    required this.tabs,
  }) : super(key: key);

  /// List of tabs to be rendered.
  final List<ScrollableList> tabs;

  @override
  _ScrollToAnimateTabSliverState createState() =>
      _ScrollToAnimateTabSliverState();
}

class _ScrollToAnimateTabSliverState extends State<ScrollToAnimateTabSliver>
    with SingleTickerProviderStateMixin {
  late AutoScrollController scrollController;
  late TabController tabController;

  final ValueNotifier<bool> isCollapsedNotifier = ValueNotifier(false);
  final listViewKey = RectGetter.createGlobalKey();

  Map<int, GlobalKey<RectGetterState>> itemKeys = {};
  bool pauseRectGetterIndex = false;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: widget.tabs.length, vsync: this);
    scrollController = AutoScrollController();
  }

  @override
  void dispose() {
    isCollapsedNotifier.dispose();
    scrollController.dispose();
    tabController.dispose();
    super.dispose();
  }

  // This method determines when the app bar should be collapsed
  void onCollapsed({required bool value}) {
    if (isCollapsedNotifier.value != value) {
      isCollapsedNotifier.value = value;
    }
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (pauseRectGetterIndex || isAnimating) return true;

    final List<int> visibleItems = getVisibleItemsIndex();

    if (visibleItems.isNotEmpty) {
      tabController.animateTo(visibleItems.first);
    }
    return true;
  }

  List<int> getVisibleItemsIndex() {
    final Rect? rect = RectGetter.getRectFromKey(listViewKey);
    final List<int> items = [];
    if (rect == null) return items;

    itemKeys.forEach((index, key) {
      final Rect? itemRect = RectGetter.getRectFromKey(key);
      if (itemRect == null) return;
      if (itemRect.top - 600 > rect.bottom) return;
      if (itemRect.bottom - 400 < rect.top) return;
      items.add(index);
    });
    return items;
  }

  void animateAndScrollTo(int index) {
    if (isAnimating) return;
    isAnimating = true;
    pauseRectGetterIndex = true;

    tabController.animateTo(index);
    scrollController
        .scrollToIndex(index,
            preferPosition: AutoScrollPosition.begin,
            duration: const Duration(milliseconds: 300))
        .then((_) {
      pauseRectGetterIndex = false;
      isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RectGetter(
        key: listViewKey,
        child: NotificationListener<ScrollNotification>(
          onNotification: onScrollNotification,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 200.0,
                title: ValueListenableBuilder<bool>(
                  valueListenable: isCollapsedNotifier,
                  builder: (context, isCollapsed, child) {
                    return AnimatedOpacity(
                      opacity: isCollapsed ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Text("Scroll Demo"),
                    );
                  },
                ),
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final top = constraints.biggest.height;
                    final collapsedHeight =
                        MediaQuery.of(context).padding.top + kToolbarHeight;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onCollapsed(value: top <= collapsedHeight + 10);
                    });

                    return FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Container(
                        color: Colors.blueAccent,
                        child: Center(
                          child: const Text(
                            "Collapsible App Bar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: TabBar(
                    controller: tabController,
                    onTap: (index) => animateAndScrollTo(index),
                    tabs:
                        widget.tabs.map((tab) => Tab(text: tab.label)).toList(),
                    isScrollable: true,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    print(index);
                    if (index >= widget.tabs.length) return null;
                    return buildSectionItem(index);
                  },
                  childCount: widget.tabs.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionItem(int index) {
    itemKeys[index] = RectGetter.createGlobalKey();
    return RectGetter(
      key: itemKeys[index]!,
      child: AutoScrollTag(
        key: ValueKey(index),
        index: index,
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: _kTabMargin.add(const EdgeInsets.all(5)),
              child: _buildInnerTab(index),
            ),
            widget.tabs[index].body,
          ],
        ),
      ),
    );
  }

  Widget _buildInnerTab(int index) {
    final tab = widget.tabs[index];
    return Builder(
      builder: (_) {
        if (tab.bodyLabelDecoration != null) {
          return tab.bodyLabelDecoration!;
        }
        return Text(
          tab.label.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        );
      },
    );
  }
}
