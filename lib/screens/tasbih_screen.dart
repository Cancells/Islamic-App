import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';

class TasbihScreen extends StatefulWidget {
  final StorageService storage;

  const TasbihScreen({
    Key? key,
    required this.storage,
  }) : super(key: key);

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _count = 0;
  int _target = 33;
  String _arabicText = 'سُبْحَانَ ٱللَّٰهِ';
  String _translationText = 'Glory be to Allah';
  String _currentDhikrName = 'SubhanAllah';

  List<Map<String, dynamic>> _presets = [];

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  void _loadPresets() {
    final List<Map<String, dynamic>> standard = [
      {'name': 'SubhanAllah', 'arabic': 'سُبْحَانَ ٱللَّٰهِ', 'translation': 'Glory be to Allah', 'target': 33},
      {'name': 'Alhamdulillah', 'arabic': 'ٱلْحَمْدُ لِلَّٰهِ', 'translation': 'Praise be to Allah', 'target': 33},
      {'name': 'Allahu Akbar', 'arabic': 'ٱللَّٰهُ أَكْبَرُ', 'translation': 'Allah is the Greatest', 'target': 34},
      {'name': 'Astaghfirullah', 'arabic': 'أَسْتَغْفِرُ ٱللَّٰهَ', 'translation': 'I seek forgiveness from Allah', 'target': 100},
      {'name': 'La ilaha illallah', 'arabic': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ', 'translation': 'There is no god but Allah', 'target': 100},
    ];

    final custom = widget.storage.getCustomDhikrs();
    setState(() {
      _presets = [...standard, ...custom];
    });
  }

  void _selectDhikr(Map<String, dynamic> item) {
    setState(() {
      _currentDhikrName = item['name'];
      _arabicText = item['arabic'] ?? '';
      _translationText = item['translation'] ?? '';
      _target = item['target'] ?? 33;
      _count = 0;
    });
    HapticFeedback.mediumImpact();
  }

  void _increment() {
    setState(() {
      _count++;
    });

    if (_count == _target) {
      HapticFeedback.vibrate(); // Long vibrate on target reached
      _showTargetReachedNotification();
    } else {
      HapticFeedback.lightImpact(); // Soft click feel
    }
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
    HapticFeedback.heavyImpact();
  }

  void _showTargetReachedNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Target of $_target reached for $_currentDhikrName!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddCustomDhikrDialog() {
    final nameController = TextEditingController();
    final arabicController = TextEditingController();
    final translationController = TextEditingController();
    final targetController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: const Text("Add Custom Dhikr", style: TextStyle(color: Color(0xFFE5C158), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Dhikr Name (English)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: arabicController,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(labelText: 'Arabic Script (Optional)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: translationController,
                  decoration: const InputDecoration(labelText: 'Translation (Optional)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target Count'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5C158), foregroundColor: Colors.black),
              onPressed: () async {
                final name = nameController.text.trim();
                final targetVal = int.tryParse(targetController.text) ?? 100;
                if (name.isNotEmpty) {
                  await widget.storage.addCustomDhikr(
                    name,
                    arabicController.text.trim(),
                    translationController.text.trim(),
                    targetVal,
                  );
                  Navigator.pop(context);
                  _loadPresets();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercent = (_count / _target).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt layout for mobile sizes
        final isCompact = constraints.maxHeight < 550;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Preset List (Horizontal selection)
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _presets.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _presets.length) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            avatar: const Icon(Icons.add, size: 16, color: Color(0xFFE5C158)),
                            label: const Text("Custom"),
                            backgroundColor: theme.cardColor,
                            onPressed: _showAddCustomDhikrDialog,
                          ),
                        );
                      }
                      
                      final preset = _presets[index];
                      final isSelected = preset['name'] == _currentDhikrName;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          selectedColor: const Color(0xFFE5C158).withOpacity(0.2),
                          disabledColor: theme.cardColor,
                          label: Text(
                            preset['name'],
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFE5C158) : theme.textTheme.bodyMedium?.color,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) _selectDhikr(preset);
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: isCompact ? 16 : 40),

                // Active Dhikr Texts
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 90,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _arabicText,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 26,
                          color: Color(0xFFE5C158),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _translationText,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isCompact ? 16 : 40),

                // Big Click Area
                GestureDetector(
                  onTap: _increment,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress Circle Ring
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: progressPercent,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.04),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE5C158)),
                          ),
                        ),
                        // Inner Click Button
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _count.toString(),
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Target: $_target",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isCompact ? 16 : 40),

                // Reset Action Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    foregroundColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("Reset Count"),
                  onPressed: _reset,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
