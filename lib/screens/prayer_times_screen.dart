import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/prayer_models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  final StorageService storage;

  const PrayerTimesScreen({
    super.key,
    required this.storage,
  });

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  PrayerTimeData? _prayerData;
  bool _isLoading = true;
  int _calcMethod = 2; // ISNA
  int _asrMethod = 0;  // Standard (Shafi'i)

  @override
  void initState() {
    super.initState();
    _calcMethod = widget.storage.getInt('calc_method', defaultValue: 2);
    _asrMethod = widget.storage.getInt('asr_method', defaultValue: 0);
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    try {
      final loc = widget.storage.getLocation();
      
      PrayerTimeData data;
      if (loc['source'] == 'default' || loc['latitude'] == 30.0444) {
        data = await ApiService.fetchPrayerTimesByCity(
          city: loc['city'] ?? 'Cairo',
          country: loc['country'] ?? 'Egypt',
          method: _calcMethod,
          school: _asrMethod,
        );
      } else {
        data = await ApiService.fetchPrayerTimes(
          latitude: loc['latitude'],
          longitude: loc['longitude'],
          method: _calcMethod,
          school: _asrMethod,
        );
      }

      setState(() {
        _prayerData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(TranslationService.isArabic ? 'خطأ في تحميل مواقيت الصلاة: $e' : 'Error loading prayer times: $e')),
      );
    }
  }

  @override
  void didUpdateWidget(covariant PrayerTimesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newCalc = widget.storage.getInt('calc_method', defaultValue: 2);
    final newAsr = widget.storage.getInt('asr_method', defaultValue: 0);
    if (newCalc != _calcMethod || newAsr != _asrMethod) {
      setState(() {
        _calcMethod = newCalc;
        _asrMethod = newAsr;
      });
      _loadPrayerTimes();
    }
  }

  Future<void> _updateLocationWithGPS() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(TranslationService.isArabic ? 'خدمات الموقع معطلة.' : 'Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(TranslationService.isArabic ? 'تم رفض إذن الوصول للموقع.' : 'Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(TranslationService.isArabic ? 'تم رفض إذن الموقع بشكل دائم.' : 'Location permissions are permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final address = await ApiService.reverseGeocode(position.latitude, position.longitude);
      await widget.storage.setLocation(
        address['city'] ?? (TranslationService.isArabic ? 'موقعي' : 'My Location'),
        address['country'] ?? 'GPS',
        position.latitude,
        position.longitude,
        'gps',
      );

      await _loadPrayerTimes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(TranslationService.isArabic ? 'تم تحديث الموقع إلى ${address['city']}، ${address['country']}!' : 'Location updated to ${address['city']}, ${address['country']}!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(TranslationService.isArabic ? 'خطأ في تحديد الموقع (GPS): $e' : 'GPS Error: $e')),
        );
      }
    }
  }

  void _showManualLocationDialog() {
    final cityController = TextEditingController();
    final countryController = TextEditingController();

    // Load current values
    final currentLoc = widget.storage.getLocation();
    cityController.text = currentLoc['city'] ?? '';
    countryController.text = currentLoc['country'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(TranslationService.t('set_manual_loc'), style: const TextStyle(color: Color(0xFFE5C158), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: TranslationService.t('city_name'),
                  hintText: TranslationService.isArabic ? 'مثال: القاهرة' : 'e.g. London',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: countryController,
                decoration: InputDecoration(
                  labelText: TranslationService.t('country_name'),
                  hintText: TranslationService.isArabic ? 'مثال: مصر' : 'e.g. United Kingdom',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(TranslationService.t('cancel'), style: const TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5C158), foregroundColor: Colors.black),
              onPressed: () async {
                final city = cityController.text.trim();
                final country = countryController.text.trim();
                if (city.isNotEmpty && country.isNotEmpty) {
                  final navigator = Navigator.of(context);
                  // Save coordinates as fallback or mock
                  // For manual inputs, we set fallback coordinates to Cairo or London coordinates, 
                  // but the API timingsByCity handles the city name directly
                  await widget.storage.setLocation(city, country, 30.0444, 31.2357, 'manual');
                  navigator.pop();
                  unawaited(_loadPrayerTimes());
                }
              },
              child: Text(TranslationService.t('get_times')),
            ),
          ],
        );
      },
    );
  }

  String _getNextPrayerName() {
    if (_prayerData == null) return '';
    final now = DateTime.now();
    final todayStr = now.toIso8601String().substring(0, 10);

    final prayers = {
      'Fajr': _prayerData!.fajr,
      'Sunrise': _prayerData!.sunrise,
      'Dhuhr': _prayerData!.dhuhr,
      'Asr': _prayerData!.asr,
      'Maghrib': _prayerData!.maghrib,
      'Isha': _prayerData!.isha,
    };

    final List<MapEntry<String, DateTime>> todayPrayers = [];
    prayers.forEach((name, timeStr) {
      final cleanTime = timeStr.split(' ')[0];
      try {
        final parsed = DateTime.parse("${todayStr}T$cleanTime:00");
        todayPrayers.add(MapEntry(name, parsed));
      } catch (_) {}
    });

    todayPrayers.sort((a, b) => a.value.compareTo(b.value));

    for (final entry in todayPrayers) {
      if (entry.value.isAfter(now)) {
        return entry.key;
      }
    }
    return 'Fajr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = widget.storage.getLocation();

    return RefreshIndicator(
      onRefresh: _loadPrayerTimes,
      color: const Color(0xFFE5C158),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Settings Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFE5C158)),
                      const SizedBox(width: 8),
                      Text(
                        "Location Settings",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${TranslationService.t('current_location')}: ${loc['city']}, ${loc['country']}",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${TranslationService.isArabic ? 'الطريقة: الإحداثيات' : 'Method: Lat/Lng'} (${loc['latitude']?.toStringAsFixed(4) ?? '--'}, ${loc['longitude']?.toStringAsFixed(4) ?? '--'})",
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5C158),
                            foregroundColor: Colors.black,
                          ),
                          icon: const Icon(Icons.my_location, size: 18),
                          label: Text(TranslationService.t('use_gps')),
                          onPressed: _updateLocationWithGPS,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE5C158)),
                            foregroundColor: const Color(0xFFE5C158),
                          ),
                          icon: const Icon(Icons.keyboard, size: 18),
                          label: Text(TranslationService.t('set_manually')),
                          onPressed: _showManualLocationDialog,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Schedule Cards list
            Text(
              TranslationService.t('daily_schedule'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE5C158)))
                : _prayerData == null
                    ? Center(child: Text(TranslationService.isArabic ? "لم يتم تحميل مواقيت الصلاة بعد." : "No schedule details loaded."))
                    : Column(
                        children: [
                          _buildScheduleRow(theme, "Fajr", _prayerData!.fajr, Icons.cloud_queue),
                          _buildScheduleRow(theme, "Sunrise", _prayerData!.sunrise, Icons.wb_sunny_outlined),
                          _buildScheduleRow(theme, "Dhuhr", _prayerData!.dhuhr, Icons.wb_sunny),
                          _buildScheduleRow(theme, "Asr", _prayerData!.asr, Icons.wb_twilight),
                          _buildScheduleRow(theme, "Maghrib", _prayerData!.maghrib, Icons.wb_cloudy_outlined),
                          _buildScheduleRow(theme, "Isha", _prayerData!.isha, Icons.nights_stay),
                        ],
                      ),
          ],
        ),
      ),
     ),
    );
  }

  Widget _buildScheduleRow(ThemeData theme, String name, String time, IconData icon) {
    final cleanTime = time.split(' ')[0];
    final alertKey = 'alert_${name.toLowerCase()}';
    final alertOn = widget.storage.getBool(alertKey, defaultValue: true);
    final displayName = TranslationService.t(name.toLowerCase());
    final isNext = name == _getNextPrayerName();

    return Card(
      color: isNext ? const Color(0xFFE5C158).withOpacity(0.08) : theme.cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isNext ? const Color(0xFFE5C158).withOpacity(0.6) : Colors.transparent,
          width: isNext ? 1.8 : 0.0,
        ),
      ),
      elevation: isNext ? 4 : 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFFE5C158), size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
            Text(
              cleanTime,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(
                alertOn ? Icons.notifications_active : Icons.notifications_off,
                color: alertOn ? const Color(0xFFE5C158) : theme.disabledColor,
                size: 20,
              ),
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                await widget.storage.setBool(alertKey, !alertOn);
                setState(() {});
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(alertOn 
                        ? (TranslationService.isArabic ? 'تم كتم تنبيهات $displayName' : '$name notifications muted') 
                        : (TranslationService.isArabic ? 'تم تفعيل تنبيهات $displayName' : '$name notifications activated')),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
