import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/cmmc_controls.dart';
import '../data/models.dart';
import '../state/grc_store.dart';
import '../widgets/common.dart';

class ExportCenterScreen extends StatefulWidget {
  const ExportCenterScreen({super.key});

  @override
  State<ExportCenterScreen> createState() => _ExportCenterScreenState();
}

class _ExportCenterScreenState extends State<ExportCenterScreen> {
  final _selected = {
    'ssp': true,
    'controls': true,
    'poam': true,
    'evidence': true,
    'sprs': true,
    'affirmations': true,
  };
  bool _busy = false;
  String? _lastResult;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GrcStore>();
    if (!store.hydrated) return const Center(child: CircularProgressIndicator());

    final items = [
      ('ssp', 'SSP Appendix D Control Summary', 'CSV with all 110+ controls and their status'),
      ('controls', 'Control Implementation Matrix', 'Same as SSP — for the audit packet'),
      ('poam', 'POA&M Register', 'CSV of every Plan of Action & Milestone'),
      ('evidence', 'Evidence Index', 'CSV catalog of evidence artifacts'),
      ('sprs', 'SPRS Score Report', 'Plaintext score breakdown by family'),
      ('affirmations', 'Annual Affirmations', 'CSV of yearly attestations'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'Export Assessment Package',
              subtitle: 'CSV / JSON bundle for C3PAO handoff'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select documents to include',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (final it in items)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _selected[it.$1] ?? false,
                      onChanged: (v) =>
                          setState(() => _selected[it.$1] = v ?? false),
                      title: Text(it.$2,
                          style:
                              const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(it.$3,
                          style:
                              const TextStyle(color: Color(0xFF6B7280))),
                      dense: true,
                    ),
                  const SizedBox(height: 12),
                  Row(children: [
                    FilledButton.icon(
                      icon: _busy
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.download),
                      label: Text(_busy
                          ? 'Exporting…'
                          : 'Export ${_selected.values.where((v) => v).length} document(s)'),
                      onPressed: _busy ? null : () => _doExport(context, store),
                    ),
                  ]),
                  if (_lastResult != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        border: Border.all(color: const Color(0xFF16A34A)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle_outline,
                            color: Color(0xFF16A34A), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_lastResult!)),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _doExport(BuildContext context, GrcStore store) async {
    setState(() {
      _busy = true;
      _lastResult = null;
    });
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    final files = <XFile>[];

    Future<void> writeText(String name, String content) async {
      if (kIsWeb) {
        // Web: trigger download via Share — falls back to data URL share.
        files.add(XFile.fromData(
          Uint8List.fromList(utf8.encode(content)),
          name: name,
          mimeType: name.endsWith('.json') ? 'application/json' : 'text/csv',
        ));
      } else {
        final dir = await getTemporaryDirectory();
        final f = File('${dir.path}/$name');
        await f.writeAsString(content);
        files.add(XFile(f.path));
      }
    }

    if (_selected['ssp']! || _selected['controls']!) {
      await writeText(
        'SSP_AppendixD_ControlSummary_$stamp.csv',
        _controlsCsv(store.controls),
      );
    }
    if (_selected['poam']!) {
      await writeText('POAM_$stamp.csv', _poamCsv(store.poams));
    }
    if (_selected['evidence']!) {
      await writeText('Evidence_Index_$stamp.csv', _evidenceCsv(store.evidence));
    }
    if (_selected['sprs']!) {
      await writeText('SPRS_Score_$stamp.txt', _sprsReport(store));
    }
    if (_selected['affirmations']!) {
      await writeText(
          'Affirmations_$stamp.csv', _affirmationsCsv(store.affirmations));
    }

    // Always include manifest
    final manifest = {
      'generated': DateTime.now().toIso8601String(),
      'cmmcLevel': 2,
      'controls': store.controls.map((c) => c.toJson()).toList(),
      'poams': store.poams.map((p) => p.toJson()).toList(),
      'evidence': store.evidence.map((e) => e.toJson()).toList(),
      'affirmations': store.affirmations.map((a) => a.toJson()).toList(),
      'checklist': store.checklist.map((c) => c.toJson()).toList(),
    };
    await writeText(
        'CMMC_AssessmentPacket_$stamp.json', const JsonEncoder.withIndent('  ').convert(manifest));

    try {
      await Share.shareXFiles(files,
          subject: 'CMMC Autopsy assessment packet — $stamp');
      setState(() => _lastResult =
          'Generated ${files.length} file(s) and opened the share sheet.');
    } catch (e) {
      setState(() => _lastResult = 'Files saved to a temporary folder.');
    } finally {
      setState(() => _busy = false);
    }
  }
}

String _csvEscape(Object? v) {
  if (v == null) return '';
  final s = v.toString();
  if (s.contains(',') || s.contains('"') || s.contains('\n')) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

String _csv(List<List<Object?>> rows) =>
    rows.map((r) => r.map(_csvEscape).join(',')).join('\n');

String _controlsCsv(List<Control> controls) {
  final headers = [
    'Control ID', 'Family', 'Family Name', 'Control Name', 'Requirement Text',
    'Implementation Status', 'In SSP Section', 'Implementation Narrative',
    'Evidence Artifacts', 'POA&M ID', 'Owner', 'Last Reviewed', 'Notes',
  ];
  return _csv([
    headers,
    for (final c in controls)
      [
        c.id, c.familyCode, c.family, c.practice, c.description,
        c.status.label, c.ssp, c.narrative,
        c.evidenceIds.join('; '), c.poamId ?? '', c.owner, c.lastUpdated, c.notes,
      ],
  ]);
}

String _poamCsv(List<PoamItem> poams) {
  final headers = [
    'POA&M ID', 'Control ID', 'Finding', 'Risk', 'Remediation Plan',
    'Status', 'Due Date', 'Assigned To', 'Created Date',
  ];
  return _csv([
    headers,
    for (final p in poams)
      [
        p.id, p.controlId, p.finding, p.riskLevel.label, p.remediationPlan,
        p.derivedStatus.label, p.dueDate, p.assignedTo, p.createdDate,
      ],
  ]);
}

String _evidenceCsv(List<Evidence> evidence) {
  final headers = [
    'Evidence ID', 'Control ID', 'File Name', 'Description', 'Tags',
    'Upload Date', 'Expiration Date', 'Status', 'Uploaded By', 'Version',
    'Naming Valid',
  ];
  return _csv([
    headers,
    for (final e in evidence)
      [
        e.id, e.controlId, e.fileName, e.description, e.tags.join('; '),
        e.uploadDate, e.expirationDate,
        switch (e.status) {
          EvidenceStatus.valid => 'Valid',
          EvidenceStatus.expiringSoon => 'Expiring Soon',
          EvidenceStatus.expired => 'Expired',
        },
        e.uploadedBy, e.version, e.validNaming ? 'Yes' : 'No',
      ],
  ]);
}

String _affirmationsCsv(List<Affirmation> items) {
  final headers = [
    'Affirmation ID', 'Year', 'Submitted Date', 'Due Date', 'Status',
    'Affirmed By', 'Notes',
  ];
  return _csv([
    headers,
    for (final a in items)
      [a.id, a.year, a.submittedDate ?? '', a.dueDate, a.status, a.affirmedBy, a.notes],
  ]);
}

String _sprsReport(GrcStore store) {
  final r = computeReadiness(store);
  final breakdown = controlFamilies.map((f) {
    final fc = store.controls.where((c) => c.familyCode == f.code).toList();
    final impl = fc
        .where((c) =>
            c.status == ControlStatus.implemented ||
            c.status == ControlStatus.notApplicable)
        .length;
    return '${f.code} (${f.name}): $impl/${fc.length}';
  }).join('\n');

  return '''
CMMC Level 2 — SPRS Score Report
Generated: ${DateTime.now().toIso8601String().substring(0, 10)}

SPRS Score: ${r.sprs} / 110
Readiness Score: ${r.readiness}%
Controls Implemented: ${r.implemented} / ${r.total}
Open POA&Ms: ${r.openPoams}
Overdue POA&Ms: ${r.overduePoams}
Evidence Coverage: ${r.evidenceCoverage}%

Family Breakdown:
$breakdown
''';
}
