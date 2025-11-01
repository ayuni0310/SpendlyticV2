import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../services/auth_service.dart';
import '../../providers/theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool isNotificationOn = true;
  String selectedLanguage = 'English';
  final Map<String, Locale> localeMap = {
    'English': const Locale('en'),
    'Malay': const Locale('ms'),
    'Chinese': const Locale('zh'),
  };

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    setState(() {
      isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      isNotificationOn = prefs.getBool('notifications_enabled') ?? true;
      selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });

    themeNotifier.toggleTheme(isDarkMode);
    context.setLocale(localeMap[selectedLanguage]!);
  }

  Future<void> saveDarkModePref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
  }

  Future<void> saveNotificationPref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  Future<void> saveLanguagePref(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
  }

  Future<void> showLogoutConfirmation() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacementNamed(context, '/get_started');
                  }
                },
                child: const Text('Log Out'),
              ),
            ],
          ),
    );
  }

  Widget settingsContainer(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: isDarkMode,
          onChanged: (val) {
            setState(() => isDarkMode = val);
            Provider.of<ThemeNotifier>(context, listen: false).toggleTheme(val);
            saveDarkModePref(val);
          },
        ),
        SwitchListTile(
          title: const Text('Notifications'),
          value: isNotificationOn,
          onChanged: (val) {
            setState(() => isNotificationOn = val);
            saveNotificationPref(val);
          },
        ),
        ListTile(
          title: const Text('Language'),
          subtitle: Text(selectedLanguage),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            final selected = await showDialog<String>(
              context: context,
              builder:
                  (context) => SimpleDialog(
                    title: const Text('Select Language'),
                    children:
                        localeMap.keys
                            .map(
                              (lang) => SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, lang),
                                child: Text(lang),
                              ),
                            )
                            .toList(),
                  ),
            );
            if (selected != null && selected != selectedLanguage) {
              setState(() => selectedLanguage = selected);
              context.setLocale(localeMap[selected]!);
              saveLanguagePref(selected);
            }
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Log Out'),
          onTap: showLogoutConfirmation,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SETTINGS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildSettingsContainer(context, colorScheme),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// Container with all the settings options
  Widget buildToggleRow({
    required IconData icon,
    required Color color,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget buildSettingsContainer(BuildContext context, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          buildToggleRow(
            icon: Icons.nightlight_round,
            color: colorScheme.primary,
            label: 'Dark Mode'.tr(),
            value: isDarkMode,
            onChanged: (value) {
              setState(() => isDarkMode = value);
              Provider.of<ThemeNotifier>(
                context,
                listen: false,
              ).toggleTheme(value);
              saveDarkModePref(value);
            },
          ),
          const SizedBox(height: 10),
          buildToggleRow(
            icon: Icons.notifications,
            color: colorScheme.primary,
            label: 'Notifications'.tr(),
            value: isNotificationOn,
            onChanged: (value) {
              setState(() => isNotificationOn = value);
              saveNotificationPref(value);
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.language, color: colorScheme.primary),
            title: Text(
              'Language'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              underline: Container(),
              items:
                  localeMap.keys.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue == null) return;
                setState(() => selectedLanguage = newValue);
                context.setLocale(localeMap[newValue]!);
                saveLanguagePref(newValue);
              },
            ),
          ),
          const SizedBox(height: 10),
          // Removed Change Password & Delete Account (not supported in Huawei)
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Log Out'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: showLogoutConfirmation,
          ),
        ],
      ),
    );
  }
}
