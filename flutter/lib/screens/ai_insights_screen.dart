import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/cmmc_controls.dart';
import '../data/models.dart';
import '../state/grc_store.dart';
import '../widgets/common.dart';

enum _Priority { high, medium, low }

class _Insight {
  _Insight(this.title, this.description,
      {required this.priority, this.action, this.impact = ''});
  final String title;
  final String description;
  final _Priority priority;
  final String? action;
  final String impact;

  Color get color => switch (priority) {
        _Priority.high => const Color(0xFFDC2626),
        _Priority.medium => const Color(0xFFF59E0B),
        _Priority.low => const Color(0xFF16A34A),
      };
}

class AiInsightsScreen extends StatelessWidget {
  const AiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GrcStore>();
    if (!store.hydrated) return const Center(child: CircularProgressIndicator());

    final r = computeReadiness(store);
    final insights = _generate(store);
    final high = insights.where((i) => i.priority == _Priority.high).length;
    final med = insights.where((i) => i.priority == _Priority.medium).length;

    return SingleChildScrollView(
      padding: pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'AI-Powered Insights & Alerts',
              subtitle:
                  'Rule-based recommendations derived from your live registry, evidence, and POA&Ms'),
          Wrap(spacing: 16, runSpacing: 16, children: [
            SizedBox(
                width: 200,
                child: KpiTile(
                    label: 'High Priority',
                    value: '$high',
                    color: const Color(0xFFDC2626),
                    helper: 'Require immediate action')),
            SizedBox(
                width: 200,
                child: KpiTile(
                    label: 'Medium Priority',
                    value: '$med',
                    color: const Color(0xFFF59E0B),
                    helper: 'Address soon')),
            SizedBox(
                width: 200,
                child: KpiTile(
                    label: 'Readiness',
                    value: '${r.readiness}%',
                    color: r.readiness >= 90
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFF59E0B),
                    helper: 'Assessment ready at 90%')),
          ]),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Insights (${insights.length})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (insights.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                            'No active insights — everything looks healthy. Add controls and evidence to surface AI-generated recommendations.',
                            style: TextStyle(color: Color(0xFF6B7280))),
                      ),
                    ),
                  for (final i in insights) _InsightCard(insight: i),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_Insight> _generate(GrcStore store) {
    final out = <_Insight>[];

    for (final p in store.poams) {
      if (p.derivedStatus != PoamStatus.completed && p.ageDays > 150) {
        out.add(_Insight(
          'POA&M approaching 180-day limit',
          '${p.id} (control ${p.controlId}) has been open for ${p.ageDays} days. CMMC requires remediation within 180 days.',
          priority: _Priority.high,
          action: 'Open POA&M Tracker',
          impact: 'Assessment blocker',
        ));
      }
    }

    final overdue = store.poams
        .where((p) => p.derivedStatus == PoamStatus.overdue)
        .toList();
    if (overdue.isNotEmpty) {
      out.add(_Insight(
        '${overdue.length} overdue POA&M${overdue.length != 1 ? "s" : ""}',
        overdue.take(3).map((p) => '${p.id} (${p.controlId})').join(', '),
        priority: _Priority.high,
        impact: 'Timeline risk',
      ));
    }

    final expired = store.evidence
        .where((e) => e.status == EvidenceStatus.expired)
        .length;
    if (expired > 0) {
      out.add(_Insight(
        '$expired expired evidence artifact${expired != 1 ? "s" : ""}',
        'Expired evidence will fail control validation. Refresh and re-upload before the assessment.',
        priority: _Priority.high,
        action: 'Open Evidence Repository',
        impact: 'Control validation failure',
      ));
    }
    final expiring = store.evidence
        .where((e) => e.status == EvidenceStatus.expiringSoon)
        .length;
    if (expiring > 0) {
      out.add(_Insight(
        '$expiring evidence file${expiring != 1 ? "s" : ""} expiring within 30 days',
        'Refresh before the assessment to avoid scrambling.',
        priority: _Priority.medium,
        action: 'Upload updated evidence',
      ));
    }

    final misnamed = store.evidence.where((e) => !e.validNaming).length;
    if (misnamed > 0) {
      out.add(_Insight(
        'Evidence naming convention variance',
        '$misnamed evidence file${misnamed != 1 ? "s" : ""} do not follow the ControlID_Description_YYYY-MM-DD pattern.',
        priority: _Priority.low,
        action: 'Rename to standard format',
      ));
    }

    final noEvidence = store.controls
        .where((c) =>
            c.status == ControlStatus.implemented && c.evidenceIds.isEmpty)
        .length;
    if (noEvidence > 0) {
      out.add(_Insight(
        '$noEvidence implemented control${noEvidence != 1 ? "s" : ""} missing evidence',
        'A control marked Implemented requires audit-proof evidence. Upload at least one artifact per implemented control.',
        priority: _Priority.medium,
        action: 'Upload evidence',
      ));
    }

    for (final f in controlFamilies) {
      final fc =
          store.controls.where((c) => c.familyCode == f.code).toList();
      if (fc.isEmpty) continue;
      final impl = fc
          .where((c) =>
              c.status == ControlStatus.implemented ||
              c.status == ControlStatus.notApplicable)
          .length;
      final pct = (impl / fc.length) * 100;
      if (pct < 70) {
        out.add(_Insight(
          '${f.code} – ${f.name} family at ${pct.round()}%',
          'Only $impl of ${fc.length} controls are implemented. Prioritize this family to lift readiness.',
          priority: pct < 40 ? _Priority.high : _Priority.medium,
          action: 'Focus on ${f.code}',
        ));
      } else if (pct == 100 && fc.length > 1) {
        out.add(_Insight(
          '${f.name} family fully implemented',
          'All ${fc.length} controls in ${f.code} are implemented or N/A.',
          priority: _Priority.low,
          impact: 'Momentum',
        ));
      }
    }

    for (final a in store.affirmations) {
      if (a.submittedDate != null) continue;
      final due = DateTime.parse(a.dueDate).difference(DateTime.now()).inDays;
      if (due <= 90) {
        out.add(_Insight(
          due < 0
              ? 'Annual affirmation ${due.abs()} days overdue'
              : 'Annual affirmation due in $due days',
          '${a.year} CMMC affirmation has not been submitted yet.',
          priority: due < 0 || due <= 30 ? _Priority.high : _Priority.medium,
          action: 'Submit affirmation',
        ));
      }
    }

    return out;
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});
  final _Insight insight;
  @override
  Widget build(BuildContext context) {
    final bg = insight.color.withOpacity(0.06);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: BorderSide(color: insight.color, width: 4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(insight.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),
            TagChip(
                label: insight.priority.name.toUpperCase(),
                color: insight.color,
                dense: true),
          ]),
          const SizedBox(height: 4),
          Text(insight.description,
              style:
                  const TextStyle(fontSize: 13, color: Color(0xFF475569))),
          if (insight.impact.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Impact: ${insight.impact}',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF6B7280))),
          ],
        ],
      ),
    );
  }
}
