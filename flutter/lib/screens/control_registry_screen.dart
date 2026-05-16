import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/cmmc_controls.dart';
import '../data/evidence_requirements.dart';
import '../data/models.dart';
import '../state/auth.dart';
import '../state/grc_store.dart';
import '../widgets/common.dart';

class ControlRegistryScreen extends StatefulWidget {
  const ControlRegistryScreen({super.key});

  @override
  State<ControlRegistryScreen> createState() => _ControlRegistryScreenState();
}

class _ControlRegistryScreenState extends State<ControlRegistryScreen> {
  String _query = '';
  String _familyFilter = 'All';
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GrcStore>();
    if (!store.hydrated) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = store.controls.where((c) {
      final matchesQuery = _query.isEmpty
          ? true
          : '${c.id} ${c.practice} ${c.family} ${c.description}'
              .toLowerCase()
              .contains(_query.toLowerCase());
      final matchesFamily =
          _familyFilter == 'All' || c.familyCode == _familyFilter;
      final matchesStatus =
          _statusFilter == 'All' || c.status.label == _statusFilter;
      return matchesQuery && matchesFamily && matchesStatus;
    }).toList();

    final counts = {for (var s in ControlStatus.values) s: 0};
    for (final c in store.controls) {
      counts[c.status] = (counts[c.status] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Control Registry',
            subtitle:
                '${store.controls.length} controls — NIST SP 800-171 mapping for CMMC Level 2',
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final s in ControlStatus.values)
                SizedBox(
                  width: 180,
                  child: KpiTile(
                    label: s.label,
                    value: '${counts[s]}',
                    color: s.color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Filters(
            query: _query,
            family: _familyFilter,
            status: _statusFilter,
            onQuery: (v) => setState(() => _query = v),
            onFamily: (v) => setState(() => _familyFilter = v),
            onStatus: (v) => setState(() => _statusFilter = v),
          ),
          const SizedBox(height: 12),
          Text('Showing ${filtered.length} of ${store.controls.length} controls',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (final c in filtered)
                    _ControlRow(
                      control: c,
                      onEdit: () => _openEditor(context, c),
                      onStatusChanged: (s) =>
                          store.updateControl(c.id, status: s),
                    ),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text('No controls match the current filters.',
                          style: TextStyle(color: Color(0xFF9CA3AF))),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, Control c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ControlEditor(control: c),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.query,
    required this.family,
    required this.status,
    required this.onQuery,
    required this.onFamily,
    required this.onStatus,
  });
  final String query;
  final String family;
  final String status;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onFamily;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      onChanged: onQuery,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search, size: 18),
        hintText: 'Search by ID, name, family…',
        isDense: true,
        border: OutlineInputBorder(),
      ),
    );
    final familyDd = DropdownButtonFormField<String>(
      value: family,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Family',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: 'All', child: Text('All families')),
        for (final f in controlFamilies)
          DropdownMenuItem(
              value: f.code,
              child: Text('${f.code} — ${f.name}',
                  overflow: TextOverflow.ellipsis)),
      ],
      onChanged: (v) => onFamily(v ?? 'All'),
    );
    final statusDd = DropdownButtonFormField<String>(
      value: status,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Status',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: 'All', child: Text('All statuses')),
        for (final s in ControlStatus.values)
          DropdownMenuItem(value: s.label, child: Text(s.label)),
      ],
      onChanged: (v) => onStatus(v ?? 'All'),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(builder: (ctx, c) {
          if (c.maxWidth < 600) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: familyDd),
                  const SizedBox(width: 12),
                  Expanded(child: statusDd),
                ]),
              ],
            );
          }
          return Row(children: [
            Expanded(flex: 3, child: search),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: familyDd),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: statusDd),
          ]);
        }),
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.control,
    required this.onEdit,
    required this.onStatusChanged,
  });
  final Control control;
  final VoidCallback onEdit;
  final ValueChanged<ControlStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final family =
        controlFamilies.firstWhere((f) => f.code == control.familyCode);
    return LayoutBuilder(builder: (ctx, c) {
      final compact = c.maxWidth < 720;
      if (compact) {
        return InkWell(
          onTap: onEdit,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(control.id,
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const SizedBox(width: 8),
                  TagChip(
                      label: family.code, color: family.color, dense: true),
                  const Spacer(),
                  if (control.evidenceIds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.attach_file,
                            size: 13, color: Color(0xFF6B7280)),
                        Text(' ${control.evidenceIds.length}',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                      ]),
                    ),
                  Icon(Icons.chevron_right,
                      size: 18, color: Colors.grey.shade400),
                ]),
                const SizedBox(height: 6),
                Text(control.practice,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text('SSP §${control.ssp}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280))),
                const SizedBox(height: 10),
                Row(children: [
                  Flexible(
                    child: _StatusDropdown(
                        value: control.status, onChanged: onStatusChanged),
                  ),
                  const SizedBox(width: 8),
                  TagChip(
                      label: control.riskLevel.label,
                      color: control.riskLevel.color,
                      dense: true),
                ]),
              ],
            ),
          ),
        );
      }
      return InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 110,
                child: Text(control.id,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                  width: 60,
                  child: TagChip(
                      label: family.code, color: family.color, dense: true)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(control.practice,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                      Text('SSP §${control.ssp}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ),
              _StatusDropdown(
                  value: control.status, onChanged: onStatusChanged),
              const SizedBox(width: 8),
              SizedBox(
                  width: 80,
                  child: TagChip(
                      label: control.riskLevel.label,
                      color: control.riskLevel.color,
                      dense: true)),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.attach_file,
                        size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 2),
                    Text('${control.evidenceIds.length}',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});
  final ControlStatus value;
  final ValueChanged<ControlStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: value.color.withOpacity(0.1),
        border: Border.all(color: value.color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ControlStatus>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: Icon(Icons.expand_more, size: 16, color: value.color),
          style: TextStyle(
              color: value.color, fontWeight: FontWeight.w600, fontSize: 13),
          items: [
            for (final s in ControlStatus.values)
              DropdownMenuItem<ControlStatus>(
                value: s,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: s.color,
                          borderRadius: BorderRadius.circular(50))),
                  const SizedBox(width: 8),
                  Text(s.label,
                      style: TextStyle(color: s.color, fontSize: 13)),
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

class _ControlEditor extends StatefulWidget {
  const _ControlEditor({required this.control});
  final Control control;

  @override
  State<_ControlEditor> createState() => _ControlEditorState();
}

class _ControlEditorState extends State<_ControlEditor> {
  late ControlStatus _status;
  late RiskLevel _risk;
  late TextEditingController _owner;
  late TextEditingController _due;
  late TextEditingController _narrative;
  late TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _status = widget.control.status;
    _risk = widget.control.riskLevel;
    _owner = TextEditingController(text: widget.control.owner);
    _due = TextEditingController(text: widget.control.dueDate);
    _narrative = TextEditingController(text: widget.control.narrative);
    _notes = TextEditingController(text: widget.control.notes);
  }

  @override
  void dispose() {
    _owner.dispose();
    _due.dispose();
    _narrative.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.control;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${c.id} · SSP §${c.ssp}',
                          style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontFamily: 'monospace')),
                      Text(c.practice,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      Text(c.family,
                          style: const TextStyle(color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(c.description),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ControlStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Implementation Status',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final s in ControlStatus.values)
                  DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RiskLevel>(
              value: _risk,
              decoration: const InputDecoration(
                labelText: 'Risk level',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final r in RiskLevel.values)
                  DropdownMenuItem(value: r, child: Text(r.label)),
              ],
              onChanged: (v) => setState(() => _risk = v ?? _risk),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _owner,
              decoration: const InputDecoration(
                labelText: 'Owner',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _due,
              decoration: const InputDecoration(
                labelText: 'Due date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _narrative,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Implementation narrative',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _RequiredEvidenceChecklist(controlId: widget.control.id),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel')),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save'),
                  onPressed: () {
                    context.read<GrcStore>().updateControl(
                          c.id,
                          status: _status,
                          riskLevel: _risk,
                          owner: _owner.text,
                          dueDate: _due.text,
                          narrative: _narrative.text,
                          notes: _notes.text,
                        );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RequiredEvidenceChecklist extends StatelessWidget {
  const _RequiredEvidenceChecklist({required this.controlId});
  final String controlId;

  @override
  Widget build(BuildContext context) {
    final req = requirementFor(controlId);
    if (req == null) return const SizedBox.shrink();
    final evidence = context
        .watch<GrcStore>()
        .evidence
        .where((e) => e.controlId == controlId)
        .toList();

    // Group uploads by their artifactKind for inline display under each row.
    final byKind = <String, List<Evidence>>{};
    for (final e in evidence) {
      byKind.putIfAbsent(e.artifactKind, () => []).add(e);
    }
    final covered =
        req.artifacts.where((a) => byKind.containsKey(a)).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.fact_check_outlined,
                size: 16, color: Color(0xFF334155)),
            const SizedBox(width: 6),
            const Expanded(
              child: Text('C3PAO-acceptable evidence',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF0F172A))),
            ),
            Text('$covered / ${req.artifacts.length} uploaded',
                style: TextStyle(
                  fontSize: 11,
                  color: covered == req.artifacts.length
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                )),
          ]),
          const SizedBox(height: 8),
          for (final a in req.artifacts)
            _ArtifactUploadRow(
              controlId: controlId,
              artifact: a,
              evidenceType: req.evidenceType,
              uploaded: byKind[a] ?? const [],
            ),
          const SizedBox(height: 8),
          Wrap(spacing: 12, runSpacing: 4, children: [
            _kv('Type', req.evidenceType),
            _kv('Sample', req.sample),
          ]),
          if (req.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(req.notes,
                style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF6B7280))),
          ],
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
        children: [
          TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _ArtifactUploadRow extends StatefulWidget {
  const _ArtifactUploadRow({
    required this.controlId,
    required this.artifact,
    required this.evidenceType,
    required this.uploaded,
  });
  final String controlId;
  final String artifact;
  final String evidenceType;
  final List<Evidence> uploaded;

  @override
  State<_ArtifactUploadRow> createState() => _ArtifactUploadRowState();
}

class _ArtifactUploadRowState extends State<_ArtifactUploadRow> {
  bool _busy = false;

  Future<void> _pickAndUpload() async {
    setState(() => _busy = true);
    try {
      final picked = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (picked == null || picked.files.isEmpty) return;
      if (!mounted) return;
      final store = context.read<GrcStore>();
      final uploader = context.read<AuthState>().displayName ?? '';
      for (final f in picked.files) {
        store.addEvidence(
          controlId: widget.controlId,
          fileName: f.name,
          description: widget.artifact,
          uploadedBy: uploader,
          tags: widget.evidenceType.isEmpty ? [] : [widget.evidenceType],
          artifactKind: widget.artifact,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            '${picked.files.length} file(s) attached to ${widget.controlId}',
          ),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUploads = widget.uploaded.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(
              hasUploads ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: hasUploads
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.artifact,
                style: TextStyle(
                  fontSize: 12,
                  color: hasUploads
                      ? const Color(0xFF15803D)
                      : const Color(0xFF334155),
                  fontWeight: hasUploads ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: const Size(0, 28),
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.cloud_upload_outlined, size: 14),
                    label: Text(hasUploads ? 'Add file' : 'Upload',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                    onPressed: _pickAndUpload,
                  ),
          ]),
          if (hasUploads)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 4, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final e in widget.uploaded)
                    _UploadedFileChip(evidence: e),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _UploadedFileChip extends StatelessWidget {
  const _UploadedFileChip({required this.evidence});
  final Evidence evidence;

  @override
  Widget build(BuildContext context) {
    final status = evidence.status;
    final statusColor = switch (status) {
      EvidenceStatus.valid => const Color(0xFF16A34A),
      EvidenceStatus.expiringSoon => const Color(0xFFF59E0B),
      EvidenceStatus.expired => const Color(0xFFDC2626),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(Icons.description_outlined,
            size: 14, color: statusColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            evidence.fileName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF1F2937)),
          ),
        ),
        Text(evidence.uploadDate,
            style: const TextStyle(
                fontSize: 10, color: Color(0xFF6B7280))),
        IconButton(
          tooltip: 'Remove',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
          icon: const Icon(Icons.close,
              size: 14, color: Color(0xFF9CA3AF)),
          onPressed: () =>
              context.read<GrcStore>().removeEvidence(evidence.id),
        ),
      ]),
    );
  }
}
