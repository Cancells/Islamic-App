import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // General set/get
  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    return _prefs!.getString(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs!.getBool(key) ?? defaultValue;
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs!.getInt(key) ?? defaultValue;
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs!.getDouble(key) ?? defaultValue;
  }

  // Specific state helpers

  // Dark/Light Theme
  bool isDarkMode() {
    return getBool('is_dark_mode', defaultValue: true);
  }

  Future<bool> setDarkMode(bool val) async {
    return await setBool('is_dark_mode', val);
  }

  // Location Cache
  Map<String, dynamic> getLocation() {
    final raw = getString('user_location');
    if (raw.isEmpty) {
      return {
        'city': 'Cairo',
        'country': 'Egypt',
        'latitude': 30.0444,
        'longitude': 31.2357,
        'source': 'default'
      };
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<bool> setLocation(String city, String country, double lat, double lng, String source) async {
    final data = {
      'city': city,
      'country': country,
      'latitude': lat,
      'longitude': lng,
      'source': source
    };
    return await setString('user_location', jsonEncode(data));
  }

  // Bookmarks
  List<Map<String, dynamic>> getBookmarks() {
    final raw = getString('quran_bookmarks');
    if (raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addBookmark(int surahNumber, String surahName, int ayahNumber) async {
    final bookmarks = getBookmarks();
    final item = {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    
    // Remove duplication for the same Surah
    bookmarks.removeWhere((element) => element['surahNumber'] == surahNumber);
    bookmarks.insert(0, item);
    
    // Cap at 10 bookmarks
    if (bookmarks.length > 10) {
      bookmarks.removeLast();
    }
    
    await setString('quran_bookmarks', jsonEncode(bookmarks));
  }

  Future<void> removeBookmark(int surahNumber) async {
    final bookmarks = getBookmarks();
    bookmarks.removeWhere((element) => element['surahNumber'] == surahNumber);
    await setString('quran_bookmarks', jsonEncode(bookmarks));
  }

  // Custom Dhikr list
  List<Map<String, dynamic>> getCustomDhikrs() {
    final raw = getString('custom_dhikrs');
    if (raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addCustomDhikr(String name, String arabic, String translation, int target) async {
    final items = getCustomDhikrs();
    final item = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'arabic': arabic,
      'translation': translation,
      'target': target
    };
    items.add(item);
    await setString('custom_dhikrs', jsonEncode(items));
  }

  Future<void> deleteCustomDhikr(String id) async {
    final items = getCustomDhikrs();
    items.removeWhere((element) => element['id'] == id);
    await setString('custom_dhikrs', jsonEncode(items));
  }
}
