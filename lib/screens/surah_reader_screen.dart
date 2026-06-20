import 'package:flutter/material.dart';
import '../models/quran_models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class SurahReaderScreen extends StatefulWidget {
  final Surah surah;
  final StorageService storage;
  final Function(int surahNum, String surahName, int ayahNum, String audioUrl) onPlayAudio;

  const SurahReaderScreen({
    Key? key,
    required this.surah,
    required this.storage,
    required this.onPlayAudio,
  }) : super(key: key);

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  List<Ayah> _ayahList = [];
  bool _isLoading = true;
  double _fontSizeMultiplier = 1.0;
  bool _showTranslation = true;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadAyahs();
    _checkBookmarkStatus();
  }

  void _checkBookmarkStatus() {
    final bookmarks = widget.storage.getBookmarks();
    final exists = bookmarks.any((b) => b['surahNumber'] == widget.surah.number);
    setState(() {
      _isBookmarked = exists;
    });
  }

  Future<void> _loadAyahs() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.fetchSurahDetails(widget.surah.number);
      setState(() {
        _ayahList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load verses: $e')),
      );
    }
  }

  void _toggleBookmark() async {
    if (_isBookmarked) {
      await widget.storage.removeBookmark(widget.surah.number);
      setState(() => _isBookmarked = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark removed'), duration: Duration(seconds: 1)),
      );
    } else {
      await widget.storage.addBookmark(widget.surah.number, widget.surah.englishName, 1);
      setState(() => _isBookmarked = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark saved'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _changeFontSize(double delta) {
    setState(() {
      _fontSizeMultiplier = (_fontSizeMultiplier + delta).clamp(0.8, 1.8);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.storage.isDarkMode();
    final arabicFont = widget.storage.getString('quran_font', defaultValue: 'font-scheherazade') == 'font-amiri' 
      ? 'Amiri' 
      : 'Scheherazade New';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.surah.englishName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "${widget.surah.englishNameTranslation} • ${widget.surah.numberOfAyahs} Verses",
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF0F766E),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: const Color(0xFFE5C158)),
            onPressed: _toggleBookmark,
            tooltip: 'Bookmark Surah',
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              // Toggle size modal
              showModalBottomSheet(
                context: context,
                backgroundColor: theme.cardColor,
                builder: (context) => StatefulBuilder(
                  builder: (context, setModalState) => Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Reading Adjustments",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Translation"),
                            Switch(
                              value: _showTranslation,
                              activeColor: const Color(0xFFE5C158),
                              onChanged: (val) {
                                setState(() => _showTranslation = val);
                                setModalState(() => _showTranslation = val);
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Arabic Font Size"),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    _changeFontSize(-0.1);
                                    setModalState(() {});
                                  },
                                ),
                                Text("${(_fontSizeMultiplier * 100).toInt()}%"),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    _changeFontSize(0.1);
                                    setModalState(() {});
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE5C158)),
            )
          : Column(
              children: [
                // Full Surah Audio play bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECEFF1),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up, color: Color(0xFFE5C158)),
                      const SizedBox(width: 12),
                      const Text(
                        "Listen to Full Surah",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5C158),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: const Text("PLAY"),
                        onPressed: () {
                          // Play Surah Audio (Mishary Rashid Alafasy - Default)
                          final reciter = widget.storage.getString('default_reciter', defaultValue: 'ar.alafasy');
                          // Direct play URL
                          final url = 'https://cdn.alquran.cloud/media/audio/surah/$reciter/${widget.surah.number}.mp3';
                          widget.onPlayAudio(widget.surah.number, widget.surah.englishName, 0, url);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Streaming Surah ${widget.surah.englishName}...'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _ayahList.length + 1, // Add 1 for Bismillah header
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Render Bismillah header except for Surah 9 (Al-Tawbah) and Surah 1 (since it contains it in first ayah)
                        if (widget.surah.number == 9 || widget.surah.number == 1) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: const Text(
                            "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 28,
                              color: Color(0xFFE5C158),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      
                      final ayah = _ayahList[index - 1];
                      return _buildAyahCard(ayah, theme, arabicFont);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAyahCard(Ayah ayah, ThemeData theme, String arabicFont) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: Colors.white.withOpacity(0.04)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of card (Ayah number, play audio)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${widget.surah.number}:${ayah.numberInSurah}",
                  style: const TextStyle(
                    color: Color(0xFFE5C158),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline, size: 20, color: Color(0xFFE5C158)),
                    onPressed: () {
                      final reciter = widget.storage.getString('default_reciter', defaultValue: 'ar.alafasy');
                      final url = 'https://cdn.alquran.cloud/media/audio/ayah/$reciter/${ayah.number}';
                      widget.onPlayAudio(
                        widget.surah.number, 
                        "${widget.surah.englishName} : Ayah ${ayah.numberInSurah}", 
                        ayah.numberInSurah, 
                        url
                      );
                    },
                    tooltip: 'Play Verse Audio',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Arabic verse text (Right Aligned)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              ayah.text,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: arabicFont,
                fontSize: 22 * _fontSizeMultiplier,
                height: 1.9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_showTranslation) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            // English translation text
            Text(
              ayah.translation,
              style: TextStyle(
                fontSize: 14 * _fontSizeMultiplier,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
                height: 1.5,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
