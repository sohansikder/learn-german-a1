import 'package:flutter/material.dart';

/// Semantic color tokens for the DeutschBlitz design system.
class AppColors {
  AppColors._();

  // ── Primary Palette ──
  static const Color primaryIndigo = Color(0xFF6C63FF);
  static const Color primaryIndigoLight = Color(0xFF9D97FF);
  static const Color primaryIndigoDark = Color(0xFF4A42DB);

  // ── Secondary Palette ──
  static const Color secondaryTeal = Color(0xFF00BFA6);
  static const Color secondaryTealLight = Color(0xFF5DF2D6);
  static const Color secondaryTealDark = Color(0xFF008E76);

  // ── Accent / Gamification ──
  static const Color xpGold = Color(0xFFFFD54F);
  static const Color streakOrange = Color(0xFFFF7043);
  static const Color streakFlame = Color(0xFFFF5722);
  static const Color successGreen = Color(0xFF66BB6A);
  static const Color errorRed = Color(0xFFEF5350);

  // ── Article Colors (Der / Die / Das) ──
  static const Color derBlue = Color(0xFF42A5F5);
  static const Color diePink = Color(0xFFEC407A);
  static const Color dasGreen = Color(0xFF66BB6A);

  // ── Dark Surface Palette ──
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceDarkElevated = Color(0xFF1E1E2E);
  static const Color surfaceDarkCard = Color(0xFF252540);
  static const Color surfaceDarkDialog = Color(0xFF2D2D4A);

  // ── Light Surface Palette ──
  static const Color surfaceLight = Color(0xFFF8F8FC);
  static const Color surfaceLightCard = Color(0xFFFFFFFF);
  static const Color surfaceLightElevated = Color(0xFFF0F0F8);

  // ── Text Colors ──
  static const Color textDarkPrimary = Color(0xFFE8E8F0);
  static const Color textDarkSecondary = Color(0xFFA0A0B8);
  static const Color textLightPrimary = Color(0xFF1A1A2E);
  static const Color textLightSecondary = Color(0xFF6B6B80);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryIndigo, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [streakOrange, streakFlame],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [secondaryTeal, Color(0xFF00E5CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardDarkGradient = LinearGradient(
    colors: [surfaceDarkCard, Color(0xFF1E1E38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
