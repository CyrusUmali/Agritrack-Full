// lib/services/language_service.dart
import 'package:flutter/material.dart';

class LanguageService {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // English
      'language': 'Language',
      'save': 'Save',
    },
    'fil': {
      // Filipino
      'language': 'Wika',
      'save': 'I-save',
    },
  };

  static String getTranslation(String key, String languageCode) {
    return _translations[languageCode]?[key] ?? _translations['en']![key]!;
  }

  static const supportedLocales = [
    Locale('en'), // English
    Locale('fil'), // Filipino
  ];
}
