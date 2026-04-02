import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';

class ThemedCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const ThemedCard({super.key, required this.child, this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    final style = appThemeNotifier.value;
    
    if (style == AveroThemeStyle.calming) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor == Colors.white ? Colors.white : backgroundColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 8),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      );
    } else if (style == AveroThemeStyle.oled) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.grey.shade800, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );
    } else if (style == AveroThemeStyle.glassmorphic) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 24,
                  spreadRadius: -5,
                )
              ]
            ),
            child: child,
          ),
        ),
      );
    } else if (style == AveroThemeStyle.neumorphic) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E5EC),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFA3B1C6),
              offset: Offset(8, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-8, -8),
              blurRadius: 16,
            ),
          ],
        ),
        child: child,
      );
    } else if (style == AveroThemeStyle.appleLike) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 4),
              blurRadius: 20,
            ),
          ]
        ),
        child: child,
      );
    } else {
      // Neo-brutalist
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(6, 6),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: child,
      );
    }
  }
}

class ThemedTimerPainter extends CustomPainter {
  final int seconds;
  final AveroThemeStyle style;

  ThemedTimerPainter({required this.seconds, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final progress = (seconds % 60) / 60.0;

    if (style == AveroThemeStyle.calming || style == AveroThemeStyle.appleLike) {
      final bgPaint = Paint()
        ..color = style == AveroThemeStyle.calming ? const Color(0xFFE8EFEA) : const Color(0xFFE5E5EA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = style == AveroThemeStyle.appleLike ? 12 : 16
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, bgPaint);

      if (seconds > 0) {
        final arcPaint = Paint()
          ..color = style == AveroThemeStyle.calming ? const Color(0xFF6DA28F) : const Color(0xFF007AFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = style == AveroThemeStyle.appleLike ? 12 : 16
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -pi / 2,
          progress * 2 * pi,
          false,
          arcPaint,
        );
      }
    } else if (style == AveroThemeStyle.oled) {
      final bgPaint = Paint()
        ..color = Colors.grey.shade900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius, bgPaint);

      if (seconds > 0) {
        final arcPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.square;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -pi / 2,
          progress * 2 * pi,
          false,
          arcPaint,
        );
      }
    } else if (style == AveroThemeStyle.glassmorphic) {
      final bgPaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20;
      canvas.drawCircle(center, radius, bgPaint);

      if (seconds > 0) {
        final arcPaint = Paint()
          ..color = const Color(0xFF8B5CF6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20
          ..strokeCap = StrokeCap.round;
        
        // Add subtle glow
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -pi / 2,
          progress * 2 * pi,
          false,
          Paint()
            ..color = const Color(0xFF8B5CF6).withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 30
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -pi / 2,
          progress * 2 * pi,
          false,
          arcPaint,
        );
      }
    } else if (style == AveroThemeStyle.neumorphic) {
      // Outer shadow ring
      final outerShadowPaint = Paint()
        ..color = const Color(0xFFA3B1C6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(center.dx + 4, center.dy + 4), radius, outerShadowPaint);

      final outerHighlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(center.dx - 4, center.dy - 4), radius, outerHighlightPaint);

      final bgPaint = Paint()
        ..color = const Color(0xFFE0E5EC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20;
      canvas.drawCircle(center, radius, bgPaint);

      if (seconds > 0) {
        final arcPaint = Paint()
          ..color = const Color(0xFF4A90E2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -pi / 2,
          progress * 2 * pi,
          false,
          arcPaint,
        );
      }
    } else {
      // Neo-brutalist
      final bgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, bgPaint);

      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      canvas.drawCircle(center, radius, borderPaint);

      final arcPaint = Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.fill;
      
      if (seconds > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -pi / 2,
          progress * 2 * pi,
          true,
          arcPaint,
        );
        canvas.drawCircle(center, radius, borderPaint);
        canvas.drawLine(center, Offset(center.dx, center.dy - radius), borderPaint);
        canvas.drawLine(
          center, 
          Offset(
            center.dx + radius * cos(-pi / 2 + progress * 2 * pi), 
            center.dy + radius * sin(-pi / 2 + progress * 2 * pi)
          ), 
          borderPaint
        );
      }
    }
  }

  @override
  bool shouldRepaint(ThemedTimerPainter oldDelegate) {
    return oldDelegate.seconds != seconds || oldDelegate.style != style;
  }
}

Widget buildThemedButton(
    String title,
    Color color,
    VoidCallback onTap, {
    double width = 140,
    Color textColor = Colors.black,
  }) {
    final style = appThemeNotifier.value;
    
    if (style == AveroThemeStyle.calming || style == AveroThemeStyle.appleLike) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color == Colors.white ? (style == AveroThemeStyle.calming ? const Color(0xFFE8EFEA) : const Color(0xFFF2F2F7)) : color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(style == AveroThemeStyle.appleLike ? 12 : 30),
          ),
          child: Center(
            child: Text(
              title,
              style: getThemeTextStyle(
                color: color == Colors.white ? (style == AveroThemeStyle.calming ? const Color(0xFF4A6B5D) : Colors.black) : Colors.white,
                fontWeight: style == AveroThemeStyle.appleLike ? FontWeight.w600 : FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    } else if (style == AveroThemeStyle.oled) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: getThemeTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    } else if (style == AveroThemeStyle.glassmorphic) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: width,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: color == Colors.white ? Colors.white.withOpacity(0.1) : color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: Center(
                child: Text(
                  title,
                  style: getThemeTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (style == AveroThemeStyle.neumorphic) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E5EC),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFA3B1C6),
                offset: Offset(4, 4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: getThemeTextStyle(
                color: color == Colors.white ? const Color(0xFF5A6B8C) : color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(6, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: getThemeTextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }
}
