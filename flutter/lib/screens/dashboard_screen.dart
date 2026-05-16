import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/cmmc_controls.dart';
import '../data/models.dart';
import '../state/grc_store.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GrcStore>();
    if (!store.hydrated) {
      return const Center(child: CircularProgressIndicator());
    }
    final r = computeReadiness(store);

    return SingleChildScrollView(
      padding: pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'CMMC Level 2 Executive Dashboard',
            subtitle: 'Stoplight view of controls, evidence, POA&Ms, and readiness',
          ),
          _KpiRow(r: r),
          const SizedBox(height: 24),
          _ReadinessCard(r: r, store: store),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (ctx, c) {
            final wide = c.maxWidth > 800;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _StatusPieCard(store: store)),
                  const SizedBox(width: 16),
                  Expanded(child: _FamilyHeatmap(store: store)),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusPieCard(store: store),
                const SizedBox(height: 16),
                _FamilyHeatmap(store: store),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.r});
  final ReadinessScore r;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      KpiTile(
          label: 'SPRS Score',
          value: '${r.sprs} / 110',
          color: const Color(0xFF16A34A),
          helper: 'Readiness ${r.readiness}%'),
      KpiTile(
          label: 'Controls Met',
          value: '${r.implemented} / ${r.total}',
          color: const Color(0xFF2563EB)),
      KpiTile(
          label: 'Open POA&Ms',
          value: '${r.openPoams}',
          color: const Color(0xFFF59E0B),
          helper: r.overduePoams > 0 ? '${r.overduePoams} overdue' : null),
      KpiTile(
          label: 'Evidence Issues',
          value: '${r.expiringEvidence}',
          color: const Color(0xFFDC2626),
          helper: 'Expiring or expired'),
    ];
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth > 900 ? 4 : (c.maxWidth > 600 ? 2 : 1);
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: tiles
            .map((t) => SizedBox(
                width: (c.maxWidth - (cols - 1) * 16) / cols, child: t))
            .toList(),
      );
    });
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.r, required this.store});
  final ReadinessScore r;
  final GrcStore store;

  @override
  Widget build(BuildContext context) {
    final color = r.readiness >= 90
        ? const Color(0xFF16A34A)
        : r.readiness >= 70
            ? const Color(0xFFF59E0B)
            : const Color(0xFFDC2626);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assessment Readiness',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: r.readiness / 100,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${r.readiness}%',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _statLine('Implemented', '${r.implemented}/${r.total}'),
                _statLine('In Progress', '${r.inProgress}'),
                _statLine('Not Started', '${r.notStarted}'),
                _statLine('Evidence coverage', '${r.evidenceCoverage}%'),
                _statLine('Pre-assessment checklist', '${r.checklistPct}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statLine(String label, String value) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$label  ', style: const TextStyle(color: Color(0xFF6B7280))),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
  }
}

class _StatusPieCard extends StatelessWidget {
  const _StatusPieCard({required this.store});
  final GrcStore store;

  @override
  Widget build(BuildContext context) {
    final counts = {for (var s in ControlStatus.values) s: 0};
    for (final c in store.controls) {
      counts[c.status] = (counts[c.status] ?? 0) + 1;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Control Status Distribution',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    for (final entry in counts.entries)
                      if (entry.value > 0)
                        PieChartSectionData(
                          value: entry.value.toDouble(),
                          color: entry.key.color,
                          title: '${entry.value}',
                          radius: 60,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                for (final entry in counts.entries)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: entry.key.color,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 4),
                    Text('${entry.key.label} (${entry.value})',
                        style: const TextStyle(fontSize: 12)),
                  ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyHeatmap extends StatelessWidget {
  const _FamilyHeatmap({required this.store});
  final GrcStore store;

  @override
  Widget build(BuildContext context) {
    final rows = controlFamilies.map((f) {
      final fc = store.controls.where((c) => c.familyCode == f.code).toList();
      final impl = fc
          .where((c) =>
              c.status == ControlStatus.implemented ||
              c.status == ControlStatus.notApplicable)
          .length;
      final pct = fc.isEmpty ? 0 : ((impl / fc.length) * 100).round();
      Color color = const Color(0xFF16A34A);
      if (pct < 70) color = const Color(0xFFDC2626);
      else if (pct < 100) color = const Color(0xFFF59E0B);
      return (f, impl, fc.length, pct, color);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Control Family Heatmap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                        width: 40,
                        child: Text(row.$1.code,
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: row.$4 / 100,
                          minHeight: 16,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation(row.$5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                        width: 70,
                        child: Text('${row.$2}/${row.$3}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280)))),
                    SizedBox(
                        width: 40,
                        child: Text('${row.$4}%',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: row.$5))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
