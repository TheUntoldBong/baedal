import 'package:flutter/material.dart';


class CouponClipper extends CustomClipper<Path> {
  final double borderRadius;
  final double notchRadius;

  CouponClipper({
    this.borderRadius = 12.0,
    this.notchRadius = 10.0,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(borderRadius, 0);

    path.lineTo(size.width - borderRadius, 0);
    path.arcToPoint(
      Offset(size.width, borderRadius),
      radius: Radius.circular(borderRadius),
    );

    path.lineTo(size.width, (size.height / 2) - notchRadius);
    path.arcToPoint(
      Offset(size.width, (size.height / 2) + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height - borderRadius);
    path.arcToPoint(
      Offset(size.width - borderRadius, size.height),
      radius: Radius.circular(borderRadius),
    );

    path.lineTo(borderRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - borderRadius),
      radius: Radius.circular(borderRadius),
    );

    path.lineTo(0, (size.height / 2) + notchRadius);
    path.arcToPoint(
      Offset(0, (size.height / 2) - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(0, borderRadius);
    path.arcToPoint(
      Offset(borderRadius, 0),
      radius: Radius.circular(borderRadius),
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
