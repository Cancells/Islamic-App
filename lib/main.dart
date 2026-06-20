import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/storage_service.dart';
import 'services/translation_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/tasbih_screen.dart';
import 'screens/azkar_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.getInstance();
  TranslationService.setLanguage(storage.getString('lang_code', defaultValue: 'ar'));
  runApp(NoorApp(storage: storage));
}

class NoorApp extends StatefulWidget {
  final StorageService storage;

  const NoorApp({Key? key, required this.storage}) : super(key: key);

  @override
  State<NoorApp> createState() => _NoorAppState();
}

class _NoorAppState extends State<NoorApp> {
  bool _isDarkMode = true;
  String _langCode = 'ar';

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.storage.isDarkMode();
    _langCode = widget.storage.getString('lang_code', defaultValue: 'ar');
    TranslationService.setLanguage(_langCode);
  }

  void _updateTheme() {
    setState(() {
      _isDarkMode = widget.storage.isDarkMode();
      _langCode = widget.storage.getString('lang_code', defaultValue: 'ar');
      TranslationService.setLanguage(_langCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noor - Islamic App',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Warm Sand Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F6F0),
        primaryColor: const Color(0xFF0F766E),
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        chipTheme: const ChipThemeData(
          backgroundColor: Color(0xFFECEFF1),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1E293B)),
          bodyMedium: TextStyle(color: Color(0xFF475569)),
        ),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF0F766E),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFB45309),
          unselectedItemColor: Color(0xFF64748B),
        ),
      ),

      // Premium Obsidian Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        primaryColor: const Color(0xFF054F37),
        cardColor: const Color(0xFF121B2F),
        dialogBackgroundColor: const Color(0xFF1E293B),
        chipTheme: const ChipThemeData(
          backgroundColor: Color(0xFF1E293B),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFF8FAFC)),
          bodyMedium: TextStyle(color: Color(0xFF94A3B8)),
        ),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF0F172A),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0F172A),
          selectedItemColor: Color(0xFFE5C158),
          unselectedItemColor: Color(0xFF64748B),
        ),
      ),
      
      home: Directionality(
        textDirection: TranslationService.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: MainScaffold(
          storage: widget.storage,
          onThemeChanged: _updateTheme,
        ),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onThemeChanged;

  const MainScaffold({
    Key? key,
    required this.storage,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentTab = 0;
  
  // Audio Player variables
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _playingTrackTitle = '';
  String _playingTrackSubtitle = '';
  int _playingSurahNum = 0;
  int _playingAyahNum = 0;
  String _currentAudioUrl = '';

  @override
  void initState() {
    super.initState();
    
    // Listen to player states
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = (state == PlayerState.playing);
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        _handleAudioCompletion();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _handleAudioCompletion() {
    // If continuous play is enabled, auto-play next verse if applicable
    final continuous = widget.storage.getBool('setting_continuous_play', defaultValue: true);
    if (continuous && _playingAyahNum > 0) {
      // Auto increment ayah index and fetch next url
      final nextAyah = _playingAyahNum + 1;
      // In a production build we'd fetch the next ayah url.
      // For now we stop or loop.
    }
  }

  void _playAudio(int surahNum, String surahName, int ayahNum, String audioUrl) async {
    try {
      if (_isPlaying && _currentAudioUrl == audioUrl) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
        return;
      }

      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(audioUrl));
      
      setState(() {
        _playingSurahNum = surahNum;
        _playingAyahNum = ayahNum;
        _playingTrackTitle = surahName;
        _playingTrackSubtitle = ayahNum == 0 ? "Full Surah Recitation" : "Ayah $ayahNum";
        _currentAudioUrl = audioUrl;
        _isPlaying = true;
      });

      // Save bookmark as last played/read
      if (ayahNum > 0) {
        widget.storage.addBookmark(surahNum, surahName, ayahNum);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio playback error: $e')),
      );
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      if (_currentAudioUrl.isNotEmpty) {
        await _audioPlayer.resume();
        setState(() => _isPlaying = true);
      }
    }
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _playingTrackTitle = '';
      _playingTrackSubtitle = '';
      _currentAudioUrl = '';
    });
  }

  Map<String, dynamic> _getLastBookmark() {
    final bookmarks = widget.storage.getBookmarks();
    return bookmarks.isNotEmpty ? bookmarks.first : {};
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.storage.isDarkMode();
    final theme = Theme.of(context);
    
    // Screens list mapping
    final List<Widget> screens = [
      DashboardScreen(
        storage: widget.storage, 
        onTabChange: (index) => setState(() => _currentTab = index),
        lastBookmark: _getLastBookmark(),
      ),
      QuranScreen(
        storage: widget.storage, 
        onPlayAudio: _playAudio,
      ),
      PrayerTimesScreen(
        storage: widget.storage,
      ),
      QiblaScreen(
        storage: widget.storage,
      ),
      TasbihScreen(
        storage: widget.storage,
      ),
      AzkarScreen(
        storage: widget.storage,
      ),
    ];

    final List<String> tabTitles = [
      TranslationService.t('app_title'),
      TranslationService.t('quran'),
      TranslationService.t('prayer'),
      TranslationService.t('qibla'),
      TranslationService.t('tasbih'),
      TranslationService.t('azkar'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tabTitles[_currentTab],
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 18),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF0F766E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFE5C158)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    storage: widget.storage,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Current Active Tab
          screens[_currentTab],

          // Floating Audio Player Widget (Bottom overlay)
          if (_playingTrackTitle.isNotEmpty)
            Positioned(
              left: 12,
              right: 12,
              bottom: 8,
              child: Card(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECEFF1),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5C158).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.music_note, color: Color(0xFFE5C158), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _playingTrackTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _playingTrackSubtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: const Color(0xFFE5C158)),
                        onPressed: _togglePlayPause,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.white60),
                        onPressed: _stopAudio,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: TranslationService.t('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: TranslationService.t('quran'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.access_time),
            activeIcon: const Icon(Icons.access_time_filled),
            label: TranslationService.t('prayer'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore),
            label: TranslationService.t('qibla'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fingerprint_outlined),
            activeIcon: const Icon(Icons.fingerprint),
            label: TranslationService.t('tasbih'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.volunteer_activism_outlined),
            activeIcon: const Icon(Icons.volunteer_activism),
            label: TranslationService.t('azkar'),
          ),
        ],
      ),
    );
  }
}
