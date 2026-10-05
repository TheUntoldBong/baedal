import 'package:flutter/material.dart';


class ColorWraper extends StatelessWidget {
  final Widget child;
  const ColorWraper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.withAlpha(50),
      child: child,
    );
  }
}
