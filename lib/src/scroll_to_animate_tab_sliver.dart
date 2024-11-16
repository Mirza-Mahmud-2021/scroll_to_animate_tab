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
    required this.tabs,
    this.tabHeight = kToolbarHeight,
    this.tabAnimationDuration = _kScrollDuration,
    this.bodyAnimationDuration = _kScrollDuration,
    this.tabAnimationCurve = Curves.decelerate,
    this.bodyAnimationCurve = Curves.decelerate,
    this.backgroundColor = Colors.transparent,
    this.activeTabDecoration,
    this.inActiveTabDecoration,
    super.key,
  });

  /// List of tabs to be rendered.
  final List<ScrollableList> tabs;

  /// Height of the tab at the top of the view.
  final double tabHeight;

  /// Duration of tab change animation.
  final Duration? tabAnimationDuration;

  /// Duration of inner scroll view animation.
  final Duration? bodyAnimationDuration;

  /// Animation curve used when animating tab change.
  final Curve? tabAnimationCurve;

  /// Animation curve used when changing index of inner [ScrollView]s.
  final Curve? bodyAnimationCurve;

  /// Change Tab Background Color
  final Color? backgroundColor;

  /// Change Active Tab Decoration
  final TabDecoration? activeTabDecoration;

  /// Change Inactive Tab Decoration.
  final TabDecoration? inActiveTabDecoration;

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
  final _index = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: widget.tabs.length, vsync: this);
    tabController.addListener(
      () {
        _index.value = tabController.index;
      },
    );
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
    tabController.animateTo(index);
    scrollController
        .scrollToIndex(
          index,
          preferPosition: AutoScrollPosition.begin,
          duration: const Duration(milliseconds: 300),
        )
        .then((_) {});
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
                expandedHeight: 300,
                title: ValueListenableBuilder<bool>(
                  valueListenable: isCollapsedNotifier,
                  builder: (context, isCollapsed, child) {
                    if (!isCollapsed)
                      return const Text(
                        'Scroll Demo',
                        style: TextStyle(color: Colors.yellow),
                      );

                    return const Text(
                      'Scroll Demo',
                      style: TextStyle(color: Colors.red),
                    );
                  },
                ),
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final top = constraints.biggest.height;
                    final collapsedHeight = MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        40;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onCollapsed(value: top <= collapsedHeight + 10);
                    });

                    return FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Container(
                        color: Colors.grey,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 200,
                                width: 200,
                                color: Colors.red,
                              ),
                              const Text(
                                'Collapsible App Bar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: widget.backgroundColor,
                    height: widget.tabHeight,
                    child: TabBar(
                      controller: tabController,
                      isScrollable: true,
                      padding: const EdgeInsets.all(0),
                      indicatorWeight: BorderSide.strokeAlignCenter,
                      indicatorSize: TabBarIndicatorSize.tab,
                      splashBorderRadius: BorderRadius.circular(10),
                      dividerColor: Colors.transparent,
                      tabAlignment: TabAlignment.start,
                      labelPadding: EdgeInsets.zero,
                      onTap: animateAndScrollTo,
                      indicator: const BoxDecoration(),
                      // Remove default indicator
                      tabs: widget.tabs.map((tab) {
                        return ValueListenableBuilder(
                          valueListenable: _index,
                          builder: (context, index, child) {
                            return Container(
                              margin: _kTabMargin,
                              padding: _kTabPadding,
                              alignment: Alignment.center,
                              decoration: index == widget.tabs.indexOf(tab)
                                  ? widget.activeTabDecoration?.decoration
                                  : widget.inActiveTabDecoration?.decoration,
                              child: _buildTab(
                                widget.tabs.indexOf(tab),
                                index == widget.tabs.indexOf(tab),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
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

  Widget _buildTab(int index, bool isSelected) {
    if (isSelected) {
      return Text(
        widget.tabs[index].label,
        style: widget.activeTabDecoration?.textStyle,
      );
    }
    return Text(
      widget.tabs[index].label,
      style: widget.inActiveTabDecoration?.textStyle,
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
