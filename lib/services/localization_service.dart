import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  final Locale locale;

  LocalizationService({required this.locale});

  static LocalizationService? of(BuildContext context) {
    return Localizations.of<LocalizationService>(context, LocalizationService);
  }

  late Map<String, String> _localizedStrings;

  Future<void> load() async {
    String jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  String translate(String key, {List<String> params = const []}) {
    String? translatedValue = _localizedStrings[key];
    if (translatedValue == null) {
      return key; // Return the key if translation is missing
    }

    if (params.isNotEmpty) {
      for (int i = 0; i < params.length; i++) {
        translatedValue = translatedValue!.replaceAll('%${i + 1}\$s', params[i]);
      }
    }

    return translatedValue!;
  }

  get currentLanguage => locale.languageCode;
}

class LocalizationDelegate extends LocalizationsDelegate<LocalizationService> {
  const LocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<LocalizationService> load(Locale locale) async {
    LocalizationService service = LocalizationService(locale: locale);
    await service.load();
    return service;
  }

  @override
  bool shouldReload(LocalizationDelegate old) {
    return false;
  }
}