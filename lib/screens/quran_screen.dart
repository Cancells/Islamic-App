import 'package:flutter/material.dart';
import '../models/quran_models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';
import 'surah_reader_screen.dart';

class QuranScreen extends StatefulWidget {
  final StorageService storage;
  final Function(int surahNum, String surahName, int ayahNum, String audioUrl) onPlayAudio;

  const QuranScreen({
    Key? key,
    required this.storage,
    required this.onPlayAudio,
  }) : super(key: key);

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<Surah> _surahList = [];
  List<Surah> _filteredSurahList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.fetchSurahList();
      setState(() {
        _surahList = list;
        _filteredSurahList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load Surah list: $e')),
      );
    }
  }

  void _filterSurahs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSurahList = _surahList;
      });
      return;
    }

    final lower = query.toLowerCase();
    setState(() {
      _filteredSurahList = _surahList.where((surah) {
        return surah.englishName.toLowerCase().contains(lower) ||
            surah.englishNameTranslation.toLowerCase().contains(lower) ||
            surah.number.toString() == query;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.storage.isDarkMode();

    return Column(
      children: [
        // Search Bar Container
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterSurahs,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: TranslationService.t('search_placeholder'),
              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFFE5C158)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _filterSurahs('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: theme.cardColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: const Color(0xFFE5C158).withOpacity(0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5C158)),
              ),
            ),
          ),
        ),

        // Surah List Builder
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE5C158)),
                )
              : _filteredSurahList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: theme.disabledColor),
                          const SizedBox(height: 12),
                          Text(
                            TranslationService.t('no_surah_match'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredSurahList.length,
                      itemBuilder: (context, index) {
                        final surah = _filteredSurahList[index];
                        return _buildSurahTile(surah, theme, isDark);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSurahTile(Surah surah, ThemeData theme, bool isDark) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE5C158).withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5C158).withOpacity(0.15)),
            ),
            child: Center(
              child: Text(
                surah.number.toString(),
                style: const TextStyle(
                  color: Color(0xFFE5C158),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            surah.englishName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                surah.revelationType.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.circle, size: 4, color: Colors.white24),
              const SizedBox(width: 6),
              Text(
                "${surah.numberOfAyahs} ${TranslationService.t('verses')}",
                style: TextStyle(
                  fontSize: 10,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ),
            ],
          ),
          trailing: Text(
            surah.name,
            style: const TextStyle(
              fontFamily: 'Amiri', // Arabic font loaded
              color: Color(0xFFE5C158),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahReaderScreen(
                  surah: surah,
                  storage: widget.storage,
                  onPlayAudio: widget.onPlayAudio,
                ),
              ),
            );
          },
        ),
        const Divider(height: 1, color: Colors.white10, indent: 68),
      ],
    );
  }
}
