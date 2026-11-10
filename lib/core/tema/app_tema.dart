import 'package:flutter/material.dart';

/// Tema visual do DengueZero.
abstract final class AppTema {
  /// Cor que dá origem a toda a paleta do app.
  static const Color corSemente = Color(0xFF2E7D32);

  /// Tema claro.
  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(seedColor: corSemente);
    return ThemeData(
      colorScheme: esquema,
      scaffoldBackgroundColor: esquema.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: esquema.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: esquema.outlineVariant),
        ),
      ),
    );
  }
}
