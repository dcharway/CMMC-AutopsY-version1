import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/grc_store.dart';
import '../widgets/common.dart';

class AffirmationsScreen extends StatelessWidget {
  const AffirmationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GrcStore>();
    if (!store.hydrated) return const Center(child: CircularProgressIndicator());

    final gapControls = store.controls.where((c) {
      if (c.status == ControlStatus.implemented ||
          c.status == ControlStatus.notApplicable) return false;
      final hasPoam = c.poamId != null &&
          store.poams.any((p) => p.id == c.poamId && p.status != PoamStatus.completed);
      return !hasPoam;
    }).toList();
    final eligible = gapControls.isEmpty;
    final r = computeReadiness(store);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'Annual Affirmations',
              subtitle:
                  'Submit and track yearly attestations that all CMMC controls are met or covered by an approved POA&M.'),
          LayoutBuilder(builder: (ctx, c) {
            final list = Column(
              children: [
                for (final a in store.affirmations)
                  _AffirmationCard(item: a, eligible: eligible),
              ],
            );
            final eligibilityCard = Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Eligibility Check',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text('Readiness ${r.readiness}%'),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: r.readiness / 100,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFE5E7EB),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: eligible
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: eligible
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFF59E0B)),
                            ),
                            child: Row(children: [
                              Icon(
                                  eligible
                                      ? Icons.verified_outlined
                                      : Icons.warning_amber,
                                  color: eligible
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFB45309)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  eligible
                                      ? 'All controls implemented, N/A, or covered by an active POA&M. You can submit.'
                                      : '${gapControls.length} control(s) not implemented and missing a POA&M.',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ]),
                          ),
                          if (gapControls.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('GAP CONTROLS',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280))),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final c in gapControls.take(20))
                                      Text('${c.id} · ${c.status.label}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                              color: Color(0xFF475569))),
                                    if (gapControls.length > 20)
                                      Text('… and ${gapControls.length - 20} more',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
            if (c.maxWidth > 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: list),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: eligibilityCard),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [list, const SizedBox(height: 16), eligibilityCard],
            );
          }),
        ],
      ),
    );
  }
}

class _AffirmationCard extends StatefulWidget {
  const _AffirmationCard({required this.item, required this.eligible});
  final Affirmation item;
  final bool eligible;

  @override
  State<_AffirmationCard> createState() => _AffirmationCardState();
}

class _AffirmationCardState extends State<_AffirmationCard> {
  late TextEditingController _by;
  late TextEditingController _due;
  late TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _by = TextEditingController(text: widget.item.affirmedBy);
    _due = TextEditingController(text: widget.item.dueDate);
    _notes = TextEditingController(text: widget.item.notes);
  }

  @override
  void dispose() {
    _by.dispose();
    _due.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.item;
    final due = a.dueDate.isNotEmpty
        ? DateTime.parse(a.dueDate).difference(DateTime.now()).inDays
        : null;
    final isOverdue = a.submittedDate == null && due != null && due < 0;
    final isSoon =
        a.submittedDate == null && due != null && due >= 0 && due <= 90;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.id,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280))),
                    Text('${a.year} Annual Affirmation',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              TagChip(
                label: a.submittedDate != null
                    ? 'Submitted'
                    : isOverdue
                        ? 'Overdue'
                        : 'Pending',
                color: a.submittedDate != null
                    ? const Color(0xFF16A34A)
                    : isOverdue
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFF59E0B),
              ),
            ]),
            if (isOverdue)
              _alert(Icons.warning_amber,
                  'Affirmation is ${due!.abs()} days overdue. Submit immediately.',
                  const Color(0xFFDC2626)),
            if (isSoon && !isOverdue)
              _alert(Icons.event,
                  'Affirmation due in $due days.',
                  const Color(0xFFF59E0B)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _by,
                  decoration: const InputDecoration(
                      labelText: 'Affirmed by (Senior Official)',
                      border: OutlineInputBorder()),
                  onChanged: (v) => context
                      .read<GrcStore>()
                      .updateAffirmation(a.id, affirmedBy: v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _due,
                  decoration: const InputDecoration(
                      labelText: 'Due date (YYYY-MM-DD)',
                      border: OutlineInputBorder()),
                  onChanged: (v) => context
                      .read<GrcStore>()
                      .updateAffirmation(a.id, dueDate: v),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Notes', border: OutlineInputBorder()),
              onChanged: (v) => context
                  .read<GrcStore>()
                  .updateAffirmation(a.id, notes: v),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'I affirm that all 110 CMMC Level 2 (NIST SP 800-171) practices applicable to our system are currently implemented, or have an approved POA&M with remediation within 180 days. I attest the information provided is accurate as of the submission date.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (a.submittedDate != null) ...[
                  TagChip(
                      icon: Icons.verified_outlined,
                      label: 'Submitted ${a.submittedDate}',
                      color: const Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF59E0B)),
                    onPressed: () => context.read<GrcStore>().updateAffirmation(
                        a.id, submittedDate: '', status: 'Pending'),
                    child: const Text('Revoke'),
                  ),
                ] else
                  FilledButton.icon(
                    icon: const Icon(Icons.verified_outlined, size: 18),
                    label: const Text('Submit Affirmation'),
                    onPressed: !widget.eligible || _by.text.isEmpty
                        ? null
                        : () => context.read<GrcStore>().updateAffirmation(
                              a.id,
                              submittedDate: DateTime.now()
                                  .toIso8601String()
                                  .substring(0, 10),
                              status: 'Submitted',
                            ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _alert(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text, style: TextStyle(color: color, fontSize: 12))),
        ]),
      ),
    );
  }
}
