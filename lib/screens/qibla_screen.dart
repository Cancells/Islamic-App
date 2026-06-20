import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class QiblaScreen extends StatefulWidget {
  final StorageService storage;

  const QiblaScreen({
    Key? key,
    required this.storage,
  }) : super(key: key);

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _qiblaAngle = 0;
  double _deviceHeading = 0; // Simulated heading in degrees (0 = North)
  String _locationName = "Cairo, Egypt";

  @override
  void initState() {
    super.initState();
    _calculateQiblaDirection();
  }

  void _calculateQiblaDirection() {
    final loc = widget.storage.getLocation();
    final double lat = loc['latitude'] ?? 30.0444;
    final double lng = loc['longitude'] ?? 31.2357;
    
    // Kaaba Coordinates
    const double latK = 21.4225 * pi / 180.0;
    const double lngK = 39.8262 * pi / 180.0;
    
    final double phi = lat * pi / 180.0;
    final double lambda = lng * pi / 180.0;
    
    final double deltaLambda = lngK - lambda;
    
    final double y = sin(deltaLambda);
    final double x = cos(phi) * tan(latK) - sin(phi) * cos(deltaLambda);
    
    double qiblaRad = atan2(y, x);
    double qiblaDeg = (qiblaRad * 180.0 / pi + 360.0) % 360.0;

    setState(() {
      _qiblaAngle = qiblaDeg;
      _locationName = "${loc['city']}, ${loc['country']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relativeAngle = (_qiblaAngle - _deviceHeading + 360.0) % 360.0;
    final isAligned = (relativeAngle < 5 || relativeAngle > 355);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          // Info Cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildStatColumn("Your Location", _locationName),
                Container(width: 1, height: 40, color: Colors.white12),
                _buildStatColumn("Qibla Angle", "${_qiblaAngle.toStringAsFixed(1)}° N"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            isAligned ? "Aligned with Kaaba!" : "Rotate device to align with Kaaba",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isAligned ? const Color(0xFF10B981) : Colors.white70,
            ),
          ),
          const SizedBox(height: 40),

          // Interactive Rotating Compass
          GestureDetector(
            onPanUpdate: (details) {
              // Simulate compass rotation by dragging horizontally
              setState(() {
                _deviceHeading = (_deviceHeading + details.delta.dx / 2.0 + 360.0) % 360.0;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Compass Dial Background & Text
                Transform.rotate(
                  angle: -_deviceHeading * pi / 180.0,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isAligned ? const Color(0xFF10B981) : const Color(0xFFE5C158),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isAligned ? const Color(0xFF10B981) : const Color(0xFFE5C158)).withOpacity(0.15),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: CompassDialPainter(theme: theme),
                    ),
                  ),
                ),

                // Qibla needle pointing to Makkah
                Transform.rotate(
                  angle: (relativeAngle - 90) * pi / 180.0, // Adjust by 90 to match needle default orientation
                  child: SizedBox(
                    width: 230,
                    height: 230,
                    child: Stack(
                      children: [
                        // Pointer Arrow
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: const Icon(
                              Icons.keyboard_arrow_right,
                              color: Color(0xFFE5C158),
                              size: 32,
                            ),
                          ),
                        ),
                        // Kaaba Icon at the tip
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(right: 42),
                            child: Transform.rotate(
                              angle: (90 - relativeAngle) * pi / 180.0, // Keep icon upright
                              child: const Icon(
                                Icons.mosque,
                                color: Color(0xFFE5C158),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Pin
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5C158),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Simulation Slider for Emulator
          const Spacer(),
          Text(
            "Compass Rotation Simulator: ${(_deviceHeading).toInt()}°",
            style: const TextStyle(fontSize: 12, color: Colors.white38),
          ),
          Slider(
            value: _deviceHeading,
            min: 0,
            max: 360,
            activeColor: const Color(0xFFE5C158),
            onChanged: (val) {
              setState(() {
                _deviceHeading = val;
              });
            },
          ),
          const Text(
            "Swipe/Drag the compass or use the slider to rotate.",
            style: TextStyle(fontSize: 11, color: Colors.white24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE5C158)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CompassDialPainter extends CustomPainter {
  final ThemeData theme;
  CompassDialPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintText = TextPainter(textDirection: TextDirection.ltr);

    void drawLabel(String text, double angle, Color color) {
      paintText.text = TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
      );
      paintText.layout();
      final radius = (size.width / 2) - 24;
      final x = center.dx + radius * cos(angle - pi / 2) - paintText.width / 2;
      final y = center.dy + radius * sin(angle - pi / 2) - paintText.height / 2;
      paintText.paint(canvas, Offset(x, y));
    }

    // Draw Cardinal points
    drawLabel("N", 0, const Color(0xFF10B981));
    drawLabel("E", pi / 2, Colors.white70);
    drawLabel("S", pi, Colors.white70);
    drawLabel("W", 3 * pi / 2, Colors.white70);

    // Draw minor ticks
    final tickPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 30) {
      if (i % 90 == 0) continue;
      final angle = i * pi / 180;
      final startRadius = (size.width / 2) - 12;
      final endRadius = (size.width / 2) - 4;
      final start = Offset(center.dx + startRadius * cos(angle), center.dy + startRadius * sin(angle));
      final end = Offset(center.dx + endRadius * cos(angle), center.dy + endRadius * sin(angle));
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
