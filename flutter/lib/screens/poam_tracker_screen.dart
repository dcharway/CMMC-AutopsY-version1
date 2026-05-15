import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/grc_store.dart';
import '../widgets/common.dart';

class PoamTrackerScreen extends StatelessWidget {
  const PoamTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GrcStore>();
    if (!store.hydrated) return const Center(child: CircularProgressIndicator());

    final items = store.poams.toList();
    final open = items.where((p) => p.derivedStatus != PoamStatus.completed).length;
    final overdue =
        items.where((p) => p.derivedStatus == PoamStatus.overdue).length;
    final at180 = items
        .where((p) =>
            p.derivedStatus != PoamStatus.completed && p.ageDays > 150)
        .length;
    final high = items
        .where((p) =>
            p.riskLevel == RiskLevel.high &&
            p.derivedStatus != PoamStatus.completed)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'POA&M Tracker',
            subtitle: 'Plans of Action & Milestones — max 180-day remediation window',
            actions: [
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New POA&M'),
                onPressed: () => _openEditor(context, null),
              ),
            ],
          ),
          Wrap(spacing: 16, runSpacing: 16, children: [
            SizedBox(
                width: 180,
                child: KpiTile(
                    label: 'Open Items',
                    value: '$open',
                    color: const Color(0xFF2563EB))),
            SizedBox(
                width: 180,
                child: KpiTile(
                    label: 'Overdue',
                    value: '$overdue',
                    color: const Color(0xFFDC2626))),
            SizedBox(
                width: 220,
                child: KpiTile(
                    label: 'Near 180-day limit',
                    value: '$at180',
                    color: const Color(0xFFF59E0B))),
            SizedBox(
                width: 180,
                child: KpiTile(
                    label: 'High Risk',
                    value: '$high',
                    color: const Color(0xFF7E22CE))),
          ]),
          if (at180 > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                border: Border.all(color: const Color(0xFFFCD34D)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Color(0xFFB45309)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$at180 POA&M item(s) approaching the 180-day CMMC remediation limit. Escalate or complete to avoid disqualification.',
                      style: const TextStyle(color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.inbox_outlined,
                          size: 48, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 8),
                      const Text('No POA&Ms yet',
                          style: TextStyle(color: Color(0xFF6B7280))),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Create your first POA&M'),
                          onPressed: () => _openEditor(context, null)),
                    ],
                  ),
                ),
              ),
            )
          else
            _Kanban(items: items),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, PoamItem? p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PoamEditor(initial: p),
    );
  }
}

class _Kanban extends StatelessWidget {
  const _Kanban({required this.items});
  final List<PoamItem> items;

  @override
  Widget build(BuildContext context) {
    final columns = [
      PoamStatus.open,
      PoamStatus.inProgress,
      PoamStatus.completed,
      PoamStatus.overdue,
    ];
    return LayoutBuilder(builder: (ctx, c) {
      final wide = c.maxWidth > 900;
      final children = [
        for (final col in columns)
          SizedBox(
            width: wide ? (c.maxWidth - 48) / 4 : double.infinity,
            child: _KanbanColumn(
              status: col,
              items: items.where((p) => p.derivedStatus == col).toList(),
            ),
          ),
      ];
      return wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1) const SizedBox(width: 16),
                ],
              ],
            )
          : Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1) const SizedBox(height: 16),
                ],
              ],
            );
    });
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({required this.status, required this.items});
  final PoamStatus status;
  final List<PoamItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: status.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(status.label,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${items.length}',
                    style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('—',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9CA3AF))),
            ),
          for (final p in items) _PoamCard(item: p),
        ],
      ),
    );
  }
}

class _PoamCard extends StatelessWidget {
  const _PoamCard({required this.item});
  final PoamItem item;

