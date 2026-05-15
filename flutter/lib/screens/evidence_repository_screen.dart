import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/grc_store.dart';
import '../widgets/common.dart';

class EvidenceRepositoryScreen extends StatelessWidget {
  const EvidenceRepositoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GrcStore>();
    if (!store.hydrated) return const Center(child: CircularProgressIndicator());

    final ev = store.evidence;
    final total = ev.length;
    final valid =
        ev.where((e) => e.status == EvidenceStatus.valid).length;
    final expiring =
        ev.where((e) => e.status == EvidenceStatus.expiringSoon).length;
    final expired =
        ev.where((e) => e.status == EvidenceStatus.expired).length;
    final misnamed = ev.where((e) => !e.validNaming).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Evidence Repository',
            subtitle: 'Upload, tag, version, and validate evidence per control',
            actions: [
              FilledButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Evidence'),
                onPressed: () => _openUpload(context),
              ),
            ],
          ),
          Wrap(spacing: 16, runSpacing: 16, children: [
            SizedBox(
                width: 160,
                child: KpiTile(
                    label: 'Total',
                    value: '$total',
                    color: const Color(0xFF2563EB))),
            SizedBox(
                width: 160,
                child: KpiTile(
                    label: 'Valid',
                    value: '$valid',
                    color: const Color(0xFF16A34A))),
            SizedBox(
                width: 180,
                child: KpiTile(
                    label: 'Expiring ≤30d',
                    value: '$expiring',
                    color: const Color(0xFFF59E0B))),
            SizedBox(
                width: 160,
                child: KpiTile(
                    label: 'Expired',
                    value: '$expired',
                    color: const Color(0xFFDC2626))),
            SizedBox(
                width: 180,
                child: KpiTile(
                    label: 'Naming issues',
                    value: '$misnamed',
                    color: const Color(0xFF7E22CE))),
          ]),
          const SizedBox(height: 16),
          if (ev.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(children: [
                    const Icon(Icons.folder_open,
                        size: 48, color: Color(0xFF9CA3AF)),
                    const SizedBox(height: 8),
                    const Text('No evidence uploaded yet',
                        style: TextStyle(color: Color(0xFF6B7280))),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload your first artifact'),
                        onPressed: () => _openUpload(context)),
                  ]),
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (final e in ev) _EvidenceRow(item: e),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _openUpload(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _UploadDialog(),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({required this.item});
  final Evidence item;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      EvidenceStatus.valid => const Color(0xFF16A34A),
      EvidenceStatus.expiringSoon => const Color(0xFFF59E0B),
      EvidenceStatus.expired => const Color(0xFFDC2626),
    };
    final statusLabel = switch (item.status) {
      EvidenceStatus.valid => 'Valid',
      EvidenceStatus.expiringSoon => 'Expiring Soon',
      EvidenceStatus.expired => 'Expired',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(item.validNaming ? Icons.verified_outlined : Icons.report_outlined,
              size: 18,
              color: item.validNaming
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.fileName,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                if (item.description.isNotEmpty)
                  Text(item.description,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                if (item.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final t in item.tags)
                          TagChip(
                              label: t,
                              color: const Color(0xFF6366F1),
                              dense: true),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(item.controlId,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
          SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.uploadDate, style: const TextStyle(fontSize: 12)),
                Text('v${item.version}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(item.expirationDate.isEmpty ? '—' : item.expirationDate,
                style: const TextStyle(fontSize: 12)),
          ),
          TagChip(label: statusLabel, color: statusColor, dense: true),
          IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => context.read<GrcStore>().removeEvidence(item.id)),
        ],
      ),
    );
  }
}

class _UploadDialog extends StatefulWidget {
  const _UploadDialog();

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  String? _controlId;
  String _fileName = '';
  final _desc = TextEditingController();
  final _expiry = TextEditingController();
  final _uploadedBy = TextEditingController();
  final _tagInput = TextEditingController();
  final List<String> _tags = [];

  @override
  void dispose() {
    _desc.dispose();
    _expiry.dispose();
    _uploadedBy.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<GrcStore>();
    final namingValid = _fileName.isEmpty || isValidNaming(_fileName);

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
            Row(children: [
              const Expanded(
                  child: Text('Upload Evidence',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700))),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop()),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Naming convention: ControlID_ArtifactDescription_YYYY-MM-DD.ext — e.g. AC.1.1.1_AccessControlPolicy_2026-04-01.pdf',
                style: TextStyle(fontSize: 12),
              ),
            ),
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
            Row(children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file, size: 18),
                label: Text(_fileName.isEmpty ? 'Choose file' : _fileName,
                    overflow: TextOverflow.ellipsis),
                onPressed: () async {
                  final picked = await FilePicker.platform.pickFiles();
                  if (picked != null && picked.files.isNotEmpty) {
                    setState(() => _fileName = picked.files.single.name);
                  }
                },
              ),
            ]),
            if (_fileName.isNotEmpty && !namingValid) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'File name does not match the recommended naming convention. It will be flagged for the assessor.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _tagInput,
                  decoration: const InputDecoration(
                      labelText: 'Add tag (press +)',
                      border: OutlineInputBorder()),
                  onSubmitted: (v) {
                    if (v.trim().isEmpty) return;
                    setState(() {
                      _tags.add(v.trim());
                      _tagInput.clear();
                    });
                  },
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_tagInput.text.trim().isEmpty) return;
                    setState(() {
                      _tags.add(_tagInput.text.trim());
                      _tagInput.clear();
                    });
                  }),
            ]),
            if (_tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final t in _tags)
                      InputChip(
                        label: Text(t),
                        onDeleted: () => setState(() => _tags.remove(t)),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _uploadedBy,
                  decoration: const InputDecoration(
                      labelText: 'Uploaded by', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _expiry,
                  decoration: const InputDecoration(
                      labelText: 'Expiration date (YYYY-MM-DD)',
                      border: OutlineInputBorder()),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel')),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _controlId == null || _fileName.isEmpty
                      ? null
                      : () {
                          store.addEvidence(
                            controlId: _controlId!,
                            fileName: _fileName,
                            description: _desc.text,
                            expirationDate: _expiry.text,
                            uploadedBy: _uploadedBy.text,
                            tags: _tags,
                          );
                          Navigator.of(context).pop();
                        },
                  child: const Text('Upload'),
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
