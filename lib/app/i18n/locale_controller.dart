import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeControllerProvider = StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController();
});

class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null);

  static const supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  void setLocale(Locale locale) {
    if (supportedLocales.contains(locale)) {
      state = locale;
    }
  }

  void clearLocale() {
    state = null;
  }

  bool get isRtl => state?.languageCode == 'ar';
}
