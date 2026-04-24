import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal() {
    _loadTheme();
  }

  ThemeModeType _themeMode = ThemeModeType.system;

  ThemeModeType get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeModeType.dark) return true;
    if (_themeMode == ThemeModeType.light) return false;
    return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_mode');
    if (saved != null) {
      _themeMode = ThemeModeType.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => ThemeModeType.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeModeType mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    notifyListeners();
  }

  // Couleurs dynamiques
  Color get background => isDarkMode ? _darkBackground : _lightBackground;
  Color get surface => isDarkMode ? _darkSurface : _lightSurface;
  Color get surfaceLight => isDarkMode ? _darkSurfaceLight : _lightSurfaceLight;
  Color get textPrimary => isDarkMode ? _darkTextPrimary : _lightTextPrimary;
  Color get textSecondary =>
      isDarkMode ? _darkTextSecondary : _lightTextSecondary;
  Color get textMuted => isDarkMode ? _darkTextMuted : _lightTextMuted;

  // Couleurs fixes
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color primaryGreenLight = Color(0xFF2E7D32);
  static const Color accentSecondary = Color(0xFFFF6B6B);
  static const Color correct = Color(0xFF00D4AA);
  static const Color incorrect = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFD93D);

  // Couleurs sombres
  static const Color _darkBackground = Color(0xFF0A0F0A);
  static const Color _darkSurface = Color(0xFF121912);
  static const Color _darkSurfaceLight = Color(0xFF1A231A);
  static const Color _darkTextPrimary = Color(0xFFF5F5F5);
  static const Color _darkTextSecondary = Color(0xFFB0B0B0);
  static const Color _darkTextMuted = Color(0xFF707070);

  // Couleurs claires
  static const Color _lightBackground = Color(0xFFF5F5F5);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceLight = Color(0xFFE8E8E8);
  static const Color _lightTextPrimary = Color(0xFF1A1A1A);
  static const Color _lightTextSecondary = Color(0xFF666666);
  static const Color _lightTextMuted = Color(0xFF999999);

  ThemeData get themeData {
    final isDark = isDarkMode;
    final bg = background;
    final surf = surface;
    final txtPrim = textPrimary;
    final txtSec = textSecondary;
    final txtMut = textMuted;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      primaryColor: primaryGreen,
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryGreen,
        secondary: accentSecondary,
        surface: surf,
        background: bg,
        error: incorrect,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: txtPrim,
        onBackground: txtPrim,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: txtPrim,
          letterSpacing: -1.5,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: txtPrim,
          letterSpacing: -1,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: txtPrim,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: txtPrim,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: txtPrim,
          letterSpacing: -0.3,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: txtPrim,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: txtSec,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: txtMut,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: txtPrim,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: txtSec,
          letterSpacing: 0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: txtPrim,
          side: BorderSide(color: surfaceLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: txtPrim,
        ),
        iconTheme: IconThemeData(color: txtPrim),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surf,
        selectedItemColor: primaryGreen,
        unselectedItemColor: txtMut,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
