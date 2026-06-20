import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran_models.dart';
import '../models/prayer_models.dart';

class ApiService {
  static const String _quranBaseUrl = 'https://api.alquran.cloud/v1';
  static const String _adhanBaseUrl = 'https://api.aladhan.com/v1';

  // Fetch list of all 114 Surahs
  static Future<List<Surah>> fetchSurahList() async {
    try {
      final response = await http.get(Uri.parse('$_quranBaseUrl/surah'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> list = data['data'];
        return list.map((json) => Surah.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load Surah list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchSurahList: $e');
      rethrow;
    }
  }

  // Fetch specific Surah text in Arabic & English translation
  static Future<List<Ayah>> fetchSurahDetails(int surahNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_quranBaseUrl/surah/$surahNumber/editions/quran-uthmani,en.sahih')
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> editions = data['data'];
        
        final List<dynamic> arabicAyahs = editions[0]['ayahs'];
        final List<dynamic> englishAyahs = editions[1]['ayahs'];
        
        final List<Ayah> ayahs = [];
        for (int i = 0; i < arabicAyahs.length; i++) {
          ayahs.add(Ayah.fromEditions(arabicAyahs[i], englishAyahs[i]));
        }
        return ayahs;
      } else {
        throw Exception('Failed to load Surah details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchSurahDetails: $e');
      rethrow;
    }
  }

  // Fetch prayer times using coordinates
  static Future<PrayerTimeData> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required int school,
  }) async {
    try {
      final dateStr = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
      // Format: YYYY-MM-DD matches DD-MM-YYYY in API if we query specific endpoint, 
      // but AlAdhan /timings endpoint takes timestamp or date.
      // Let's use /timings/{date} which takes DD-MM-YYYY format.
      final parts = dateStr.split('-');
      final formattedDate = "${parts[2]}-${parts[1]}-${parts[0]}"; // DD-MM-YYYY
      
      final url = Uri.parse(
        '$_adhanBaseUrl/timings/$formattedDate?latitude=$latitude&longitude=$longitude&method=$method&school=$school'
      );
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PrayerTimeData.fromJson(data['data']);
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchPrayerTimes: $e');
      rethrow;
    }
  }

  // Fetch prayer times using City and Country
  static Future<PrayerTimeData> fetchPrayerTimesByCity({
    required String city,
    required String country,
    required int method,
    required int school,
  }) async {
    try {
      final dateStr = DateTime.now().toIso8601String().substring(0, 10);
      final parts = dateStr.split('-');
      final formattedDate = "${parts[2]}-${parts[1]}-${parts[0]}"; // DD-MM-YYYY
      
      final url = Uri.parse(
        '$_adhanBaseUrl/timingsByCity/$formattedDate?city=$city&country=$country&method=$method&school=$school'
      );
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PrayerTimeData.fromJson(data['data']);
      } else {
        throw Exception('Failed to load prayer times by city: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchPrayerTimesByCity: $e');
      rethrow;
    }
  }
}
