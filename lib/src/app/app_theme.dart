import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandPalette {
  final Color primarySeed;
  final Color secondarySeed;
  final Color tertiarySeed;

  const BrandPalette({
    required this.primarySeed,
    required this.secondarySeed,
    required this.tertiarySeed,
  });

  /// Evergreen (recomendado)
  static const evergreen = BrandPalette(
    primarySeed: Color(0xFF2E8B57),
    secondarySeed: Color(0xFF4ECDC4),
    tertiarySeed: Color(0xFF3A7CA5),
  );

  static const matcha = BrandPalette(
    primarySeed: Color(0xFF27AE60),
    secondarySeed: Color(0xFFE9C46A),
    tertiarySeed: Color(0xFF2D9CDB),
  );

  static const deepTeal = BrandPalette(
    primarySeed: Color(0xFF00897B),
    secondarySeed: Color(0xFFFFB300),
    tertiarySeed: Color(0xFF5E35B1),
  );

  static const forestNight = BrandPalette(
    primarySeed: Color(0xFF1B5E20),
    secondarySeed: Color(0xFF80CBC4),
    tertiarySeed: Color(0xFFB39DDB),
  );
}

class AppTheme {
  final BrandPalette palette;
  final bool highContrast;

  const AppTheme({required this.palette, this.highContrast = false});

  ThemeData light() {
    var scheme = ColorScheme.fromSeed(
      seedColor: palette.primarySeed,
      brightness: Brightness.light,
    );

    // Ajustes finos: secundarios/terciarios y neutrales legibles
    scheme = scheme.copyWith(
      secondary: palette.secondarySeed,
      tertiary: palette.tertiarySeed,
      onPrimary: Colors.white,
      onSecondary: _bestOnColor(palette.secondarySeed, isDarkBg: false),
      onTertiary: _bestOnColor(palette.tertiarySeed, isDarkBg: false),
      onSurface: const Color(0xFF121417),
      // onBackground: const Color(0xFF121417),
      // outlineVariant: scheme.outlineVariant.withOpacity(0.6),
      outlineVariant: scheme.outlineVariant.withValues(alpha: 0.6),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      // Cards y contenedores suaves
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // Inputs con fondo sutil
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: _outline(scheme),
        enabledBorder: _outline(scheme),
        focusedBorder: _outline(scheme, focused: true),
        errorBorder: _outline(scheme, error: true),
        focusedErrorBorder: _outline(scheme, focused: true, error: true),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      // Botones
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
          backgroundColor: WidgetStatePropertyAll(scheme.primary),
          foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
          side: WidgetStatePropertyAll(BorderSide(color: scheme.outline)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          foregroundColor: WidgetStatePropertyAll(scheme.onSurface),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(scheme.primary),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.secondaryContainer,
        labelStyle: TextStyle(color: scheme.onSurface),
        selectedShadowColor: Colors.transparent,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        tileColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 0,
      ),
      scaffoldBackgroundColor: scheme.surface,
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  ThemeData dark() {
    var scheme = ColorScheme.fromSeed(
      seedColor: palette.primarySeed,
      brightness: Brightness.dark,
    );

    scheme = scheme.copyWith(
      secondary: palette.secondarySeed,
      tertiary: palette.tertiarySeed,
      onPrimary: Colors.white,
      onSecondary: _bestOnColor(palette.secondarySeed, isDarkBg: true),
      onTertiary: _bestOnColor(palette.tertiarySeed, isDarkBg: true),
      onSurface: Colors.white,
      // onBackground: Colors.white,
      outlineVariant: scheme.outlineVariant.withValues(alpha: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHigh,
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: _outline(scheme),
        enabledBorder: _outline(scheme),
        focusedBorder: _outline(scheme, focused: true),
        errorBorder: _outline(scheme, error: true),
        focusedErrorBorder: _outline(scheme, focused: true, error: true),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
          backgroundColor: WidgetStatePropertyAll(scheme.primary),
          foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
          side: WidgetStatePropertyAll(BorderSide(color: scheme.outline)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          foregroundColor: WidgetStatePropertyAll(scheme.onSurface),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(scheme.primary),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.secondaryContainer,
        labelStyle: TextStyle(color: scheme.onSurface),
        selectedShadowColor: Colors.transparent,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        tileColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 0,
      ),
      scaffoldBackgroundColor: scheme.surface,
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Helpers
  static OutlineInputBorder _outline(
    ColorScheme s, {
    bool focused = false,
    bool error = false,
  }) {
    final c = error ? s.error : (focused ? s.primary : s.outlineVariant);
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: focused ? 2 : 1),
    );
  }

  static Color _bestOnColor(Color bg, {required bool isDarkBg}) {
    // Heurística rápida: si el color es oscuro, texto blanco; si es claro, texto negro
    final luminance = bg.computeLuminance();
    if (isDarkBg) {
      // en dark, preferir blanco salvo que el color sea muy claro
      return (luminance > 0.6) ? Colors.black : Colors.white;
    }
    // en light, preferir negro salvo que el color sea muy oscuro
    return (luminance < 0.32) ? Colors.white : Colors.black;
  }
}
