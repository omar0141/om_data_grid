import 'package:flutter/material.dart';

class ScrollHelper {
  ScrollHelper._();
  static final ScrollHelper _instance = ScrollHelper._();
  factory ScrollHelper() => _instance;

  void scrollToSelectedItem({
    required ScrollController scrollController,
    required int selectedIndex,
    required double itemHeight,
  }) {
    if (selectedIndex >= 0) {
      // Calculate the position of the selected item
      final double itemPosition = selectedIndex * itemHeight;

      // Calculate the visible area of the scroll view
      final double scrollViewHeight =
          scrollController.position.viewportDimension;

      // Calculate the start position for scrolling
      // This centers the item in the visible area if possible
      final double scrollPosition =
          itemPosition - (scrollViewHeight / 2) + (itemHeight / 2);

      // Ensure we don't scroll beyond bounds
      final double maxScroll = scrollController.position.maxScrollExtent;
      final double boundedPosition = scrollPosition.clamp(0.0, maxScroll);

      scrollController.animateTo(
        boundedPosition,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
  }
}
