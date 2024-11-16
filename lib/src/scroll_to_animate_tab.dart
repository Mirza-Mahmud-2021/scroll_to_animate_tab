import 'package:flutter/material.dart';
import 'package:scroll_to_animate_tab/scroll_to_animate_tab.dart';
import 'package:scroll_to_animate_tab/src/scroll_to_animate_tab_normal.dart';
import 'package:scroll_to_animate_tab/src/scroll_to_animate_tab_sliver.dart';

const Duration _kScrollDuration = Duration(milliseconds: 200);
const EdgeInsetsGeometry _kTabMargin = EdgeInsets.symmetric(
  vertical: 5,
  horizontal: 8,
);
const EdgeInsetsGeometry _kTabPadding = EdgeInsets.symmetric(
  vertical: 5,
  horizontal: 12,
);

class ScrollToAnimateTab extends StatelessWidget {
  /// Create a new [ScrollToAnimateTab]
  ScrollToAnimateTab({
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
  }) {
    _isSliver = false;
  }

  ScrollToAnimateTab.sliver({
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
  }) {
    _isSliver = true;
  }

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

  late bool _isSliver = false;

  @override
  Widget build(BuildContext context) {
    if (_isSliver) {
      return ScrollToAnimateTabSliver(
        tabs: tabs,
        tabHeight: tabHeight,
        tabAnimationDuration: tabAnimationDuration,
        bodyAnimationDuration: bodyAnimationDuration,
        tabAnimationCurve: tabAnimationCurve,
        bodyAnimationCurve: bodyAnimationCurve,
        backgroundColor: backgroundColor,
        activeTabDecoration: activeTabDecoration,
        inActiveTabDecoration: inActiveTabDecoration,
      );
    }
    return ScrollToAnimateTabNormal(
      tabs: tabs,
      tabHeight: tabHeight,
      tabAnimationDuration: tabAnimationDuration,
      bodyAnimationDuration: bodyAnimationDuration,
      tabAnimationCurve: tabAnimationCurve,
      bodyAnimationCurve: bodyAnimationCurve,
      backgroundColor: backgroundColor,
      activeTabDecoration: activeTabDecoration,
      inActiveTabDecoration: inActiveTabDecoration,
    );
  }
}
