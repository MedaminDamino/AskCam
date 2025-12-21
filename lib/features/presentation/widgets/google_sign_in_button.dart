import 'dart:math' as math;

import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_radius.dart';
import 'package:askcam/core/ui/app_spacing.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.xxl + AppSpacing.lg,
      child: OutlinedButton(
        onPressed: ButtonFeedbackService.wrap(
          context,
          isLoading ? null : onPressed,
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.onSurface,
          side: BorderSide(color: colors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.md),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: colors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GoogleLogo(
                    size: 20,
                    colors: [
                      colors.primary,
                      colors.secondary,
                      colors.tertiary,
                      colors.primaryContainer,
                    ],
                  ),
                  SizedBox(width: AppSpacing.md),
                  Text(
                    context.l10n.googleSignInButton,
                    style: textTheme.labelLarge,
                  ),
                ],
              ),
      ),
    );
  }
}

class GoogleLogo extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const GoogleLogo({
    super.key,
    this.size = 18,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GoogleLogoPainter(colors),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  final List<Color> colors;

  _GoogleLogoPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = colors[0];
    canvas.drawArc(rect, -math.pi / 4, math.pi / 2, false, paint);

    paint.color = colors[1];
    canvas.drawArc(rect, math.pi / 4, math.pi / 2, false, paint);

    paint.color = colors[2];
    canvas.drawArc(rect, 3 * math.pi / 4, math.pi / 2, false, paint);

    paint.color = colors[3];
    canvas.drawArc(rect, 5 * math.pi / 4, math.pi / 2, false, paint);

    final barPaint = Paint()..color = colors[0];
    final barHeight = stroke * 0.9;
    final barWidth = radius;
    final barRect = Rect.fromLTWH(
      center.dx,
      center.dy - barHeight / 2,
      barWidth,
      barHeight,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
