import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CustomContainerShapeBorder extends CustomPainter {
  
  final Color color;

  CustomContainerShapeBorder(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = this.color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var path = Path();
    path.moveTo(10, 135);
    path.arcToPoint(const Offset(1.0, 125.0), radius: const Radius.circular(12.0));
    path.arcToPoint(const Offset(1.0, 55.0));
    path.arcToPoint(const Offset(12.0, 35.0), radius: const Radius.circular(24.0), clockwise: true);
    path.arcToPoint(const Offset(14.0, 25.0), radius: const Radius.circular(16.0), clockwise: false);
    path.arcToPoint(const Offset(14.0, 11.0), radius: const Radius.circular(16.0), clockwise: true);
    path.lineTo(36.0, 11.0);
    path.moveTo(40, 135);
    path.lineTo(10, 135);
    path.moveTo(40, 135);
    path.arcToPoint(const Offset(49.0, 125.0), radius: const Radius.circular(12.0), clockwise: false);
    path.arcToPoint(const Offset(49.0, 55.0), clockwise: false);
    path.arcToPoint(const Offset(38.0, 35.0), radius: const Radius.circular(24.0), clockwise: false);
    path.arcToPoint(const Offset(36.0, 25.0), radius: const Radius.circular(16.0), clockwise: true);
    path.arcToPoint(const Offset(36.0, 11.0), radius: const Radius.circular(16.0), clockwise: false);

    var mNewPath = Path();

    mNewPath.moveTo(40, 50);
    mNewPath.lineTo(40, 60);

    canvas.drawPath(mNewPath, Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);

    canvas.drawPath(path, paint);

    var mNewShadowPath = Path();
    mNewShadowPath.moveTo(40, 75);
    mNewShadowPath.lineTo(40, 115);

    canvas.drawPath(mNewShadowPath, Paint()
      ..color = this.color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        const Offset(40, 75),
        const Offset(40, 115),
        [
          Colors.white,
          Colors.white24,
        ],
      ));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}