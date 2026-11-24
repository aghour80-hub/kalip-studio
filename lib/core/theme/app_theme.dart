import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme({bool isKhmer = false}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvasLinen,
      primaryColor: AppColors.primaryBlack,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlack,
        onPrimary: AppColors.pureWhite,
        secondary: AppColors.luxuryBeige,
        onSecondary: AppColors.primaryBlack,
        surface: AppColors.pureWhite,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.pureWhite,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvasLinen,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: (isKhmer
                ? GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.w700)
                : GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 1.2))
            .copyWith(color: AppColors.primaryBlack),
        iconTheme: const IconThemeData(color: AppColors.primaryBlack, size: 22),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.pureWhite,
        selectedItemColor: AppColors.primaryBlack,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: AppColors.borderLight, width: 0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlack,
          foregroundColor: AppColors.pureWhite,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          textStyle: (isKhmer
                  ? GoogleFonts.kantumruyPro(fontSize: 14, fontWeight: FontWeight.w600)
                  : GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlack,
          side: const BorderSide(color: AppColors.primaryBlack, width: 1.2),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          textStyle: (isKhmer
                  ? GoogleFonts.kantumruyPro(fontSize: 14, fontWeight: FontWeight.w600)
                  : GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.primaryBlack, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 0.8,
        space: 24,
      ),
    );
  }
}
