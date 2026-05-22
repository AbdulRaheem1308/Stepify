import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('lightTheme has correct brightness and primary color', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.primaryColor, AppTheme.primaryGreen);
      expect(theme.scaffoldBackgroundColor, AppTheme.neutral50);
      expect(theme.colorScheme.primary, AppTheme.primaryGreen);
    });

    test('darkTheme has correct brightness and primary color', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.primaryColor, AppTheme.primaryGreen);
      expect(theme.scaffoldBackgroundColor, AppTheme.neutral900);
      expect(theme.colorScheme.surface, AppTheme.neutral800);
    });

    test('colors are defined correctly', () {
      expect(AppTheme.primaryGreen.value, 0xFF047857);
      expect(AppTheme.secondaryBlue.value, 0xFF0369A1);
      expect(AppTheme.error.value, 0xFFEF4444);
    });
    
    test('gradients are defined', () {
      expect(AppTheme.primaryGradient.colors.length, 2);
      expect(AppTheme.energyGradient.colors.length, 2);
      expect(AppTheme.rewardGradient.colors.length, 2);
    });
  });
}
