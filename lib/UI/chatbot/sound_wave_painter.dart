import 'package:flutter/material.dart';
import 'dart:math';

class SoundWavePainter extends CustomPainter {
  final double soundLevel;
  final List<double> _randomFactors = List.generate(12, (index) => Random().nextDouble());

  SoundWavePainter(this.soundLevel);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFDDDCDC)
      ..style = PaintingStyle.fill;

    final barCount = 12;
    final barWidth = 8.0;
    final spacing = 4.0;
    final maxBarHeight = size.height;

    for (int i = 0; i < barCount; i++) {
      // 랜덤한 높이 변동을 추가하여 자연스럽게 변하도록 설정
      final randomFactor = _randomFactors[i];
      final barHeight = max((soundLevel * maxBarHeight * randomFactor) / 2, 5).toDouble(); // 🔥 여기 수정
      final x = (size.width - (barCount * (barWidth + spacing))) / 2 + i * (barWidth + spacing);
      final y = (maxBarHeight - barHeight) / 2;

      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
