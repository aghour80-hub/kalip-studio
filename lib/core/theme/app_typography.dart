import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle displayLarge({bool isKhmer = false, Color color = AppColors.textPrimary}) {
    if (isKhmer) {
      return GoogleFonts.kantumruyPro(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );
    }
    return GoogleFonts.cormorantGaramond(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: color,
      height: 1.15,
    );
  }

  static TextStyle displayMedium({bool isKhmer = false, Color color = AppColors.textPrimary}) {
    if (isKhmer) {
      return GoogleFonts.kantumruyPro(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );
    }
    return GoogleFonts.cormorantGaramond(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: color,
      height: 1.2,
    );
  }

  static TextStyle headline({bool isKhmer = false, Color color = AppColors.textPrimary}) {
    if (isKhmer) {
      return GoogleFonts.kantumruyPro(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.35,
      );
    }
    return GoogleFonts.cormorantGaramond(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: color,
      height: 1.25,
    );
  }

  static TextStyle titleMedium({bool isKhmer = false, Color color = AppColors.textPrimary}) {
    if (isKhmer) {
      return GoogleFonts.kantumruyPro(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );
    }
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: color,
    );
  }

  static TextStyle titleSmall({bool isKhmer = false, Color color = AppColors.textSecondary}) {
    if (isKhmer) {
      return GoogleFonts.kantumruyPro(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );
    }
    return GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: color,
    );
  }

  static TextStyle bodyLarge({bool isKhmer = false, Color color = AppColors.textPrimary}) {
    if (isKhmer) {
      return GoogleFonts.kantumruyPro(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.6,
      );
    }
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  static TextStyle bodyMedium({bool isKhmer = false, Color color = AppColors.textPrimary}) {
    if (isKhmer) {
      return GoogleFonts.kantumruyPro(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );
    }
    return GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.45,
    );
  }

  static TextStyle bodySmall({bool isKhmer = false, Color color = AppColors.textSecondary}) {
    if (isKhmer) {
      return GoogleFonts.kantumruyPro(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color,
      );
    }
    return GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle labelLarge({bool isKhmer = false, Color color = AppColors.textPrimary}) {
    if (isKhmer) {
      return GoogleFonts.kantumruyPro(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      );
    }
    return GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: color,
    );
  }

  static TextStyle priceTag({Color color = AppColors.primaryBlack, double fontSize = 16}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: color,
    );
  }
}
