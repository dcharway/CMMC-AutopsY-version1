import 'package:flutter/material.dart';

/// Mobile-first page padding. Pinches the gutters on small screens so
/// content tables / cards have more breathing room.
EdgeInsets pagePadding(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  return EdgeInsets.symmetric(
    horizontal: w < 600 ? 12 : 24,
    vertical: w < 600 ? 16 : 24,
  );
}

/// Returns true when the widget is rendering on a phone-class viewport.
bool isCompact(BuildContext context) =>
    MediaQuery.of(context).size.width < 600;

/// Render two form fields side-by-side on tablet/desktop, stacked on mobile.
class TwoColumn extends StatelessWidget {
  const TwoColumn({super.key, required this.left, required this.right, this.gap = 12});
  final Widget left;
  final Widget right;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      if (c.maxWidth < 480) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, SizedBox(height: gap), right],
        );
      }
      return Row(
        children: [
          Expanded(child: left),
          SizedBox(width: gap),
          Expanded(child: right),
        ],
      );
    });
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle, this.actions});
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final compact = isCompact(context);
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              fontSize: compact ? 22 : 26,
              fontWeight: FontWeight.w700,
            )),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              style: const TextStyle(color: Color(0xFF6B7280))),
        ],
      ],
    );
    if (actions == null || actions!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: header,
      );
    }
    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            const SizedBox(height: 12),
            Row(children: [for (final a in actions!) Expanded(child: a)]),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: header),
          ...actions!,
        ],
      ),
    );
  }
}

class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    this.color = const Color(0xFF2563EB),
    this.helper,
  });
  final String label;
  final String value;
  final Color color;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700, color: color)),
            if (helper != null) ...[
              const SizedBox(height: 4),
              Text(helper!,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ],
        ),
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dense = false,
  });
  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final padding = dense
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
