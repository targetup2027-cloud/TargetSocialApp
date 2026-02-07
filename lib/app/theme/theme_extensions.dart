import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  Color get primaryColor => colorScheme.primary;
  Color get onSurface => colorScheme.onSurface;
  Color get onSurfaceVariant => colorScheme.onSurfaceVariant;
  Color get surface => colorScheme.surface;
  Color get scaffoldBg => theme.scaffoldBackgroundColor;
  
  Color get cardColor => isDarkMode 
      ? const Color(0xFF121212) 
      : const Color(0xFFFFFFFF);
  
  Color get dividerColor => isDarkMode 
      ? Colors.white.withValues(alpha: 0.08) 
      : Colors.black.withValues(alpha: 0.08);
  
  Color get hintColor => isDarkMode 
      ? Colors.white.withValues(alpha: 0.5) 
      : Colors.black.withValues(alpha: 0.5);
  
  Color get iconColor => isDarkMode 
      ? Colors.white 
      : Colors.black87;
  
  Color get subtleIconColor => isDarkMode 
      ? Colors.white.withValues(alpha: 0.7) 
      : Colors.black.withValues(alpha: 0.6);
}
