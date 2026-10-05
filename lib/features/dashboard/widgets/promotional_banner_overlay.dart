import 'package:flutter/material.dart';

class PromotionalBannerOverlay extends StatelessWidget {
  final Widget child;
  const PromotionalBannerOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned(left: 0, right: 0, bottom: 0, child: child);
  }
}
