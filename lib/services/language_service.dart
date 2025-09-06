// lib/services/language_service.dart
import 'package:flutter/material.dart';





class LanguageService {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'language': 'Language',
      'save': 'Save',
      'welcome': 'Welcome',
      'Change Password': 'Change Password',
      'Current Password': 'Current Password',
      'New Password': 'New Password',
      'Confirm New Password': 'Confirm New Password',
      'MTG-text': 'Migrate to Google authentication for easier sign-in',
      'Disconnect Google': 'Disconnect Google',
      'Migrate to Google': 'Migrate to Google',
      'Settings': 'Settings',

      
    },
    'fil': {
      'language': 'Wika', 
      'save': 'I-save',
      'welcome': 'Maligayang pagdating',
      'Change Password': 'Palitan ang Password',
      'Current Password': 'Kasalukuyang Password',
      'New Password': 'Bagong Password',
      'Confirm New Password': 'Kumpirmahin ang Bagong Password',
      'MTG-text': 'Mag-migrate sa Google authentication para sa mas madaling pag-sign-in',
      'Disconnect Google': 'I-disconnect ang Google',
      'Migrate to Google': 'I-migrate sa Google',
      'Settings': 'Mga Setting',
    },
  };

  static String t(String key, {String languageCode = 'en'}) {
    return _translations[languageCode]?[key] ?? _translations['en']![key] ?? key;
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('fil'),
  ];
} 