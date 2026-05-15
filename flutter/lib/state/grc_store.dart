import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/cmmc_controls.dart';
import '../data/models.dart';

const _kStoreKey = 'cmmc_autopsy_state_v1';

final _namingRe = RegExp(
  r'^[A-Z]{2}\.\d+\.\d+\.\d+_[A-Za-z0-9-]+_\d{4}-\d{2}-\d{2}\.[A-Za-z0-9]+$',
);

bool isValidNaming(String fileName) => _namingRe.hasMatch(fileName);

String _today() => DateTime.now().toIso8601String().substring(0, 10);

String _uid(String prefix) {
  final rand = Random();
  final chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final suffix =
      List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  return '$prefix-$suffix';
}

class GrcStore extends ChangeNotifier {
  List<Control> _controls = seedControls();
  List<Evidence> _evidence = [];
  List<PoamItem> _poams = [];
  List<Affirmation> _affirmations = seedAffirmations();
  List<ChecklistItem> _checklist = seedChecklist();
  bool _hydrated = false;

  bool get hydrated => _hydrated;
  List<Control> get controls => List.unmodifiable(_controls);
  List<Evidence> get evidence => List.unmodifiable(_evidence);
  List<PoamItem> get poams => List.unmodifiable(_poams);
  List<Affirmation> get affirmations => List.unmodifiable(_affirmations);
  List<ChecklistItem> get checklist => List.unmodifiable(_checklist);

  Future<void> hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStoreKey);
      if (raw != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;

        // Always seed from the latest control catalogue, then merge stored
        // per-row state on top.
        final stored = (m['controls'] as List? ?? [])
            .map((j) => Control.fromJson(j as Map<String, dynamic>))
            .toList();
        final byId = {for (var c in stored) c.id: c};
        _controls = seedControls()
            .map((c) => byId.containsKey(c.id) ? byId[c.id]! : c)
            .toList();

        _evidence = (m['evidence'] as List? ?? [])
            .map((j) => Evidence.fromJson(j as Map<String, dynamic>))
            .toList();
        _poams = (m['poams'] as List? ?? [])
            .map((j) => PoamItem.fromJson(j as Map<String, dynamic>))
            .toList();
        _affirmations = (m['affirmations'] as List? ?? [])
            .map((j) => Affirmation.fromJson(j as Map<String, dynamic>))
            .toList();
        if (_affirmations.isEmpty) _affirmations = seedAffirmations();
        _checklist = (m['checklist'] as List? ?? [])
            .map((j) => ChecklistItem.fromJson(j as Map<String, dynamic>))
            .toList();
        if (_checklist.isEmpty) _checklist = seedChecklist();
      }
    } catch (e) {
      debugPrint('GrcStore.hydrate failed: $e');
    } finally {
      _hydrated = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'controls': _controls.map((c) => c.toJson()).toList(),
        'evidence': _evidence.map((c) => c.toJson()).toList(),
        'poams': _poams.map((c) => c.toJson()).toList(),
        'affirmations': _affirmations.map((c) => c.toJson()).toList(),
        'checklist': _checklist.map((c) => c.toJson()).toList(),
      };
      await prefs.setString(_kStoreKey, jsonEncode(payload));
    } catch (e) {
      debugPrint('GrcStore.persist failed: $e');
    }
  }

  void _emit() {
    notifyListeners();
    _persist();
  }

  // Controls -----------------------------------------------------------------
  void updateControl(String id,
      {ControlStatus? status,
      String? owner,
      String? dueDate,
      String? narrative,
      String? notes,
      RiskLevel? riskLevel}) {
    final i = _controls.indexWhere((c) => c.id == id);
    if (i < 0) return;
    _controls[i] = _controls[i].copyWith(
      status: status,
      owner: owner,
      dueDate: dueDate,
      narrative: narrative,
      notes: notes,
      riskLevel: riskLevel,
    );
    _emit();
  }

  // Evidence -----------------------------------------------------------------
  Evidence addEvidence({
    required String controlId,
    required String fileName,
    String description = '',
    String expirationDate = '',
    String uploadedBy = '',
    List<String>? tags,
  }) {
    final id = _uid('EV');
    final ev = Evidence(
      id: id,
      controlId: controlId,
      fileName: fileName,
      description: description,
      uploadDate: _today(),
      expirationDate: expirationDate,
      uploadedBy: uploadedBy,
      tags: tags ?? [],
      validNaming: isValidNaming(fileName),
    );
    _evidence.add(ev);
    final ci = _controls.indexWhere((c) => c.id == controlId);
    if (ci >= 0 && !_controls[ci].evidenceIds.contains(id)) {
      _controls[ci] = _controls[ci].copyWith(
        evidenceIds: [..._controls[ci].evidenceIds, id],
      );
    }
    _emit();
    return ev;
  }

  void removeEvidence(String id) {
    _evidence.removeWhere((e) => e.id == id);
    for (var i = 0; i < _controls.length; i++) {
      if (_controls[i].evidenceIds.contains(id)) {
        _controls[i] = _controls[i].copyWith(
          evidenceIds:
              _controls[i].evidenceIds.where((x) => x != id).toList(),
        );
      }
    }
    _emit();
  }

  // POA&M --------------------------------------------------------------------
  PoamItem addPoam({
    required String controlId,
    required String finding,
    RiskLevel riskLevel = RiskLevel.medium,
    String remediationPlan = '',
    String dueDate = '',
    PoamStatus status = PoamStatus.open,
    String assignedTo = '',
  }) {
    final id = _uid('POAM');
    final p = PoamItem(
      id: id,
      controlId: controlId,
      finding: finding,
      riskLevel: riskLevel,
      remediationPlan: remediationPlan,
      dueDate: dueDate,
      status: status,
      assignedTo: assignedTo,
    );
    _poams.add(p);
    final ci = _controls.indexWhere((c) => c.id == controlId);
    if (ci >= 0) {
      _controls[ci] = _controls[ci].copyWith(poamId: id);
    }
    _emit();
    return p;
  }

  void updatePoam(String id,
      {String? finding,
      RiskLevel? riskLevel,
      String? remediationPlan,
      String? dueDate,
      PoamStatus? status,
      String? assignedTo}) {
    final i = _poams.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final p = _poams[i];
    if (finding != null) p.finding = finding;
    if (riskLevel != null) p.riskLevel = riskLevel;
    if (remediationPlan != null) p.remediationPlan = remediationPlan;
    if (dueDate != null) p.dueDate = dueDate;
    if (status != null) p.status = status;
    if (assignedTo != null) p.assignedTo = assignedTo;
    _emit();
  }

  void removePoam(String id) {
    _poams.removeWhere((p) => p.id == id);
    for (var i = 0; i < _controls.length; i++) {
      if (_controls[i].poamId == id) {
        _controls[i] = _controls[i].copyWith(clearPoam: true);
      }
    }
    _emit();
  }

  // Affirmations -------------------------------------------------------------
  void updateAffirmation(String id,
      {String? submittedDate,
      String? dueDate,
      String? status,
      String? affirmedBy,
      String? notes}) {
    final i = _affirmations.indexWhere((a) => a.id == id);
    if (i < 0) return;
    final a = _affirmations[i];
    if (submittedDate != null) a.submittedDate = submittedDate;
    if (submittedDate == '') a.submittedDate = null;
    if (dueDate != null) a.dueDate = dueDate;
    if (status != null) a.status = status;
    if (affirmedBy != null) a.affirmedBy = affirmedBy;
    if (notes != null) a.notes = notes;
    _emit();
  }

  // Checklist ----------------------------------------------------------------
  void toggleChecklist(String id) {
    final i = _checklist.indexWhere((c) => c.id == id);
    if (i < 0) return;
    _checklist[i].done = !_checklist[i].done;
    _emit();
  }

  void setBlocker(String id, String blocker) {
    final i = _checklist.indexWhere((c) => c.id == id);
    if (i < 0) return;
    _checklist[i].blocker = blocker;
    _emit();
  }

  void resetAll() {
    _controls = seedControls();
    _evidence = [];
    _poams = [];
    _affirmations = seedAffirmations();
    _checklist = seedChecklist();
    _emit();
  }
}

