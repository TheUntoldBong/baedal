import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/theme/dark_theme.dart' as dark_theme;
import 'package:stackfood_multivendor/theme/light_theme.dart' as light_theme;

SystemUiOverlayStyle get appSystemUiOverlayStyle => Get.isDarkMode
    ? dark_theme.darkSystemUiOverlayStyle
    : light_theme.lightSystemUiOverlayStyle;

SystemUiOverlayStyle systemUiOverlayStyleOf(BuildContext context, {Color? statusBarColor}) {
  final SystemUiOverlayStyle base = Theme.of(context).brightness == Brightness.dark
      ? dark_theme.darkSystemUiOverlayStyle
      : light_theme.lightSystemUiOverlayStyle;
  return statusBarColor == null ? base : base.copyWith(statusBarColor: statusBarColor);
}
