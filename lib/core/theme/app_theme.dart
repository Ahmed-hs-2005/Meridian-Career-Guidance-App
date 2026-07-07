import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors - Modern Navigation Premium
  static const Color primary = Color(0xFF0a1a35); 
  static const Color primaryLight = Color(0xFF0f2847);
  static const Color accent = Color(0xFFd4af37); // Premium Gold
  static const Color accentWarm = Color(0xFFff6b5b); // Coral     
  static const Color accentGreen = Color(0xFF00b4a6); // Teal    
 
  // Surface Colors
  static const Color surface = Color(0xFF0a1a35);
  static const Color surfaceCard = Color(0xFF1f3a52); // Slate
  static const Color surfaceBright = Color(0xFF2d4a63);
 
  // Text Colors
  static const Color textPrimary = Color(0xFFe8eef7); // Light Cream
  static const Color textSecondary = Color(0xFF9db3c8); // Muted Blue
  static const Color textMuted = Color(0xFF6b8299);
 
  // Area Colors
  static const Color webColor = Color(0xFFd4af37);
  static const Color mobileColor = Color(0xFFd4af37);
  static const Color ecomColor = Color(0xFFd4af37);
  static const Color aiColor = Color(0xFFd4af37);
  static const Color saasColor = Color(0xFFd4af37);
 
  // Semantic Colors
  static const Color success = Color(0xFF00b4a6); // Teal
  static const Color warning = Color(0xFFff6b5b); // Coral
  static const Color error = Color(0xFFff6b5b);
 
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0a1a35), Color(0xFF0f2847)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
 
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFd4af37), Color(0xFFb8962e)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
 
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1f3a52), Color(0xFF2d4a63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Meridian Line Color (gold at 20% opacity)
  static const Color meridianLine = Color(0x33d4af37);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentWarm,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.primary,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        // Display Font: Georgia Serif for headings
        displayLarge: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 1.0,
          height: 1.2,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 0.8,
          height: 1.2,
        ),
        headlineLarge: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 0.6,
          height: 1.3,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
          height: 1.3,
        ),
        // Body Font: System Sans for UI text
        titleLarge: const TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        titleMedium: const TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        bodyLarge: const TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: const TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
          height: 1.4,
        ),
        labelLarge: const TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: AppColors.textPrimary,
        ),
        labelMedium: const TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: AppColors.textSecondary,
        ),
        labelSmall: const TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
          color: AppColors.textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.meridianLine, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primary, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primary, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.error, width: 0.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Segoe UI',
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Segoe UI',
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceCard,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.meridianLine,
        thickness: 1,
        space: 24,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceCard,
        selectedColor: AppColors.accent,
        labelStyle: const TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        side: const BorderSide(color: AppColors.meridianLine, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}