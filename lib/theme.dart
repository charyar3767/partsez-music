import 'package:flutter/material.dart';

class Renkler {
  static const fon = Color(0xFF080A12);
  static const kart = Color(0xFF151923);
  static const kartGyrmak = Color(0xFF10141E);
  static const esasy = Color(0xFF7C8FFF);
  static const goshmaca = Color(0xFFB36EFF);
  static const tekstSoluk = Color(0xFF9BA3B4);
  static const tekst = Color(0xFFF7F8FC);

  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [esasy, goshmaca],
  );

  static const LinearGradient kartGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [kart, kartGyrmak],
  );
}

ThemeData partsezTema() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Renkler.fon,
    canvasColor: Renkler.fon,
    colorScheme: const ColorScheme.dark(
      primary: Renkler.esasy,
      secondary: Renkler.goshmaca,
      surface: Renkler.kart,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.w800, color: Renkler.tekst),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: Renkler.tekst),
      bodyMedium: TextStyle(color: Renkler.tekst),
      bodySmall: TextStyle(color: Renkler.tekstSoluk),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Renkler.fon,
      foregroundColor: Renkler.tekst,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Renkler.esasy,
      thumbColor: Renkler.tekst,
      inactiveTrackColor: Color(0x33FFFFFF),
      trackHeight: 3,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
    ),
  );
}
