import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/prayer_models.dart';
import 'quran_download_screen.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.storage,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  static const _platform = MethodChannel('com.noor.noor_app/system');

  String _themePreset = 'dark';
  String _quranFont = 'font-scheherazade';
  String _reciter = 'ar.alafasy';
  
  // Add calculation settings
  int _calcMethod = 2;
  int _asrMethod = 0;
  bool _continuousPlay = true;
  bool _hideContinuousBorders = false;
  bool _autoBookmark = true;

  // Add notification triggers
  bool _alertFajr = true;
  bool _alertDhuhr = true;
  bool _alertAsr = true;
  bool _alertMaghrib = true;
  bool _alertIsha = true;

  // Permissions and wake lock
  bool _exactAlarmPermitted = true;
  bool _batteryIgnored = true;
  bool _keepScreenAwake = false;

  // Focus lock
  int _focusLockDuration = 0;
  bool _focusAutoStart = false;
  
  // Pre-azan reminder
  int _preAzanReminder = 0;

  bool _morningAzkarReminder = true;
  bool _eveningAzkarReminder = true;
  bool _todaysVerseReminder = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _themePreset = widget.storage.getString('theme_preset', defaultValue: 'dark');
    _quranFont = widget.storage.getString('quran_font', defaultValue: 'font-scheherazade');
    _reciter = widget.storage.getString('default_reciter', defaultValue: 'ar.alafasy');
    
    _calcMethod = widget.storage.getInt('calc_method', defaultValue: 2);
    _asrMethod = widget.storage.getInt('asr_method', defaultValue: 0);
    _continuousPlay = widget.storage.getBool('setting_continuous_play', defaultValue: true);
    _hideContinuousBorders = widget.storage.getBool('setting_hide_continuous_borders', defaultValue: false);
    _autoBookmark = widget.storage.getBool('setting_auto_bookmark', defaultValue: true);

    _alertFajr = widget.storage.getBool('alert_fajr', defaultValue: true);
    _alertDhuhr = widget.storage.getBool('alert_dhuhr', defaultValue: true);
    _alertAsr = widget.storage.getBool('alert_asr', defaultValue: true);
    _alertMaghrib = widget.storage.getBool('alert_maghrib', defaultValue: true);
    _alertIsha = widget.storage.getBool('alert_isha', defaultValue: true);

    _keepScreenAwake = widget.storage.getBool('keep_screen_awake', defaultValue: false);
    _focusLockDuration = widget.storage.getInt('focus_lock_duration', defaultValue: 0);
    _focusAutoStart = widget.storage.getBool('focus_auto_start', defaultValue: false);
    _preAzanReminder = widget.storage.getInt('pre_azan_reminder_minutes', defaultValue: 0);

    _morningAzkarReminder = widget.storage.getBool('morning_azkar_reminder', defaultValue: true);
    _eveningAzkarReminder = widget.storage.getBool('evening_azkar_reminder', defaultValue: true);
    _todaysVerseReminder = widget.storage.getBool('todays_verse_reminder', defaultValue: true);

    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final alarm = await _platform.invokeMethod<bool>('checkExactAlarmPermission') ?? true;
      // checkBatteryOptimization returns true if optimization is enabled, so we invert it to reflect ignored status
      final batteryOptimized = await _platform.invokeMethod<bool>('checkBatteryOptimization') ?? false;
      setState(() {
        _exactAlarmPermitted = alarm;
        _batteryIgnored = !batteryOptimized; // true means ignored, false means not ignored
      });
    } catch (_) {}
  }

  Future<void> _requestExactAlarm() async {
    try {
      await _platform.invokeMethod('requestExactAlarmPermission');
      Future.delayed(const Duration(seconds: 2), _checkPermissions);
    } catch (_) {}
  }

  Future<void> _requestBatteryOptimization() async {
    try {
      await _platform.invokeMethod('requestDisableBatteryOptimization');
      Future.delayed(const Duration(seconds: 2), _checkPermissions);
    } catch (_) {}
  }

  Future<void> _toggleKeepScreenAwake(bool val) async {
    setState(() {
      _keepScreenAwake = val;
    });
    await widget.storage.setBool('keep_screen_awake', val);
    try {
      await _platform.invokeMethod('setKeepScreenOn', {'enabled': val});
    } catch (_) {}
  }

  Future<void> _changeFocusDuration(int? val) async {
    if (val != null) {
      setState(() {
        _focusLockDuration = val;
        if (val == 0) _focusAutoStart = false;
      });
      await widget.storage.setInt('focus_lock_duration', val);
      if (val == 0) {
        await widget.storage.setBool('focus_auto_start', false);
      }
    }
  }

  Future<void> _toggleFocusAutoStart(bool val) async {
    setState(() {
      _focusAutoStart = val;
    });
    await widget.storage.setBool('focus_auto_start', val);
  }

  Future<void> _changePreAzanReminder(int? minutes) async {
    if (minutes != null) {
      setState(() {
        _preAzanReminder = minutes;
      });
      await widget.storage.setInt('pre_azan_reminder_minutes', minutes);
      try {
        final loc = widget.storage.getLocation();
        final method = widget.storage.getInt('calc_method', defaultValue: 2);
        final school = widget.storage.getInt('asr_method', defaultValue: 0);
        final prayerData = await ApiService.fetchPrayerTimes(
          latitude: loc['latitude'],
          longitude: loc['longitude'],
          method: method,
          school: school,
        );
        await NotificationService().schedulePrayerAlarms(prayerData, widget.storage);
      } catch (_) {}
    }
  }

  Future<void> _toggleDailyReminder(String key, bool val, Function(bool) updateState) async {
    await widget.storage.setBool(key, val);
    setState(() {
      updateState(val);
    });
    try {
      await NotificationService().scheduleDailyReminders(widget.storage);
    } catch (_) {}
  }

  Future<void> _changeThemePreset(String? val) async {
    if (val != null) {
      setState(() {
        _themePreset = val;
      });
      await widget.storage.setString('theme_preset', val);
      widget.onThemeChanged();
    }
  }

  Future<void> _changeFont(String? val) async {
    if (val != null) {
      setState(() {
        _quranFont = val;
      });
      await widget.storage.setString('quran_font', val);
      widget.onThemeChanged();
    }
  }

  Future<void> _changeReciter(String? val) async {
    if (val != null) {
      setState(() {
        _reciter = val;
      });
      await widget.storage.setString('default_reciter', val);
      widget.onThemeChanged();
    }
  }



  Future<void> _rescheduleAlarms() async {
    try {
      final loc = widget.storage.getLocation();
      final method = widget.storage.getInt('calc_method', defaultValue: 2);
      final school = widget.storage.getInt('asr_method', defaultValue: 0);

      final PrayerTimeData data;
      if (loc['source'] == 'default' || loc['latitude'] == 30.0444) {
        data = await ApiService.fetchPrayerTimesByCity(
          city: loc['city'] ?? 'Cairo',
          country: loc['country'] ?? 'Egypt',
          method: method,
          school: school,
        );
      } else {
        data = await ApiService.fetchPrayerTimes(
          latitude: loc['latitude'],
          longitude: loc['longitude'],
          method: method,
          school: school,
        );
      }
      await NotificationService().schedulePrayerAlarms(data, widget.storage);
    } catch (_) {}
  }

  Future<void> _changeCalcMethod(int? val) async {
    if (val != null) {
      setState(() {
        _calcMethod = val;
      });
      await widget.storage.setInt('calc_method', val);
      widget.onThemeChanged();
      await _rescheduleAlarms();
    }
  }

  Future<void> _changeAsrMethod(int? val) async {
    if (val != null) {
      setState(() {
        _asrMethod = val;
      });
      await widget.storage.setInt('asr_method', val);
      widget.onThemeChanged();
      await _rescheduleAlarms();
    }
  }

  Future<void> _toggleContinuousPlay(bool val) async {
    setState(() {
      _continuousPlay = val;
    });
    await widget.storage.setBool('setting_continuous_play', val);
  }

  Future<void> _toggleHideContinuousBorders(bool val) async {
    setState(() {
      _hideContinuousBorders = val;
    });
    await widget.storage.setBool('setting_hide_continuous_borders', val);
  }

  Future<void> _toggleAutoBookmark(bool val) async {
    setState(() {
      _autoBookmark = val;
    });
    await widget.storage.setBool('setting_auto_bookmark', val);
  }

  Future<void> _toggleAlert(String key, bool val, Function(bool) updateState) async {
    updateState(val);
    await widget.storage.setBool(key, val);
    await _rescheduleAlarms();
  }

  Future<void> _resetApp() async {
    unawaited(showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          "${TranslationService.t('reset_settings')}?", 
          style: const TextStyle(color: Color(0xFFE5C158), fontWeight: FontWeight.bold),
          textAlign: TextAlign.start,
        ),
        content: Text(
          TranslationService.t('reset_settings_sub'),
          textAlign: TextAlign.start,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(TranslationService.t('cancel'), style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(dialogContext);

              await widget.storage.setString('theme_preset', 'dark');
              await widget.storage.setString('quran_font', 'font-scheherazade');
              await widget.storage.setString('default_reciter', 'ar.alafasy');
              await widget.storage.setString('lang_code', 'ar');
              await widget.storage.setString('quran_bookmarks', '[]');
              await widget.storage.setString('custom_dhikrs', '[]');
              await widget.storage.setInt('calc_method', 2);
              await widget.storage.setInt('asr_method', 0);
              await widget.storage.setBool('setting_continuous_play', true);
              await widget.storage.setBool('setting_hide_continuous_borders', false);
              await widget.storage.setBool('setting_auto_bookmark', true);
              await widget.storage.setBool('first_time_v2', true); // Reset onboarding too

              await widget.storage.setBool('alert_fajr', true);
              await widget.storage.setBool('alert_dhuhr', true);
              await widget.storage.setBool('alert_asr', true);
              await widget.storage.setBool('alert_maghrib', true);
              await widget.storage.setBool('alert_isha', true);

              await widget.storage.setBool('keep_screen_awake', false);
              await widget.storage.setInt('focus_lock_duration', 0);
              await widget.storage.setBool('focus_auto_start', false);
              
              TranslationService.setLanguage('ar');
              
              setState(() {
                _themePreset = 'dark';
                _quranFont = 'font-scheherazade';
                _reciter = 'ar.alafasy';
                _calcMethod = 2;
                _asrMethod = 0;
                _continuousPlay = true;
                _hideContinuousBorders = false;
                _autoBookmark = true;
                _alertFajr = true;
                _alertDhuhr = true;
                _alertAsr = true;
                _alertMaghrib = true;
                _alertIsha = true;
                _keepScreenAwake = false;
                _focusLockDuration = 0;
                _focusAutoStart = false;
              });
              navigator.pop();
              widget.onThemeChanged();
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text(TranslationService.isArabic ? 'تم إعادة تعيين التطبيق.' : 'Application reset.')),
              );
            },
            child: Text(TranslationService.t('reset_settings')),
          ),
        ],
      ),
    ));
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
        backgroundColor: theme.appBarTheme.backgroundColor,
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
                ListTile(
                  title: Text(TranslationService.t('theme_preset_label')),
                  subtitle: Text(TranslationService.t('theme_preset_sub')),
                  trailing: DropdownButton<String>(
                    value: _themePreset,
                    underline: const SizedBox(),
                    dropdownColor: theme.cardColor,
                    items: [
                      DropdownMenuItem(value: 'light', child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "فاتح" : "Light"))),
                      DropdownMenuItem(value: 'dark', child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "داكن" : "Dark"))),
                      DropdownMenuItem(value: 'black', child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "أسود OLED" : "OLED Black"))),
                      DropdownMenuItem(value: 'dark_monet', child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "داكن متكيف" : "Adaptive Dark"))),
                      DropdownMenuItem(value: 'white_monet', child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "فاتح متكيف" : "Adaptive Light"))),
                    ],
                    onChanged: _changeThemePreset,
                  ),
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: Text(TranslationService.t('quran_font')),
                  subtitle: Text(TranslationService.t('quran_font_sub')),
                  trailing: DropdownButton<String>(
                    value: _quranFont,
                    underline: const SizedBox(),
                    dropdownColor: theme.cardColor,
                    items: [
                      DropdownMenuItem(value: 'font-scheherazade', child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "خط شهرزاد" : "Scheherazade Font"))),
                      DropdownMenuItem(value: 'font-amiri', child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "الخط الأميري" : "Amiri Font"))),
                    ],
                    onChanged: _changeFont,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Language
          _buildSectionHeader(TranslationService.t('app_lang')),
          Card(
            color: theme.cardColor,
            child: ListTile(
              title: Text(TranslationService.t('app_lang')),
              subtitle: Text(TranslationService.t('app_lang_sub')),
              trailing: DropdownButton<String>(
                value: TranslationService.currentLanguage,
                underline: const SizedBox(),
                dropdownColor: theme.cardColor,
                items: [
                  const DropdownMenuItem(value: 'ar', child: Align(alignment: AlignmentDirectional.centerStart, child: Text("العربية"))),
                  const DropdownMenuItem(value: 'en', child: Align(alignment: AlignmentDirectional.centerStart, child: Text("English"))),
                ],
                onChanged: (lang) async {
                  if (lang != null) {
                    await widget.storage.setString('lang_code', lang);
                    TranslationService.setLanguage(lang);
                    widget.onThemeChanged(); // Trigger root level rebuild for direction/translation
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section Calculations
          _buildSectionHeader(TranslationService.t('calc_settings')),
          Card(
            color: theme.cardColor,
            child: Column(
              children: [
                ListTile(
                  title: Text(TranslationService.t('calc_method')),
                  subtitle: Text(TranslationService.t('calc_settings')),
                  trailing: SizedBox(
                    width: 160,
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _calcMethod,
                      underline: const SizedBox(),
                      dropdownColor: theme.cardColor,
                      items: [
                        DropdownMenuItem(
                          value: 2, 
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(TranslationService.isArabic 
                                ? "الهيئة الإسلامية لأمريكا الشمالية (ISNA)" 
                                : "Islamic Society of North America (ISNA)"),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 3, 
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(TranslationService.isArabic 
                                ? "رابطة العالم الإسلامي" 
                                : "Muslim World League (MWL)"),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 4, 
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(TranslationService.isArabic 
                                ? "جامعة أم القرى (مكة)" 
                                : "Umm Al-Qura University (Makkah)"),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 5, 
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(TranslationService.isArabic 
                                ? "الهيئة المصرية العامة للمساحة" 
                                : "Egyptian General Authority of Survey"),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 13, 
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(TranslationService.isArabic 
                                ? "تركيا (الشؤون الدينية)" 
                                : "Turkey (Diyanet)"),
                          ),
                        ),
                      ],
                      onChanged: _changeCalcMethod,
                    ),
                  ),
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: Text(TranslationService.t('asr_calc_label')),
                  subtitle: Text(TranslationService.t('asr_calc_sub')),
                  trailing: SizedBox(
                    width: 160,
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _asrMethod,
                      underline: const SizedBox(),
                      dropdownColor: theme.cardColor,
                      items: [
                        DropdownMenuItem(
                          value: 0, 
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(TranslationService.isArabic 
                                ? "الشافعي، المالكي، الحنبلي" 
                                : "Standard (Shafi'i, Maliki, Hanbali)"),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 1, 
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(TranslationService.isArabic 
                                ? "المذهب الحنفي" 
                                : "Hanafi School"),
                          ),
                        ),
                      ],
                      onChanged: _changeAsrMethod,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Notifications
          _buildSectionHeader(TranslationService.t('athan_notif_label')),
          Card(
            color: theme.cardColor,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(TranslationService.t('fajr_notif')),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _alertFajr,
                  onChanged: (val) => _toggleAlert('alert_fajr', val, (v) => setState(() => _alertFajr = v)),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  title: Text(TranslationService.t('dhuhr_notif')),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _alertDhuhr,
                  onChanged: (val) => _toggleAlert('alert_dhuhr', val, (v) => setState(() => _alertDhuhr = v)),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  title: Text(TranslationService.t('asr_notif')),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _alertAsr,
                  onChanged: (val) => _toggleAlert('alert_asr', val, (v) => setState(() => _alertAsr = v)),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  title: Text(TranslationService.t('maghrib_notif')),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _alertMaghrib,
                  onChanged: (val) => _toggleAlert('alert_maghrib', val, (v) => setState(() => _alertMaghrib = v)),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  title: Text(TranslationService.t('isha_notif')),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _alertIsha,
                  onChanged: (val) => _toggleAlert('alert_isha', val, (v) => setState(() => _alertIsha = v)),
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: Text(TranslationService.t('pre_azan_reminder')),
                  trailing: DropdownButton<int>(
                    value: _preAzanReminder,
                    underline: const SizedBox(),
                    dropdownColor: theme.cardColor,
                    items: [
                      DropdownMenuItem(value: 0, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "إيقاف" : "None"))),
                      DropdownMenuItem(value: 5, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "قبل ٥ دقائق" : "5 minutes before"))),
                      DropdownMenuItem(value: 10, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "قبل ١٠ دقائق" : "10 minutes before"))),
                      DropdownMenuItem(value: 15, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "قبل ١٥ دقيقة" : "15 minutes before"))),
                    ],
                    onChanged: _changePreAzanReminder,
                  ),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  title: Text(TranslationService.t('morning_azkar_reminder')),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _morningAzkarReminder,
                  onChanged: (val) => _toggleDailyReminder('morning_azkar_reminder', val, (v) => _morningAzkarReminder = v),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  title: Text(TranslationService.t('evening_azkar_reminder')),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _eveningAzkarReminder,
                  onChanged: (val) => _toggleDailyReminder('evening_azkar_reminder', val, (v) => _eveningAzkarReminder = v),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  title: Text(TranslationService.t('todays_verse_reminder')),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _todaysVerseReminder,
                  onChanged: (val) => _toggleDailyReminder('todays_verse_reminder', val, (v) => _todaysVerseReminder = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Audio & Quran
          _buildSectionHeader(TranslationService.t('recitations')),
          Card(
            color: theme.cardColor,
            child: Column(
              children: [
                ListTile(
                  title: Text(TranslationService.t('qari')),
                  subtitle: Text(TranslationService.t('qari_sub')),
                  trailing: DropdownButton<String>(
                    value: _reciter,
                    underline: const SizedBox(),
                    dropdownColor: theme.cardColor,
                    items: [
                      const DropdownMenuItem(value: 'ar.alafasy', child: Align(alignment: AlignmentDirectional.centerStart, child: Text("مشاري العفاسي"))),
                      const DropdownMenuItem(value: 'ar.abdurrahmaansudais', child: Align(alignment: AlignmentDirectional.centerStart, child: Text("عبد الرحمن السديس"))),
                      const DropdownMenuItem(value: 'ar.mahermuaiqly', child: Align(alignment: AlignmentDirectional.centerStart, child: Text("ماهر المعيقلي"))),
                      const DropdownMenuItem(value: 'ar.saadalghamidi', child: Align(alignment: AlignmentDirectional.centerStart, child: Text("سعد الغامدي"))),
                    ],
                    onChanged: _changeReciter,
                  ),
                ),
                const Divider(height: 1, color: Colors.white10),
                 SwitchListTile(
                  title: Text(TranslationService.t('continuous_rec_label')),
                  subtitle: Text(TranslationService.t('continuous_rec_sub')),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _continuousPlay,
                  onChanged: _toggleContinuousPlay,
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  title: Text(TranslationService.isArabic ? "إخفاء حدود القراءة المتواصلة" : "Hide Continuous Mode Borders"),
                  subtitle: Text(TranslationService.isArabic 
                      ? "إزالة الحواف والظلال لتصبح الصفحات متصلة تماماً" 
                      : "Remove section borders and shadows for seamless reading"),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _hideContinuousBorders,
                  onChanged: _toggleHideContinuousBorders,
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  title: Text(TranslationService.isArabic ? "حفظ المرجعية تلقائياً" : "Auto-Bookmark on Play"),
                  subtitle: Text(TranslationService.isArabic
                      ? "حفظ الآية الحالية كعلامة مرجعية تلقائياً عند البدء بتشغيل التلاوة"
                      : "Automatically save the current verse as bookmark when audio playback starts"),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _autoBookmark,
                  onChanged: _toggleAutoBookmark,
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.download_for_offline, color: Color(0xFFE5C158)),
                  title: Text(TranslationService.t('quran_downloads')),
                  subtitle: Text(TranslationService.t('quran_downloads_sub')),
                  trailing: Icon(TranslationService.isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios, size: 14, color: Colors.white30),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuranDownloadScreen(storage: widget.storage),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Permissions
          _buildSectionHeader(TranslationService.t('system_settings_permissions')),
          Card(
            color: theme.cardColor,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(TranslationService.t('wake_lock')),
                  subtitle: Text(TranslationService.t('wake_lock_sub')),
                  activeThumbColor: const Color(0xFFE5C158),
                  value: _keepScreenAwake,
                  onChanged: _toggleKeepScreenAwake,
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: Text(TranslationService.t('exact_alarms')),
                  subtitle: Text(TranslationService.t('exact_alarms_sub')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _exactAlarmPermitted 
                            ? (TranslationService.isArabic ? "مسموح" : "Allowed") 
                            : (TranslationService.isArabic ? "إعداد مطلوب" : "Setup Required"),
                        style: TextStyle(
                          color: _exactAlarmPermitted ? Colors.green : const Color(0xFFE5C158),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        TranslationService.isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                        size: 12,
                        color: _exactAlarmPermitted ? Colors.white30 : const Color(0xFFE5C158),
                      ),
                    ],
                  ),
                  onTap: _exactAlarmPermitted ? null : _requestExactAlarm,
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: Text(TranslationService.t('battery_optimization')),
                  subtitle: Text(TranslationService.t('battery_optimization_sub')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _batteryIgnored 
                            ? (TranslationService.isArabic ? "متجاهل" : "Ignored") 
                            : (TranslationService.isArabic ? "إعداد مطلوب" : "Setup Required"),
                        style: TextStyle(
                          color: _batteryIgnored ? Colors.green : const Color(0xFFE5C158),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        TranslationService.isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                        size: 12,
                        color: _batteryIgnored ? Colors.white30 : const Color(0xFFE5C158),
                      ),
                    ],
                  ),
                  onTap: _batteryIgnored ? null : _requestBatteryOptimization,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Focus Lock
          _buildSectionHeader(TranslationService.t('focus_prayer_lock')),
          Card(
            color: theme.cardColor,
            child: Column(
              children: [
                ListTile(
                  title: Text(TranslationService.t('focus_timer')),
                  subtitle: Text(TranslationService.t('focus_prayer_lock_sub')),
                  trailing: DropdownButton<int>(
                    value: _focusLockDuration,
                    underline: const SizedBox(),
                    dropdownColor: theme.cardColor,
                    items: [
                      DropdownMenuItem(value: 0, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "إيقاف" : "Off"))),
                      DropdownMenuItem(value: 5, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "٥ دقائق" : "5 Minutes"))),
                      DropdownMenuItem(value: 10, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "١٠ دقائق" : "10 Minutes"))),
                      DropdownMenuItem(value: 15, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "١٥ دقيقة" : "15 Minutes"))),
                      DropdownMenuItem(value: 20, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "٢٠ دقيقة" : "20 Minutes"))),
                      DropdownMenuItem(value: 30, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(TranslationService.isArabic ? "٣٠ دقيقة" : "30 Minutes"))),
                    ],
                    onChanged: _changeFocusDuration,
                  ),
                ),
                if (_focusLockDuration > 0) ...[
                  const Divider(height: 1, color: Colors.white10),
                  SwitchListTile(
                    title: Text(TranslationService.t('focus_setting_auto')),
                    activeThumbColor: const Color(0xFFE5C158),
                    value: _focusAutoStart,
                    onChanged: _toggleFocusAutoStart,
                  ),
                ],
              ],
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
              trailing: Icon(TranslationService.isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios, size: 14, color: Colors.redAccent),
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
                  TranslationService.t('version_premium'),
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
      padding: const EdgeInsetsDirectional.only(start: 4.0, bottom: 8.0, end: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF0F766E),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
