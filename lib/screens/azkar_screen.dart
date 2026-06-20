import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/azkar_data.dart';
import '../services/storage_service.dart';

class AzkarScreen extends StatefulWidget {
  final StorageService storage;

  const AzkarScreen({
    Key? key,
    required this.storage,
  }) : super(key: key);

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, int> _countsCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeCounts() {
    // Set up standard counts for each item
    for (var item in AzkarData.morning) {
      _countsCache[item.id] = item.count;
    }
    for (var item in AzkarData.evening) {
      _countsCache[item.id] = item.count;
    }
    for (var item in AzkarData.postPrayer) {
      _countsCache[item.id] = item.count;
    }
    for (var item in AzkarData.daily) {
      _countsCache[item.id] = item.count;
    }
  }

  void _decrementCount(String id, int originalMax) {
    final current = _countsCache[id] ?? originalMax;
    if (current > 0) {
      setState(() {
        _countsCache[id] = current - 1;
      });
      if (current - 1 == 0) {
        HapticFeedback.vibrate(); // Celebration vibration
      } else {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _resetAzkarTab(List<AzkarItem> items) {
    setState(() {
      for (var item in items) {
        _countsCache[item.id] = item.count;
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.storage.isDarkMode();

    return Column(
      children: [
        // Category Tabs
        TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE5C158),
          labelColor: const Color(0xFFE5C158),
          unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          isScrollable: true,
          physics: const BouncingScrollPhysics(),
          tabs: const [
            Tab(text: "Morning"),
            Tab(text: "Evening"),
            Tab(text: "Post-Prayer"),
            Tab(text: "Daily Duas"),
          ],
        ),
        
        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildAzkarList(AzkarData.morning, theme),
              _buildAzkarList(AzkarData.evening, theme),
              _buildAzkarList(AzkarData.postPrayer, theme),
              _buildAzkarList(AzkarData.daily, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAzkarList(List<AzkarItem> list, ThemeData theme) {
    return Column(
      children: [
        // Tab Actions (Reset button)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _resetAzkarTab(list),
                icon: const Icon(Icons.restore, size: 16, color: Color(0xFFE5C158)),
                label: const Text(
                  "Reset Counts",
                  style: TextStyle(color: Color(0xFFE5C158), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final currentCount = _countsCache[item.id] ?? item.count;
              final isDone = currentCount == 0;

              return Card(
                color: theme.cardColor,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDone 
                      ? const Color(0xFF10B981).withOpacity(0.5) 
                      : Colors.white.withOpacity(0.04),
                    width: isDone ? 1.5 : 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Top Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5C158).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Read ${item.count} times",
                              style: const TextStyle(
                                color: Color(0xFFE5C158),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Interactive decrement counter
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDone ? const Color(0xFF10B981) : const Color(0xFFE5C158),
                              foregroundColor: isDone ? Colors.white : Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: Icon(isDone ? Icons.check : Icons.fingerprint, size: 14),
                            label: Text(
                              isDone ? "Done" : "$currentCount remaining",
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: isDone ? null : () => _decrementCount(item.id, item.count),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Arabic text (Right Aligned)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          item.arabic,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 22,
                            height: 1.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 8),
                      // Transliteration (Italicized)
                      Text(
                        item.transliteration,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // English Translation
                      Text(
                        item.translation,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Reference citation
                      Text(
                        "Source: ${item.reference}",
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
