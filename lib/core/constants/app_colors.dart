import 'dart:ui';

class AppColors {
  // Primary neon colors
  static const Color neonPink = Color(0xFFFF00FF); // Fuchsia
  static const Color neonTurquoise = Color(0xFF40E0D0); // Turquoise
  static const Color neonPurple = Color(0xFF9D00FF);
  static const Color neonBlue = Color(0xFF00FFFF);
  static const Color neonGreen = Color(0xFF00FF00);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF2A2A2A);
  static const Color darkBorder = Color(0xFF3A3A3A);
  
  // Text colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB0B0B0);
  static const Color disabledText = Color(0xFF606060);
  
  // Accent colors
  static const Color accent1 = Color(0xFFFF4081); // Pink accent
  static const Color accent2 = Color(0xFF00BCD4); // Cyan accent
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    neonPink,
    neonTurquoise,
  ];
  
  static const List<Color> backgroundGradient = [
    darkBackground,
    Color(0xFF1A0A1A),
  ];
  
  static const List<Color> cardGradient = [
    darkSurface,
    darkCard,
  ];

  // Authentication specific colors
  static const Color authCardBackground = Color(0xFF1E1E1E);
  static const Color inputBorder = Color(0xFF404040);
  static const Color inputFocusedBorder = neonTurquoise;
  static const Color inputErrorBorder = error;
}