// ignore_for_file: unused_element
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stackfood_multivendor/util/styles.dart';

const Color _primaryColor = AppConstants.primaryColor;
final Color _primary1000 = Color.lerp(_primaryColor, Colors.black, 0.5)!;
final Color _primary900 = Color.lerp(_primaryColor, Colors.black, 0.3)!;
final Color _primary700 = Color.lerp(_primaryColor, Colors.white, 0.2)!;
final Color _primary600 = Color.lerp(_primaryColor, Colors.white, 0.4)!;
final Color _primary500 = Color.lerp(_primaryColor, Colors.white, 0.5)!;
final Color _primary400 = Color.lerp(_primaryColor, Colors.white, 0.6)!;
final Color _primary300 = Color.lerp(_primaryColor, Colors.white, 0.7)!;
final Color _primary200 = Color.lerp(_primaryColor, Colors.white, 0.8)!;
final Color _primary100 = Color.lerp(_primaryColor, Colors.white, 0.9)!;
const Color surfaceContainer = Color(0xFF1E1E1E);
const Color surface = Color(0xFF2C2C2C);

const SystemUiOverlayStyle darkSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: _primaryColor,
  secondaryHeaderColor: _primaryColor.withValues(alpha: 0.61),
  disabledColor: const Color(0xFF383838),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFA3A3A3),
  cardColor: const Color(0xFF1E1E1E),
  shadowColor: Colors.white.withValues(alpha: 0.05),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: _primaryColor, textStyle: heading.defaultSize)),
  colorScheme: ColorScheme.dark(
    primary: _primaryColor,
    onPrimary: Colors.white,
    primaryContainer: _primary400,
    onPrimaryContainer: _primary100,
    primaryFixed: _primary900,
    onPrimaryFixed: _primary100,
    secondary: _primaryColor.withValues(alpha: 0.61),
    tertiary: Color(0xFF6BA4FF),
    tertiaryContainer: Color(0xFF224A8A),
    error: Color(0xFFC00F0C),
    onError: Color(0xFF300603),
    errorContainer: Color(0xFF690807),
    onErrorContainer: Color(0xFFFDD3D0),
    surface: surface,
    onSurface: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFF2C2C2C),
    surfaceContainerLow: Color(0xFF444444),
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: Color(0xFF434343),
    surfaceContainerHighest: Color(0xFF383838),
    onSurfaceVariant: Color(0xFF242424),
    outline: Color(0xFF383838),
    outlineVariant: Color(0xFF444444),
    shadow: Color(0x0d000000),
    scrim: Color(0xFF000000),
  ),
  appBarTheme: const AppBarTheme(systemOverlayStyle: darkSystemUiOverlayStyle),
  popupMenuTheme: const PopupMenuThemeData(color: surface, shadowColor: surfaceContainer),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10, backgroundColor: Color(0xFF1E1E1E)),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    extendedSizeConstraints: const BoxConstraints.tightFor(height: 40),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.black, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: DividerThemeData(color: const Color(0xFF2C2C2C), thickness: 1),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
