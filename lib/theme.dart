import 'package:flutter/material.dart';

class Renkler {
  static const Color fon = Color(0xFF0B0B1F);
  static const Color kart = Color(0xFF1A1A3A);
  static const Color esasy = Color(0xFFFF8A3D);
  static const Color goshmaca = Color(0xFFFF3D81);
  static const Color tekstSoluk = Color(0xFFB0B0C8);

  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [esasy, goshmaca],
  );
}
