import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AppThemeMode { light, dark, blue }

class ThemeConfig {
  final Brightness brightness;
  final Color seedColor;
  final Color scaffoldBg;
  final Color bgPrimary;
  final Color textMain;
  final Color textMuted;
  final Color gradStart;
  final Color gradEnd;
  final Color primaryAccent;
  final Color cardColor;
  final Color softBg;
  final Color navBarBg;
  final Color navIndicatorBg;
  final Color success;
  final Color warning;
  final Color info;

  ThemeConfig({
    required this.brightness,
    required this.seedColor,
    required this.scaffoldBg,
    required this.bgPrimary,
    required this.textMain,
    required this.textMuted,
    required this.gradStart,
    required this.gradEnd,
    required this.primaryAccent,
    required this.cardColor,
    required this.softBg,
    required this.navBarBg,
    required this.navIndicatorBg,
    required this.success,
    required this.warning,
    required this.info,
  });

  factory ThemeConfig.light() {
    return ThemeConfig(
      brightness: Brightness.light,
      seedColor: Colors.red,
      scaffoldBg: const Color(0xFFF5F5F7),
      bgPrimary: const Color(0xFFFEF2F2),
      textMain: const Color(0xFF1F2937),
      textMuted: Colors.grey.shade600,
      gradStart: const Color(0xFFEF4444), // red 500
      gradEnd: const Color(0xFF991B1B), // red 800
      primaryAccent: const Color(0xFFDC2626), // red 600
      cardColor: Colors.white,
      softBg: Colors.red.shade50,
      navBarBg: Colors.white,
      navIndicatorBg: Colors.red.shade600,
      success: const Color(0xFF10B981),
      warning: const Color(0xFFF97316),
      info: const Color(0xFF8B5CF6),
    );
  }

  factory ThemeConfig.dark() {
    return ThemeConfig(
      brightness: Brightness.dark,
      seedColor: const Color(0xFF00E5FF),      
      scaffoldBg: const Color(0xFF121212), // Dark grey
      bgPrimary: const Color(0xFF121212), // Dark grey
      textMain: const Color(0xFFFFFFFF).withValues(alpha: 0.87), // 87% Opacity White
      textMuted: const Color(0xFFFFFFFF).withValues(alpha: 0.60), // 60% Opacity White
      gradStart: const Color(0xFF00E5FF), // Electric Cyan
      gradEnd: const Color(0xFF1DE9B6), // Teal/Mint
      primaryAccent: const Color(0xFF00E5FF), // Electric Cyan
      cardColor: const Color(0xFF1E1E1E), // Lighter grey for Cards/Divisions
      softBg: const Color(0xFFFFFFFF).withValues(alpha: 0.10), // White at 10% opacity for subtle dividers/backgrounds
      navBarBg: const Color(0xFF1E1E1E), // Match cards for NavBar
      navIndicatorBg: const Color(0xFF00E5FF).withValues(alpha: 0.2), // Faint cyan for Nav indicator
      success: const Color(0xFF10B981),
      warning: const Color(0xFFF97316),
      info: const Color(0xFF8B5CF6),
    );
  }

  factory ThemeConfig.blue() {
    return ThemeConfig(
      brightness: Brightness.light,
      seedColor: Colors.blue,
      scaffoldBg: const Color(0xFFF5F8FF),
      bgPrimary: const Color(0xFFEFF6FF), // blue 50
      textMain: const Color(0xFF1E3A8A), // blue 900
      textMuted: Colors.blueGrey.shade600,
      gradStart: const Color(0xFF3B82F6), // blue 500
      gradEnd: const Color(0xFF1E3A8A), // blue 900
      primaryAccent: const Color(0xFF2563EB), // blue 600
      cardColor: Colors.white,
      softBg: Colors.blue.shade50,
      navBarBg: Colors.white,
      navIndicatorBg: const Color(0xFF2563EB),
      success: const Color(0xFF10B981),
      warning: const Color(0xFFF97316),
      info: const Color(0xFF8B5CF6),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  late Box<int> _box;
  AppThemeMode _mode = AppThemeMode.light;
  bool _isInit = false;

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<int>('theme_settings_v1');
    final savedMode = _box.get('themeMode', defaultValue: 0);
    _mode = AppThemeMode.values[savedMode ?? 0];
    _isInit = true;
    notifyListeners();
  }

  bool get isInit => _isInit;
  AppThemeMode get mode => _mode;

  ThemeConfig get config {
    switch (_mode) {
      case AppThemeMode.light:
        return ThemeConfig.light();
      case AppThemeMode.dark:
        return ThemeConfig.dark();
      case AppThemeMode.blue:
        return ThemeConfig.blue();
    }
  }

  void setTheme(AppThemeMode newMode) {
    if (_mode != newMode && _isInit) {
      _mode = newMode;
      _box.put('themeMode', newMode.index);
      notifyListeners();
    }
  }
}
