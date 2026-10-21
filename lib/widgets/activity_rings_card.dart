import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../theme/apple_colors.dart';

class ActivityRingsCard extends StatelessWidget {
  final double todayProgress;
  final double highPriorityProgress;
  final double overallProgress;
  final int todayCount;
  final int completedToday;
  final bool isDark;

  const ActivityRingsCard({
    super.key,
    required this.todayProgress,
    required this.highPriorityProgress,
    required this.overallProgress,
    required this.todayCount,
    required this.completedToday,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (todayProgress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppleColors.card(isDark),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x0C000000),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0x22FFFFFF) : const Color(0x0A000000),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rings graphic
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(110, 110),
                  painter: _ConcentricRingsPainter(
                    ring1: todayProgress.clamp(0.0, 1.0),
                    ring2: highPriorityProgress.clamp(0.0, 1.0),
                    ring3: overallProgress.clamp(0.0, 1.0),
                    isDark: isDark,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppleColors.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      'HARI INI',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppleColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          // Legend / Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Aktivitas Harian',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: AppleColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  percent == 100
                      ? 'Target hari ini tercapai penuh! 🎉'
                      : '$completedToday dari ${todayCount + completedToday} tugas selesai',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppleColors.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 12),
                _RingStatRow(
                  color: AppleColors.systemPink,
                  label: 'Hari ini',
                  value: '${(todayProgress * 100).toInt()}%',
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                _RingStatRow(
                  color: AppleColors.systemTeal,
                  label: 'Prioritas Tinggi',
                  value: '${(highPriorityProgress * 100).toInt()}%',
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                _RingStatRow(
                  color: AppleColors.systemIndigo,
                  label: 'Semua Tugas',
                  value: '${(overallProgress * 100).toInt()}%',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingStatRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final bool isDark;

  const _RingStatRow({
    required this.color,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppleColors.textSecondary(isDark),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppleColors.textPrimary(isDark),
          ),
        ),
      ],
    );
  }
}

class _ConcentricRingsPainter extends CustomPainter {
  final double ring1; // Outer
  final double ring2; // Middle
  final double ring3; // Inner
  final bool isDark;

  _ConcentricRingsPainter({
    required this.ring1,
    required this.ring2,
    required this.ring3,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 8.0;
    final gap = 3.0;

    // Radius
    final r1 = (size.width / 2) - strokeWidth / 2;
    final r2 = r1 - strokeWidth - gap;
    final r3 = r2 - strokeWidth - gap;

    _drawRing(
      canvas: canvas,
      center: center,
      radius: r1,
      strokeWidth: strokeWidth,
      progress: ring1,
      color: AppleColors.systemPink,
    );

    _drawRing(
      canvas: canvas,
      center: center,
      radius: r2,
      strokeWidth: strokeWidth,
      progress: ring2,
      color: AppleColors.systemTeal,
    );

    _drawRing(
      canvas: canvas,
      center: center,
      radius: r3,
      strokeWidth: strokeWidth,
      progress: ring3,
      color: AppleColors.systemIndigo,
    );
  }

  void _drawRing({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double strokeWidth,
    required double progress,
    required Color color,
  }) {
    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.2 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    // Active arc with round cap
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at 12 o'clock
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return oldDelegate.ring1 != ring1 ||
        oldDelegate.ring2 != ring2 ||
        oldDelegate.ring3 != ring3 ||
        oldDelegate.isDark != isDark;
  }
}
