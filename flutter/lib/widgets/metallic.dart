import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/metallic_theme.dart';

/// Headline text rendered with the brushed-gold gradient (ShaderMask).
class GoldText extends StatelessWidget {
  const GoldText(this.text,
      {super.key, this.style, this.textAlign, this.maxLines});
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (b) => MT.goldGradient.createShader(b),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      ),
    );
  }
}

/// Circular progress ring drawn with a gold gradient and a soft track,
/// matching the Figma "Total Risk Score" hero.
class GoldProgressRing extends StatelessWidget {
  const GoldProgressRing({
    super.key,
    required this.value, // 0..1
    required this.size,
    this.strokeWidth = 12,
    this.child,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(value: value.clamp(0.0, 1.0), stroke: strokeWidth),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.stroke});
  final double value;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - stroke / 2;

    final track = Paint()
      ..color = MT.stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (value <= 0) return;

    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final shader = const SweepGradient(
      colors: [MT.goldBase, MT.goldLight, MT.goldDark, MT.goldBase],
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
    ).createShader(arcRect);

    final fg = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.stroke != stroke;
}

/// Filled CTA with gold gradient + haptic feedback (a-la "premium tactile feel").
class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (icon != null) {
      children.addAll([
        Icon(icon, size: 18, color: MT.ink),
        const SizedBox(width: 8),
      ]);
    }
    children.add(
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: const TextStyle(
              color: MT.ink, fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
    final inner = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          gradient: MT.goldGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: MT.goldBase.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: inner,
      ),
    );
  }
}

/// Section header used across Material 3 screens — small all-caps label
/// with a gold underscore.
class GoldEyebrow extends StatelessWidget {
  const GoldEyebrow(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 18,
        height: 2,
        decoration: BoxDecoration(
          gradient: MT.goldGradient,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        text.toUpperCase(),
        style: const TextStyle(
            color: MT.goldLight,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4),
      ),
    ]);
  }
}

/// Reusable dark card with optional gold border accent.
class DarkCard extends StatelessWidget {
  const DarkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gold = false,
    this.onTap,
  });
  final Widget child;
  final EdgeInsets padding;
  final bool gold;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: gold ? MT.glassCard() : MT.card(),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: card,
    );
  }
}
