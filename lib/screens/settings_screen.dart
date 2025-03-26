import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cimso_golf_booking/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return ListView(
              children: [
                const SizedBox(height: 16),

                // Theme settings section
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
                  title: const Text('Dark Mode'),
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

                // Add more settings sections here as needed
              ],
            );
          }
      ),
    );
  }
}