class ReadinessScore {
  ReadinessScore({
    required this.total,
    required this.implemented,
    required this.inProgress,
    required this.notStarted,
    required this.partial,
    required this.readiness,
    required this.sprs,
    required this.openPoams,
    required this.overduePoams,
    required this.expiringEvidence,
    required this.evidenceCoverage,
    required this.checklistPct,
  });

  final int total;
  final int implemented;
  final int inProgress;
  final int notStarted;
  final int partial;
  final int readiness;
  final int sprs;
  final int openPoams;
  final int overduePoams;
  final int expiringEvidence;
  final int evidenceCoverage;
  final int checklistPct;
}

ReadinessScore computeReadiness(GrcStore s) {
  final controls = s.controls;
  final poams = s.poams;
  final evidence = s.evidence;
  final checklist = s.checklist;

  final total = controls.length;
  final implemented = controls
      .where((c) =>
          c.status == ControlStatus.implemented ||
          c.status == ControlStatus.notApplicable)
      .length;
  final partial =
      controls.where((c) => c.status == ControlStatus.partial).length;
  final inProgress =
      controls.where((c) => c.status == ControlStatus.inProgress).length;
  final notStarted =
      controls.where((c) => c.status == ControlStatus.notStarted).length;

  final impScore = ((implemented + partial * 0.5 + inProgress * 0.25) /
          (total == 0 ? 1 : total)) *
      100;

  final overduePoams = poams
      .where((p) =>
          p.status != PoamStatus.completed &&
          p.dueDate.isNotEmpty &&
          DateTime.parse(p.dueDate).isBefore(DateTime.now()))
      .length;
  final poamPenalty = (overduePoams * 2).clamp(0, 15);

  final implementedControls =
      controls.where((c) => c.status == ControlStatus.implemented).toList();
  final withEv =
      implementedControls.where((c) => c.evidenceIds.isNotEmpty).length;
  final evCoverage = implementedControls.isEmpty
      ? 0.0
      : (withEv / implementedControls.length) * 100;

  final cdone = checklist.where((c) => c.done).length;
  final cpct = (cdone / (checklist.isEmpty ? 1 : checklist.length)) * 100;

  final readiness =
      (impScore * 0.6 + evCoverage * 0.2 + cpct * 0.2 - poamPenalty)
          .clamp(0, 100)
          .round();

  final unmet = controls
      .where((c) =>
          c.status != ControlStatus.implemented &&
          c.status != ControlStatus.notApplicable)
      .length;
  final sprs = 110 - unmet;

  final expiringEvidence = evidence.where((e) {
    if (e.expirationDate.isEmpty) return false;
    final diff =
        DateTime.parse(e.expirationDate).difference(DateTime.now()).inDays;
    return diff <= 30;
  }).length;

  return ReadinessScore(
    total: total,
    implemented: implemented,
    inProgress: inProgress,
    notStarted: notStarted,
    partial: partial,
    readiness: readiness,
    sprs: sprs,
    openPoams: poams
        .where((p) =>
            p.status == PoamStatus.open || p.status == PoamStatus.inProgress)
        .length,
    overduePoams: overduePoams,
    expiringEvidence: expiringEvidence,
    evidenceCoverage: evCoverage.round(),
    checklistPct: cpct.round(),
  );
}
