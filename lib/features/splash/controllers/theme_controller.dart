import 'package:stackfood_multivendor/features/splash/domain/services/splash_service_interface.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

enum AppThemeMode { light, dark, system }

class ThemeController extends GetxController with WidgetsBindingObserver implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  ThemeController({required this.splashServiceInterface}) {
    _loadCurrentTheme();
  }

  AppThemeMode _themeMode = AppThemeMode.light;
  AppThemeMode get themeMode => _themeMode;

  bool _darkTheme = false;
  bool get darkTheme => _darkTheme;

  String _lightMap = '[]';
  String get lightMap => _lightMap;

  String _darkMap = '[]';
  String get darkMap => _darkMap;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if(_themeMode == AppThemeMode.system) {
      _darkTheme = _isSystemDark();
      update();
    }
  }

  void toggleTheme() {
    setThemeMode(_darkTheme ? AppThemeMode.light : AppThemeMode.dark);
  }

  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    _darkTheme = _resolveDarkTheme(mode);
    splashServiceInterface.saveThemeMode(mode.name);
    update();
  }

  bool _resolveDarkTheme(AppThemeMode mode) {
    if(mode == AppThemeMode.system) {
      return _isSystemDark();
    }
    return mode == AppThemeMode.dark;
  }

  bool _isSystemDark() {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  void _loadCurrentTheme() async {
    _lightMap = await rootBundle.loadString('assets/map/light_map.json');
    _darkMap = await rootBundle.loadString('assets/map/dark_map.json');
    final String savedMode = await splashServiceInterface.loadThemeMode();
    _themeMode = AppThemeMode.values.firstWhere((mode) => mode.name == savedMode, orElse: () => AppThemeMode.system);
    _darkTheme = _resolveDarkTheme(_themeMode);
    update();
  }
}
