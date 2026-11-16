import 'package:flutter/material.dart';

/// Paleta tomada de los prototipos de la Figura 5 de la tesis.
///
/// Criterios para el uso a campo (tesis, "Prototipos de interfaces"):
/// - áreas táctiles de al menos 48 × 48 dp;
/// - contraste de texto de al menos 4,5:1 para el uso a pleno sol.
/// Todos los pares texto/fondo de esta paleta superan 4,5:1.
abstract final class ColoresTrazaLabor {
  static const verdeCampo = Color(0xFF1E4D33); // barras y acción principal
  static const verdeOscuro = Color(0xFF143523);
  static const fondo = Color(0xFFF6F5F0);
  static const superficie = Colors.white;
  static const borde = Color(0xFFD8D4C8);
  static const texto = Color(0xFF1B1B1B);
  static const textoSecundario = Color(0xFF55584F);

  /// Errores y faltantes.
  static const sinConexion = Color(0xFFB3261E);

  /// Hecho, enviado, verificado.
  static const enLinea = Color(0xFF1E4D33);

  /// Guardado en el teléfono, esperando señal.
  static const pendiente = Color(0xFF5B3302);

  /// Franja de estado "Sin señal" (crema) y "Con señal" (verde claro).
  static const franjaSinSenal = Color(0xFFFFF1D6);
  static const franjaConSenal = Color(0xFFE3EFE6);

  /// Borde de las acciones secundarias de advertencia ("No pude terminar").
  static const ambar = Color(0xFF8A5A1C);
}

ThemeData construirTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: ColoresTrazaLabor.verdeCampo,
    primary: ColoresTrazaLabor.verdeCampo,
    surface: ColoresTrazaLabor.superficie,
    error: ColoresTrazaLabor.sinConexion,
  );

  const alturaMinima = Size(48, 54);
  final redondeo = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    // Atkinson Hyperlegible: la letra de los prototipos (assets/fuentes).
    fontFamily: 'Atkinson',
    scaffoldBackgroundColor: ColoresTrazaLabor.fondo,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: ColoresTrazaLabor.verdeCampo,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Atkinson',
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 17, color: ColoresTrazaLabor.texto),
      bodyMedium: TextStyle(fontSize: 15, color: ColoresTrazaLabor.texto),
      labelLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: alturaMinima,
        backgroundColor: ColoresTrazaLabor.verdeCampo,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFDAD7CE),
        disabledForegroundColor: const Color(0xFF6B6B66),
        textStyle: const TextStyle(
          fontFamily: 'Atkinson',
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        shape: redondeo,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: alturaMinima,
        foregroundColor: ColoresTrazaLabor.verdeCampo,
        backgroundColor: Colors.white,
        side: const BorderSide(color: ColoresTrazaLabor.verdeCampo, width: 1.6),
        textStyle: const TextStyle(
          fontFamily: 'Atkinson',
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        shape: redondeo,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColoresTrazaLabor.verdeCampo,
        textStyle: const TextStyle(
          fontFamily: 'Atkinson',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ColoresTrazaLabor.verdeCampo,
      foregroundColor: Colors.white,
      extendedTextStyle: TextStyle(
        fontFamily: 'Atkinson',
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ColoresTrazaLabor.borde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFB9B5A8), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: ColoresTrazaLabor.verdeCampo,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: ColoresTrazaLabor.superficie,
    ),
    cardTheme: CardThemeData(
      color: ColoresTrazaLabor.superficie,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ColoresTrazaLabor.borde),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: Color(0xFF8C8A80), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    dividerTheme: const DividerThemeData(color: ColoresTrazaLabor.borde),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: ColoresTrazaLabor.verdeOscuro,
      contentTextStyle: TextStyle(
        fontFamily: 'Atkinson',
        fontSize: 16,
        color: Colors.white,
      ),
    ),
  );
}