  @override
  Widget build(BuildContext context) {
    final daysToDue = item.dueDate.isEmpty
        ? null
        : DateTime.parse(item.dueDate).difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: item.riskLevel.color, width: 4)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => _PoamEditor(initial: item),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item.id} · ${item.controlId}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF6B7280))),
              const SizedBox(height: 4),
              Text(
                  item.finding.isEmpty ? '(no finding)' : item.finding,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Wrap(spacing: 4, runSpacing: 4, children: [
                TagChip(
                    label: item.riskLevel.label,
                    color: item.riskLevel.color,
                    dense: true),
                if (daysToDue != null)
                  TagChip(
                      icon: Icons.event,
                      label: daysToDue < 0
                          ? '${-daysToDue}d overdue'
                          : '${daysToDue}d left',
                      color: daysToDue < 0
                          ? const Color(0xFFDC2626)
                          : (daysToDue < 14
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF6B7280)),
                      dense: true),
                if (item.ageDays > 150 &&
                    item.derivedStatus != PoamStatus.completed)
                  const TagChip(
                      icon: Icons.warning_amber,
                      label: '180d',
                      color: Color(0xFFDC2626),
                      dense: true),
              ]),
              if (item.assignedTo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('@${item.assignedTo}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280))),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PoamEditor extends StatefulWidget {
  const _PoamEditor({this.initial});
  final PoamItem? initial;

  @override
  State<_PoamEditor> createState() => _PoamEditorState();
}

class _PoamEditorState extends State<_PoamEditor> {
  String? _controlId;
  late TextEditingController _finding;
  late TextEditingController _plan;
  late TextEditingController _owner;
  late TextEditingController _due;
  RiskLevel _risk = RiskLevel.medium;
  PoamStatus _status = PoamStatus.open;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _controlId = i?.controlId;
    _finding = TextEditingController(text: i?.finding ?? '');
    _plan = TextEditingController(text: i?.remediationPlan ?? '');
    _owner = TextEditingController(text: i?.assignedTo ?? '');
    _due = TextEditingController(text: i?.dueDate ?? '');
    _risk = i?.riskLevel ?? RiskLevel.medium;
    _status = i?.status ?? PoamStatus.open;
  }

  @override
  void dispose() {
    _finding.dispose();
    _plan.dispose();
    _owner.dispose();
    _due.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<GrcStore>();
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                    widget.initial == null
                        ? 'New POA&M'
                        : 'Edit ${widget.initial!.id}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop()),
            ]),
            if (widget.initial != null) ...[
              const SizedBox(height: 8),
              _AgeMeter(ageDays: widget.initial!.ageDays),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _controlId,
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: 'Related control', border: OutlineInputBorder()),
              items: [
                for (final c in store.controls)
                  DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.id} — ${c.practice}',
                          overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => setState(() => _controlId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _finding,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Finding', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<RiskLevel>(
                  value: _risk,
                  decoration: const InputDecoration(
                      labelText: 'Risk', border: OutlineInputBorder()),
                  items: [
                    for (final r in RiskLevel.values)
                      DropdownMenuItem(value: r, child: Text(r.label)),
                  ],
                  onChanged: (v) => setState(() => _risk = v ?? _risk),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<PoamStatus>(
                  value: _status,
                  decoration: const InputDecoration(
                      labelText: 'Status', border: OutlineInputBorder()),
                  items: [
                    for (final s in PoamStatus.values)
                      DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: _plan,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Remediation plan', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _owner,
                  decoration: const InputDecoration(
                      labelText: 'Owner', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _due,
                  decoration: const InputDecoration(
                      labelText: 'Due (YYYY-MM-DD)',
                      border: OutlineInputBorder()),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.initial != null)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626)),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    onPressed: () {
                      store.removePoam(widget.initial!.id);
                      Navigator.of(context).pop();
                    },
                  )
                else
                  const SizedBox.shrink(),
                Row(children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _controlId == null ||
                            _finding.text.trim().isEmpty
                        ? null
                        : () {
                            if (widget.initial == null) {
                              store.addPoam(
                                controlId: _controlId!,
                                finding: _finding.text,
                                riskLevel: _risk,
                                remediationPlan: _plan.text,
                                dueDate: _due.text,
                                status: _status,
                                assignedTo: _owner.text,
                              );
                            } else {
                              store.updatePoam(widget.initial!.id,
                                  finding: _finding.text,
                                  riskLevel: _risk,
                                  remediationPlan: _plan.text,
                                  dueDate: _due.text,
                                  status: _status,
                                  assignedTo: _owner.text);
                            }
                            Navigator.of(context).pop();
                          },
                    child: const Text('Save'),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AgeMeter extends StatelessWidget {
  const _AgeMeter({required this.ageDays});
  final int ageDays;
  @override
  Widget build(BuildContext context) {
    final pct = (ageDays / 180).clamp(0.0, 1.0);
    final color = ageDays > 180
        ? const Color(0xFFDC2626)
        : ageDays > 150
            ? const Color(0xFFF59E0B)
            : const Color(0xFF2563EB);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Expanded(
              child: Text('180-day remediation window',
                  style: TextStyle(fontSize: 11))),
          Text('Day $ageDays / 180',
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            valueColor: AlwaysStoppedAnimation(color),
            backgroundColor: const Color(0xFFE5E7EB),
          ),
        ),
      ],
    );
  }
}
