import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';
import 'package:cimso_golf_booking/providers/language_provider.dart';
import 'package:cimso_golf_booking/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get translations
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer2<ThemeProvider, LanguageProvider>(
          builder: (context, themeProvider, languageProvider, _) {
            return ListView(
              children: [
                const SizedBox(height: 16),

                // Appearance section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Appearance',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Dark mode toggle
                SwitchListTile(
                  title: Text(localizations.translate('darkMode')),
                  subtitle: Text(
                      themeProvider.isDarkMode
                          ? 'Using dark theme throughout the app'
                          : 'Using light theme throughout the app'
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) {
                    themeProvider.toggleTheme();
                  },
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                ),

                const Divider(),

                // Language section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    localizations.translate('language'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Language toggle
                SwitchListTile(
                  title: Text(
                    localizations.translate('thaiLanguage'),
                    style: TextStyle(
                      fontWeight: languageProvider.isThai ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                      localizations.translate('useThaiLanguage')
                  ),
                  value: languageProvider.isThai,
                  onChanged: (_) {
                    languageProvider.toggleLanguage();
                  },
                  secondary: const Icon(Icons.language),
                ),

                // Language selection alternatives (radio buttons approach)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Select Language:',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      RadioListTile<String>(
                        title: const Text('English'),
                        value: 'en',
                        groupValue: languageProvider.locale.languageCode,
                        onChanged: (value) {
                          if (value != null) {
                            languageProvider.setLanguage(value, 'US');
                          }
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('ภาษาไทย'),
                        value: 'th',
                        groupValue: languageProvider.locale.languageCode,
                        onChanged: (value) {
                          if (value != null) {
                            languageProvider.setLanguage(value, 'TH');
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Add more settings sections here as needed
              ],
            );
          }
      ),
    );
  }
}