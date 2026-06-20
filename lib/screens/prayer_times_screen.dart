import 'package:flutter/material.dart';
import '../models/prayer_models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  final StorageService storage;

  const PrayerTimesScreen({
    Key? key,
    required this.storage,
  }) : super(key: key);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading prayer times: $e')),
      );
    }
  }

  void _saveSettings() async {
    await widget.storage.setInt('calc_method', _calcMethod);
    await widget.storage.setInt('asr_method', _asrMethod);
    _loadPrayerTimes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings updated!'), duration: Duration(seconds: 1)),
    );
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
          title: const Text("Set Location Manually", style: TextStyle(color: Color(0xFFE5C158), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'City Name',
                  hintText: 'e.g. London',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: countryController,
                decoration: const InputDecoration(
                  labelText: 'Country Name',
                  hintText: 'e.g. United Kingdom',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5C158), foregroundColor: Colors.black),
              onPressed: () async {
                final city = cityController.text.trim();
                final country = countryController.text.trim();
                if (city.isNotEmpty && country.isNotEmpty) {
                  // Save coordinates as fallback or mock
                  // For manual inputs, we set fallback coordinates to Cairo or London coordinates, 
                  // but the API timingsByCity handles the city name directly
                  await widget.storage.setLocation(city, country, 30.0444, 31.2357, 'manual');
                  Navigator.pop(context);
                  _loadPrayerTimes();
                }
              },
              child: const Text('Get Times'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.storage.isDarkMode();
    final loc = widget.storage.getLocation();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                    "Current Location: ${loc['city']}, ${loc['country']}",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Method: Lat/Lng (${loc['latitude']?.toStringAsFixed(4) ?? '--'}, ${loc['longitude']?.toStringAsFixed(4) ?? '--'})",
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
                          label: const Text("Use GPS"),
                          onPressed: () async {
                            // Geolocation simulation or update
                            // Since geolocation requires manifest permissions and could block, 
                            // we provide coordinates update (e.g. simulated coordinates) or manual input.
                            // We set Makkah coordinates as mock location
                            await widget.storage.setLocation("Makkah", "Saudi Arabia", 21.4225, 39.8262, 'gps');
                            _loadPrayerTimes();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Location updated to Makkah (Simulated GPS)!')),
                            );
                          },
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
                          label: const Text("Set Manually"),
                          onPressed: _showManualLocationDialog,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Calculation parameters Card
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
                      const Icon(Icons.settings, color: Color(0xFFE5C158)),
                      const SizedBox(width: 8),
                      const Text(
                        "Calculation Settings",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _calcMethod,
                    dropdownColor: theme.cardColor,
                    decoration: const InputDecoration(labelText: 'Calculation Method'),
                    items: const [
                      DropdownMenuItem(value: 2, child: Text("ISNA (North America)")),
                      DropdownMenuItem(value: 3, child: Text("Muslim World League")),
                      DropdownMenuItem(value: 4, child: Text("Umm Al-Qura (Makkah)")),
                      DropdownMenuItem(value: 1, child: Text("Egyptian Survey")),
                      DropdownMenuItem(value: 13, child: Text("Diyanet (Turkey)")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _calcMethod = val);
                        _saveSettings();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _asrMethod,
                    dropdownColor: theme.cardColor,
                    decoration: const InputDecoration(labelText: 'Asr Calculation Method'),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text("Standard (Shafi'i, Maliki, Hanbali)")),
                      DropdownMenuItem(value: 1, child: Text("Hanafi School (Later Asr)")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _asrMethod = val);
                        _saveSettings();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Schedule Cards list
            const Text(
              "Daily Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE5C158)))
                : _prayerData == null
                    ? const Center(child: Text("No schedule details loaded."))
                    : Column(
                        children: [
                          _buildScheduleRow(theme, "Fajr", _prayerData!.fajr, Icons.cloud_queue),
                          _buildScheduleRow(theme, "Sunrise", _prayerData!.sunrise, Icons.wb_sunny_outlined),
                          _buildScheduleRow(theme, "Dhuhr", _prayerData!.dhuhr, Icons.wb_sunny),
                          _buildScheduleRow(theme, "Asr", _prayerData!.asr, Icons.wb_twighlight),
                          _buildScheduleRow(theme, "Maghrib", _prayerData!.maghrib, Icons.wb_cloudy_outlined),
                          _buildScheduleRow(theme, "Isha", _prayerData!.isha, Icons.nights_stay),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(ThemeData theme, String name, String time, IconData icon) {
    final cleanTime = time.split(' ')[0];
    final alertKey = 'alert_${name.toLowerCase()}';
    final alertOn = widget.storage.getBool(alertKey, defaultValue: true);

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    name,
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
                await widget.storage.setBool(alertKey, !alertOn);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(alertOn ? '$name notifications muted' : '$name notifications activated'),
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
