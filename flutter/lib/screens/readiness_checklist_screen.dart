import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/auth.dart';
import '../state/grc_store.dart';
import '../widgets/common.dart';

/// Readiness Checklist Portal — the 12-row CMMC Pre-Assessment deliverables
/// view. Each item has its own upload slot, status dropdown, due date, owner,
/// and notes; the bar across the top summarises overall progress.
class ReadinessChecklistScreen extends StatefulWidget {
  const ReadinessChecklistScreen({super.key});

  @override
  State<ReadinessChecklistScreen> createState() =>
      _ReadinessChecklistScreenState();
}

class _ReadinessChecklistScreenState extends State<ReadinessChecklistScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GrcStore>();
    if (!store.hydrated) {
      return const Center(child: CircularProgressIndicator());
    }
    final items = store.readiness;
    final filtered = _filter == 'All'
        ? items
        : items.where((i) => i.status.label == _filter).toList();

    final submitted = items
        .where((i) =>
            i.status == ReadinessStatus.submitted ||
            i.status == ReadinessStatus.accepted)
        .length;
    final accepted =
        items.where((i) => i.status == ReadinessStatus.accepted).length;
    final inProgress =
        items.where((i) => i.status == ReadinessStatus.inProgress).length;
    final rejected =
        items.where((i) => i.status == ReadinessStatus.rejected).length;
    final progress = items.isEmpty ? 0.0 : submitted / items.length;

    return SingleChildScrollView(
      padding: pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Readiness Checklist Portal',
            subtitle:
                'Pre-Assessment deliverables your organization hands to the C3PAO',
          ),
          _ProgressCard(
            total: items.length,
            submitted: submitted,
            inProgress: inProgress,
            accepted: accepted,
            rejected: rejected,
            progress: progress,
          ),
          const SizedBox(height: 16),
          _FilterBar(
            value: _filter,
            onChanged: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 12),
          Text(
            'Showing ${filtered.length} of ${items.length} deliverables',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 8),
          for (final item in filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReadinessRow(item: item),
            ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.total,
    required this.submitted,
    required this.inProgress,
    required this.accepted,
    required this.rejected,
    required this.progress,
  });
  final int total;
  final int submitted;
  final int inProgress;
  final int accepted;
  final int rejected;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${(progress * 100).round()}%',
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('$submitted / $total deliverables submitted',
                      style: const TextStyle(color: Color(0xFF6B7280))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation(progress >= 1
                    ? const Color(0xFF16A34A)
                    : progress >= 0.5
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFF59E0B)),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(spacing: 16, runSpacing: 8, children: [
              _legend('In Progress', inProgress, ReadinessStatus.inProgress.color),
              _legend('Submitted', submitted, ReadinessStatus.submitted.color),
              _legend('Accepted', accepted, ReadinessStatus.accepted.color),
              _legend('Rejected', rejected, ReadinessStatus.rejected.color),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _legend(String label, int count, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text('$label  ',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      Text('$count',
          style:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = ['All', ...ReadinessStatus.values.map((s) => s.label)];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final o in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(o),
                selected: value == o,
                onSelected: (_) => onChanged(o),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReadinessRow extends StatefulWidget {
  const _ReadinessRow({required this.item});
  final ReadinessChecklistItem item;

  @override
  State<_ReadinessRow> createState() => _ReadinessRowState();
}

class _ReadinessRowState extends State<_ReadinessRow> {
  bool _busy = false;
  late TextEditingController _providedBy;
  late TextEditingController _due;
  late TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _providedBy = TextEditingController(text: widget.item.providedBy);
    _due = TextEditingController(text: widget.item.dueDate);
    _notes = TextEditingController(text: widget.item.notes);
  }

  @override
  void didUpdateWidget(covariant _ReadinessRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.providedBy != _providedBy.text) {
      _providedBy.text = widget.item.providedBy;
    }
    if (widget.item.dueDate != _due.text) _due.text = widget.item.dueDate;
    if (widget.item.notes != _notes.text) _notes.text = widget.item.notes;
  }

  @override
  void dispose() {
    _providedBy.dispose();
    _due.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    setState(() => _busy = true);
    try {
      final picked = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (picked == null || picked.files.isEmpty) return;
      if (!mounted) return;
      final store = context.read<GrcStore>();
      final uploader = context.read<AuthState>().displayName ?? '';
      for (final f in picked.files) {
        store.attachReadinessFile(
          itemId: widget.item.id,
          fileName: f.name,
          uploadedBy: uploader,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
              '${picked.files.length} file(s) uploaded to ${widget.item.id} · ${widget.item.artifact}'),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  int? _daysUntilDue() {
    if (widget.item.dueDate.isEmpty) return null;
    try {
      return DateTime.parse(widget.item.dueDate)
          .difference(DateTime.now())
          .inDays;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final store = context.read<GrcStore>();
    final days = _daysUntilDue();
    final isOverdue = days != null &&
        days < 0 &&
        item.status != ReadinessStatus.accepted &&
        item.status != ReadinessStatus.submitted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.status.color.withOpacity(0.12),
                    border: Border.all(
                        color: item.status.color.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item.id,
                      style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: item.status.color)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.artifact,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Wrap(spacing: 8, runSpacing: 4, children: [
                        TagChip(
                            icon: Icons.flag_outlined,
                            label: item.capPhase,
                            color: const Color(0xFF7C3AED),
                            dense: true),
                        TagChip(
                            icon: Icons.description_outlined,
                            label: item.requiredFormat,
                            color: const Color(0xFF2563EB),
                            dense: true),
                        if (item.relatedControls.isNotEmpty)
                          TagChip(
                              icon: Icons.shield_outlined,
                              label: item.relatedControls.join(', '),
                              color: const Color(0xFF0891B2),
                              dense: true),
                      ]),
                    ],
                  ),
                ),
                _StatusMenu(
                  status: item.status,
                  onChanged: (s) =>
                      store.updateReadinessItem(item.id, status: s),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TwoColumn(
              left: TextField(
                controller: _providedBy,
                decoration: const InputDecoration(
                    labelText: 'Provided by',
                    isDense: true,
                    border: OutlineInputBorder()),
                onChanged: (v) =>
                    store.updateReadinessItem(item.id, providedBy: v),
              ),
              right: TextField(
                controller: _due,
                decoration: InputDecoration(
                  labelText: 'Due date (YYYY-MM-DD)',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  helperText: days == null
                      ? null
                      : days < 0
                          ? '${-days}d overdue'
                          : days < 7
                              ? '$days days left'
                              : null,
                  helperStyle: TextStyle(
                    color: isOverdue
                        ? const Color(0xFFDC2626)
                        : (days != null && days < 7
                            ? const Color(0xFFF59E0B)
                            : null),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onChanged: (v) =>
                    store.updateReadinessItem(item.id, dueDate: v),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => store.updateReadinessItem(item.id, notes: v),
            ),
            const SizedBox(height: 12),
            _FilesPanel(
              item: item,
              busy: _busy,
              onUpload: _pickAndUpload,
              onRemove: (fileId) => store.removeReadinessFile(
                itemId: item.id,
                fileId: fileId,
              ),
            ),
            if (isOverdue) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(children: [
                  Icon(Icons.warning_amber_outlined,
                      size: 16, color: Color(0xFFDC2626)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Deliverable is past due. Escalate to the owner or revise the due date.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF991B1B)),
                    ),
                  ),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusMenu extends StatelessWidget {
  const _StatusMenu({required this.status, required this.onChanged});
  final ReadinessStatus status;
  final ValueChanged<ReadinessStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        border: Border.all(color: status.color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ReadinessStatus>(
          value: status,
          isDense: true,
          icon: Icon(Icons.expand_more, size: 16, color: status.color),
          style: TextStyle(
              color: status.color, fontWeight: FontWeight.w600, fontSize: 12),
          items: [
            for (final s in ReadinessStatus.values)
              DropdownMenuItem<ReadinessStatus>(
                value: s,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: s.color,
                          borderRadius: BorderRadius.circular(50))),
                  const SizedBox(width: 6),
                  Text(s.label,
                      style: TextStyle(color: s.color, fontSize: 12)),
                ]),
              ),
          ],
          onChanged: (s) {
            if (s != null) onChanged(s);
          },
        ),
      ),
    );
  }
}

class _FilesPanel extends StatelessWidget {
  const _FilesPanel({
    required this.item,
    required this.busy,
    required this.onUpload,
    required this.onRemove,
  });
  final ReadinessChecklistItem item;
  final bool busy;
  final VoidCallback onUpload;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.cloud_upload_outlined,
                size: 16, color: Color(0xFF334155)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.files.isEmpty
                    ? 'No files uploaded yet'
                    : '${item.files.length} file${item.files.length == 1 ? "" : "s"} uploaded',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A)),
              ),
            ),
            busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 30),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: onUpload,
                    icon: const Icon(Icons.upload_file, size: 14),
                    label: Text(
                      item.files.isEmpty ? 'Upload' : 'Add file',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
          ]),
          if (item.files.isNotEmpty) ...[
            const SizedBox(height: 6),
            for (final f in item.files)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [
                  const Icon(Icons.description_outlined,
                      size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(f.fileName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  Text('${f.uploadDate} · ${f.uploadedBy.isEmpty ? "—" : f.uploadedBy}',
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF6B7280))),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 22, minHeight: 22),
                    icon: const Icon(Icons.close,
                        size: 14, color: Color(0xFF9CA3AF)),
                    onPressed: () => onRemove(f.id),
                  ),
                ]),
              ),
          ],
        ],
      ),
    );
  }
}
