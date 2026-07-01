import 'package:flutter/material.dart';

/// Colores por rol del sistema
class RolColors {
  // ── Coordinador de campaña (Verde) ──────────────────────────
  static const Color campaniaPrimary   = Color(0xFF1B5E20);
  static const Color campaniaSecondary = Color(0xFF43A047);
  static const List<Color> campaniaGradient = [
    Color(0xFF1B5E20),
    Color(0xFF2E7D32),
    Color(0xFF43A047),
  ];

  // ── Coordinador de brigada (Azul) ───────────────────────────
  static const Color brigadaPrimary   = Color(0xFF0D47A1);
  static const Color brigadaSecondary = Color(0xFF1976D2);
  static const List<Color> brigadaGradient = [
    Color(0xFF0D47A1),
    Color(0xFF1565C0),
    Color(0xFF1976D2),
  ];

  // ── Vacunador (Teal) ────────────────────────────────────────
  static const Color vacunadorPrimary   = Color(0xFF00695C);
  static const Color vacunadorSecondary = Color(0xFF00897B);
  static const List<Color> vacunadorGradient = [
    Color(0xFF004D40),
    Color(0xFF00695C),
    Color(0xFF00897B),
  ];
}