import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/grc_store.dart';
import '../widgets/common.dart';

const _phaseDescriptions = {
  AssessmentPhase.preAssessment:
      'Establish scope, document the system boundary, draft the SSP, and reach internal readiness.',
  AssessmentPhase.conformity:
      'C3PAO performs the formal assessment of all 110 practices against NIST SP 800-171A.',
  AssessmentPhase.reporting:
      'Receive findings, draft POA&Ms for any gaps (≤180-day remediation), and finalize the report.',
  AssessmentPhase.closeout:
      'Submit SPRS score, enter annual affirmation, and archive the issued certificate.',
};

class AssessmentWorkflowScreen extends StatelessWidget {
  const AssessmentWorkflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GrcStore>();
    if (!store.hydrated) return const Center(child: CircularProgressIndicator());

    final r = computeReadiness(store);
    final phaseStats = AssessmentPhase.values.map((p) {
      final items = store.checklist.where((c) => c.phase == p).toList();
      final done = items.where((c) => c.done).length;
      return (p, items, done);
    }).toList();
    final firstPhaseComplete =
        phaseStats[0].$3 == phaseStats[0].$2.length && phaseStats[0].$2.isNotEmpty;
    final readyForAudit = r.readiness >= 90 && firstPhaseComplete;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'Assessment Workflow',
              subtitle: 'CMMC Assessment Process (CAP) — 4-phase readiness tracker'),
          LayoutBuilder(builder: (ctx, c) {
            final wide = c.maxWidth > 900;
            return Flex(
              direction: wide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: wide ? 2 : 0,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          for (var i = 0; i < phaseStats.length; i++)
                            _PhaseSection(
                              phase: phaseStats[i].$1,
                              items: phaseStats[i].$2,
                              done: phaseStats[i].$3,
                              index: i,
                              isLast: i == phaseStats.length - 1,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: wide ? 16 : 0, height: wide ? 0 : 16),
                Expanded(
                  flex: wide ? 1 : 0,
                  child: Column(children: [
                    _ReadinessPanel(r: r),
                    const SizedBox(height: 12),
                    _AuditGate(ready: readyForAudit),
                  ]),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _PhaseSection extends StatelessWidget {
  const _PhaseSection({
    required this.phase,
    required this.items,
    required this.done,
    required this.index,
    required this.isLast,
  });
  final AssessmentPhase phase;
  final List<ChecklistItem> items;
  final int done;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final complete = done == items.length && items.isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: complete
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF2563EB),
              child: Text('${index + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(phase.label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: complete
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$done / ${items.length}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: complete
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF374151))),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 6, bottom: 8),
            child: Text(_phaseDescriptions[phase] ?? '',
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ),
          for (final item in items)
            _ChecklistRow(item: item),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item});
  final ChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final store = context.read<GrcStore>();
    return Container(
      margin: const EdgeInsets.only(left: 40, bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: item.done ? const Color(0xFFF0FDF4) : Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.done,
            onChanged: (_) => store.toggleChecklist(item.id),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    decoration:
                        item.done ? TextDecoration.lineThrough : null,
                    color: item.done
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF1F2937),
                  ),
                ),
                if (!item.done) ...[
                  const SizedBox(height: 4),
                  TextField(
                    controller:
                        TextEditingController(text: item.blocker),
                    onSubmitted: (v) => store.setBlocker(item.id, v),
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: UnderlineInputBorder(),
                      hintText: 'Blocker (optional, press enter to save)',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessPanel extends StatelessWidget {
  const _ReadinessPanel({required this.r});
  final ReadinessScore r;
  @override
  Widget build(BuildContext context) {
    final color = r.readiness >= 90
        ? const Color(0xFF16A34A)
        : r.readiness >= 70
            ? const Color(0xFFF59E0B)
            : const Color(0xFFDC2626);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('READINESS SCORE',
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: Color(0xFF6B7280))),
            const SizedBox(height: 4),
            Text('${r.readiness}%',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: r.readiness / 100,
                minHeight: 8,
                valueColor: AlwaysStoppedAnimation(color),
                backgroundColor: const Color(0xFFE5E7EB),
              ),
            ),
            const SizedBox(height: 12),
            _row('Controls implemented', '${r.implemented} / ${r.total}'),
            _row('Open POA&Ms', '${r.openPoams}'),
            _row('Overdue POA&Ms', '${r.overduePoams}'),
            _row('Evidence coverage', '${r.evidenceCoverage}%'),
            _row('Pre-assessment checklist', '${r.checklistPct}%'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          Text(v,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AuditGate extends StatelessWidget {
  const _AuditGate({required this.ready});
  final bool ready;
  @override
  Widget build(BuildContext context) {
    final bg =
        ready ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB);
    final border =
        ready ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ready ? Icons.lock_open : Icons.lock_outline,
                  color: border),
              const SizedBox(width: 8),
              Text(ready ? 'Ready for C3PAO Audit' : 'Not Audit-Ready',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ready
                ? 'All Pre-Assessment criteria are met and readiness ≥90%. You may schedule the formal assessment.'
                : 'Complete Pre-Assessment checklist items and reach ≥90% readiness before marking ready for audit.',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: ready ? () {} : null,
            child: Text(ready ? 'Mark Ready for Audit' : 'Locked'),
          ),
        ],
      ),
    );
  }
}
