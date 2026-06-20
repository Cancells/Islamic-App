import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onThemeChanged;

  const SettingsScreen({
    Key? key,
    required this.storage,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDark = true;
  String _quranFont = 'font-scheherazade';
  String _reciter = 'ar.alafasy';
  String _langCode = 'ar';

  @override
  void initState() {
    super.initState();
    _isDark = widget.storage.isDarkMode();
    _quranFont = widget.storage.getString('quran_font', defaultValue: 'font-scheherazade');
    _reciter = widget.storage.getString('default_reciter', defaultValue: 'ar.alafasy');
    _langCode = widget.storage.getString('lang_code', defaultValue: 'ar');
  }

  void _toggleTheme(bool val) async {
    setState(() {
      _isDark = val;
    });
    await widget.storage.setDarkMode(val);
    widget.onThemeChanged();
  }

  void _changeFont(String? val) async {
    if (val != null) {
      setState(() {
        _quranFont = val;
      });
      await widget.storage.setString('quran_font', val);
      widget.onThemeChanged();
    }
  }

  void _changeReciter(String? val) async {
    if (val != null) {
      setState(() {
        _reciter = val;
      });
      await widget.storage.setString('default_reciter', val);
      widget.onThemeChanged();
    }
  }

  void _changeLanguage(String? val) async {
    if (val != null) {
      setState(() {
        _langCode = val;
      });
      await widget.storage.setString('lang_code', val);
      TranslationService.setLanguage(val);
      widget.onThemeChanged(); // Trigger root level layout update
    }
  }

  void _resetApp() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          TranslationService.t('reset_settings') + "?", 
          style: const TextStyle(color: Color(0xFFE5C158), fontWeight: FontWeight.bold)
        ),
        content: Text(TranslationService.t('reset_settings_sub')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationService.t('cancel'), style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await widget.storage.setString('quran_font', 'font-scheherazade');
              await widget.storage.setDarkMode(true);
              await widget.storage.setString('default_reciter', 'ar.alafasy');
              await widget.storage.setString('lang_code', 'ar');
              await widget.storage.setString('quran_bookmarks', '[]');
              await widget.storage.setString('custom_dhikrs', '[]');
              
              TranslationService.setLanguage('ar');
              Navigator.pop(context);
              widget.onThemeChanged();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application reset.')),
              );
            },
            child: Text(TranslationService.t('reset_settings')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          TranslationService.t('settings'), 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: _isDark ? const Color(0xFF0F172A) : const Color(0xFF0F766E),
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section Appearance
          _buildSectionHeader(TranslationService.t('appearance')),
          Card(
            color: theme.cardColor,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(TranslationService.t('dark_mode')),
                  subtitle: Text(TranslationService.t('dark_mode_sub')),
                  activeColor: const Color(0xFFE5C158),
                  value: _isDark,
                  onChanged: _toggleTheme,
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: Text(TranslationService.t('quran_font')),
                  subtitle: Text(TranslationService.t('quran_font_sub')),
                  trailing: DropdownButton<String>(
                    value: _quranFont,
                    underline: const SizedBox(),
                    dropdownColor: theme.cardColor,
                    items: const [
                      DropdownMenuItem(value: 'font-scheherazade', child: Text("Scheherazade")),
                      DropdownMenuItem(value: 'font-amiri', child: Text("Amiri")),
                    ],
                    onChanged: _changeFont,
                  ),
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: Text(TranslationService.t('app_lang')),
                  subtitle: Text(TranslationService.t('app_lang_sub')),
                  trailing: DropdownButton<String>(
                    value: _langCode,
                    underline: const SizedBox(),
                    dropdownColor: theme.cardColor,
                    items: [
                      DropdownMenuItem(value: 'ar', child: Text(TranslationService.t('arabic'))),
                      DropdownMenuItem(value: 'en', child: Text(TranslationService.t('english'))),
                    ],
                    onChanged: _changeLanguage,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Audio
          _buildSectionHeader(TranslationService.t('recitations')),
          Card(
            color: theme.cardColor,
            child: ListTile(
              title: Text(TranslationService.t('qari')),
              subtitle: Text(TranslationService.t('qari_sub')),
              trailing: DropdownButton<String>(
                value: _reciter,
                underline: const SizedBox(),
                dropdownColor: theme.cardColor,
                items: const [
                  DropdownMenuItem(value: 'ar.alafasy', child: Text("Mishary Alafasy")),
                  DropdownMenuItem(value: 'ar.abdulrahmanalsudaish', child: Text("Al-Sudais")),
                  DropdownMenuItem(value: 'ar.maheralmuaiqly', child: Text("Maher Al-Muaiqly")),
                  DropdownMenuItem(value: 'ar.saadghamidi', child: Text("Saad Al-Ghamdi")),
                ],
                onChanged: _changeReciter,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Reset Section
          _buildSectionHeader(TranslationService.t('system_management')),
          Card(
            color: theme.cardColor,
            child: ListTile(
              title: Text(
                TranslationService.t('reset_settings'), 
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)
              ),
              subtitle: Text(TranslationService.t('reset_settings_sub')),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.redAccent),
              onTap: _resetApp,
            ),
          ),
          const SizedBox(height: 40),

          // App info credits
          Center(
            child: Column(
              children: [
                const Icon(Icons.mosque, color: Color(0xFFE5C158), size: 48),
                const SizedBox(height: 12),
                Text(
                  TranslationService.t('app_title').toUpperCase(),
                  style: const TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  "Version 1.0.0 • Premium Build",
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4), fontSize: 11),
                ),
                const SizedBox(height: 8),
                Text(
                  TranslationService.t('bless_journey'),
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, right: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF0F766E),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
