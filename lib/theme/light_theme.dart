// ignore_for_file: unused_element
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


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
const Color surfaceContainer = Color(0xFFFFFFFF);
const Color surface = Color(0xFFF5F5F5);

const SystemUiOverlayStyle lightSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

ThemeData light = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: _primaryColor,
  secondaryHeaderColor: _primaryColor.withValues(alpha: 0.61),
  disabledColor: const Color(0xFFEDEDED),
  brightness: Brightness.light,
  hintColor: const Color(0xFF757575),
  cardColor: Colors.white,
  shadowColor: Colors.black.withValues(alpha: 0.05),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: _primaryColor)),
  colorScheme: ColorScheme.light(
    primary: _primaryColor,
    onPrimary: Colors.white,
    primaryContainer: _primary400,
    onPrimaryContainer: _primary900,
    primaryFixed: _primary100,
    onPrimaryFixed: _primary1000,
    secondary: _primaryColor,
    tertiary: const Color(0xFF224A8A),
    tertiaryContainer: const Color(0xFFE1EBFA),
    error: const Color(0xFFEC221F),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFDD3D0),
    onErrorContainer: const Color(0xFF900B09),
    surface: surface,
    onSurface: const Color(0xFF1E1E1E),
    surfaceContainerLowest: const Color(0xFFEDEDED),
    surfaceContainerLow: const Color(0xFFD9D9D9),
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: const Color(0xFFCDCDCD),
    surfaceContainerHighest: const Color(0xFFA3A3A3),
    onSurfaceVariant: const Color(0xFFFFFFFF),
    outline: Color(0xFFEDEDED),
    outlineVariant: Color(0xFFD9D9D9),
    shadow: Color(0x0d000000),
    scrim: Colors.black.withValues(alpha: 0.6),
  ),
  appBarTheme: const AppBarTheme(systemOverlayStyle: lightSystemUiOverlayStyle),
  popupMenuTheme: const PopupMenuThemeData(color: surface, shadowColor: surfaceContainer),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white, backgroundColor: Color(0xFFFFFFFF)),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    extendedSizeConstraints: const BoxConstraints.tightFor(height: 40),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.white, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: DividerThemeData(color: const Color(0xFFEDEDED), thickness: 1),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
