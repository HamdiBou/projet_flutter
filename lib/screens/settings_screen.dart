import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../services/theme_service.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  String? _selectedLanguage;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _soundEnabled = prefs.getBool('sound') ?? true;
    });
  }

  Future<void> _saveSettings(bool notificationsEnabled, bool soundEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', notificationsEnabled);
    await prefs.setBool('sound', soundEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final languageService = Provider.of<LanguageService>(context, listen: false);
    _selectedLanguage = languageService.currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.of(context)!.translate('settings')),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(LocalizationService.of(context)!.translate('notifications')),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings(_notificationsEnabled, _soundEnabled);
                // TODO: Implement notification enabling/disabling
              },
            ),
          ),
          ListTile(
            title: Text(LocalizationService.of(context)!.translate('sound')),
            trailing: Switch(
              value: _soundEnabled,
              onChanged: (bool value) {
                setState(() {
                  _soundEnabled = value;
                });
                _saveSettings(_notificationsEnabled, _soundEnabled);
                // TODO: Implement sound enabling/disabling
              },
            ),
          ),
          ListTile(
            title: Text(LocalizationService.of(context)!.translate('theme')),
            trailing: Switch(
              value: themeService.isDarkMode,
              onChanged: (bool value) {
                themeService.toggleTheme();
              },
            ),
          ),
          ListTile(
            title: Text(LocalizationService.of(context)!.translate('language')),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              hint: Text(LocalizationService.of(context)!.translate('language')),
              items: const [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'fr',
                  child: Text('French'),
                ),
                DropdownMenuItem(
                  value: 'ar',
                  child: Text('Arabic'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value;
                });
                languageService.setLocale(Locale(_selectedLanguage!, _selectedLanguage == 'en' ? 'US' : _selectedLanguage == 'fr' ? 'FR' : 'SA'));
              },
            ),
          ),
        ],
      ),
    );
  }
}