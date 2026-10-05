import 'package:flutter/material.dart';


class CustomizableSpaceBarWidget extends StatelessWidget {
  const CustomizableSpaceBarWidget({super.key, required this.builder});
  final Widget Function(BuildContext context, double scrollingRate) builder;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final FlexibleSpaceBarSettings settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

        final double deltaExtent = settings.maxExtent - settings.minExtent;

        final double scrollingRate =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
            .clamp(0.0, 1.0);
        return builder(context, scrollingRate);
      },
    );
  }
}
