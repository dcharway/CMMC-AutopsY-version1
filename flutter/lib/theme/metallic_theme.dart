import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Metallic theme — gold accents on dark canvas, per the cyberAutopsy
/// Figma. All semantic colors and shared decorations live here so screens
/// only reference [MT].
class MT {
  // Brand gold
  static const goldBase = Color(0xFFC9A961);
  static const goldLight = Color(0xFFE4C574);
  static const goldDark = Color(0xFFB08D57);

  static const goldGradient = LinearGradient(
    colors: [goldBase, goldLight, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Surfaces
  static const ink = Color(0xFF0F0F0F); // app canvas
  static const inkSoft = Color(0xFF151515);
  static const surface = Color(0xFF1B1B1E);
  static const surfaceHigh = Color(0xFF24242A);
  static const stroke = Color(0xFF2C2C32);
  static const strokeSoft = Color(0xFF3A3A42);

  // Text
  static const textHigh = Color(0xFFF6F6F8);
  static const textMid = Color(0xFFB7B7BD);
  static const textLow = Color(0xFF7C7C84);

  // Status
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);
  static const info = Color(0xFF60A5FA);

  /// Subtle gold-edged border used on cards and tiles.
  static Border goldEdge({double opacity = 0.18}) =>
      Border.all(color: goldBase.withOpacity(opacity));

  static BoxDecoration card({Color? color, Border? border}) => BoxDecoration(
        color: color ?? surface,
        border: border ?? Border.all(color: stroke),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      );

  static BoxDecoration glassCard() => BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x22FFFFFF), Color(0x0EFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: goldBase.withOpacity(0.22)),
        borderRadius: BorderRadius.circular(16),
      );

  static ThemeData themeData() {
    final base = TextTheme(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w800),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w800),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(),
      bodyMedium: GoogleFonts.inter(),
      bodySmall: GoogleFonts.inter(),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w600),
    ).apply(bodyColor: textHigh, displayColor: textHigh);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ink,
      textTheme: base,
      primaryTextTheme: base,
      colorScheme: ColorScheme.fromSeed(
        seedColor: goldBase,
        brightness: Brightness.dark,
        surface: surface,
        onSurface: textHigh,
        primary: goldBase,
        onPrimary: ink,
        secondary: goldLight,
        onSecondary: ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ink,
        foregroundColor: textHigh,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700, fontSize: 18, color: textHigh),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: stroke),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      dividerColor: stroke,
      iconTheme: const IconThemeData(color: textHigh),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: surfaceHigh,
        labelStyle: GoogleFonts.inter(color: textMid, fontSize: 12),
        hintStyle: GoogleFonts.inter(color: textLow, fontSize: 12),
        helperStyle: GoogleFonts.inter(color: textLow, fontSize: 11),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: stroke)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: stroke)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: goldBase, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: goldBase,
          foregroundColor: ink,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldLight,
          side: const BorderSide(color: strokeSoft),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldLight,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceHigh,
        labelStyle: GoogleFonts.inter(fontSize: 11, color: textHigh),
        side: const BorderSide(color: stroke),
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: const StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: inkSoft,
        indicatorColor: goldBase.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
            GoogleFonts.inter(
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: states.contains(WidgetState.selected)
                    ? goldLight
                    : textMid,
                fontSize: 11)),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? goldLight : textMid,
            size: 22)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: goldBase,
        linearTrackColor: stroke,
        circularTrackColor: stroke,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: inkSoft,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: inkSoft,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: inkSoft,
        elevation: 8,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: TextStyle(color: textHigh),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? goldBase : stroke),
        thumbColor:
            const WidgetStatePropertyAll(Color(0xFFE7E2D6)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? goldBase : Colors.transparent),
        side: const BorderSide(color: strokeSoft),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
