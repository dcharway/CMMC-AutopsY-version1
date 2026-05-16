import 'package:flutter/material.dart';

enum ControlStatus {
  notStarted('Not Started', Color(0xFF9CA3AF)),
  inProgress('In Progress', Color(0xFFF59E0B)),
  implemented('Implemented', Color(0xFF16A34A)),
  partial('Partial', Color(0xFF0EA5E9)),
  notApplicable('Not Applicable', Color(0xFF6B7280));

  const ControlStatus(this.label, this.color);
  final String label;
  final Color color;

  static ControlStatus fromLabel(String? s) =>
      ControlStatus.values.firstWhere((e) => e.label == s,
          orElse: () => ControlStatus.notStarted);
}

enum RiskLevel {
  low('Low', Color(0xFF16A34A)),
  medium('Medium', Color(0xFFF59E0B)),
  high('High', Color(0xFFDC2626));

  const RiskLevel(this.label, this.color);
  final String label;
  final Color color;

  static RiskLevel fromLabel(String? s) =>
      RiskLevel.values.firstWhere((e) => e.label == s,
          orElse: () => RiskLevel.medium);
}

enum PoamStatus {
  open('Open', Color(0xFF6B7280)),
  inProgress('In Progress', Color(0xFFF59E0B)),
  completed('Completed', Color(0xFF16A34A)),
  overdue('Overdue', Color(0xFFDC2626));

  const PoamStatus(this.label, this.color);
  final String label;
  final Color color;

  static PoamStatus fromLabel(String? s) =>
      PoamStatus.values.firstWhere((e) => e.label == s,
          orElse: () => PoamStatus.open);
}

enum AssessmentPhase {
  preAssessment('Pre-Assessment'),
  conformity('Conformity Assessment'),
  reporting('Reporting'),
  closeout('Closeout');

  const AssessmentPhase(this.label);
  final String label;

  static AssessmentPhase fromLabel(String? s) =>
      AssessmentPhase.values.firstWhere((e) => e.label == s,
          orElse: () => AssessmentPhase.preAssessment);
}

class ControlFamily {
  ControlFamily(this.code, this.name, this.color);
  final String code;
  final String name;
  final Color color;
}

class Control {
  Control({
    required this.id,
    required this.familyCode,
    required this.family,
    required this.practice,
    required this.description,
    required this.ssp,
    this.status = ControlStatus.notStarted,
    this.owner = '',
    this.dueDate = '',
    List<String>? evidenceIds,
    this.poamId,
    this.narrative = '',
    this.notes = '',
    this.riskLevel = RiskLevel.medium,
    String? lastUpdated,
  })  : evidenceIds = evidenceIds ?? [],
        lastUpdated =
            lastUpdated ?? DateTime.now().toIso8601String().substring(0, 10);

  final String id;
  final String familyCode;
  final String family;
  final String practice;
  final String description;
  final String ssp;
  ControlStatus status;
  String owner;
  String dueDate;
  List<String> evidenceIds;
  String? poamId;
  String narrative;
  String notes;
  RiskLevel riskLevel;
  String lastUpdated;

  Control copyWith({
    ControlStatus? status,
    String? owner,
    String? dueDate,
    List<String>? evidenceIds,
    String? poamId,
    bool clearPoam = false,
    String? narrative,
    String? notes,
    RiskLevel? riskLevel,
  }) {
    return Control(
      id: id,
      familyCode: familyCode,
      family: family,
      practice: practice,
      description: description,
      ssp: ssp,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      evidenceIds: evidenceIds ?? this.evidenceIds,
      poamId: clearPoam ? null : (poamId ?? this.poamId),
      narrative: narrative ?? this.narrative,
      notes: notes ?? this.notes,
      riskLevel: riskLevel ?? this.riskLevel,
      lastUpdated: DateTime.now().toIso8601String().substring(0, 10),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'familyCode': familyCode,
        'family': family,
        'practice': practice,
        'description': description,
        'ssp': ssp,
        'status': status.label,
        'owner': owner,
        'dueDate': dueDate,
        'evidenceIds': evidenceIds,
        'poamId': poamId,
        'narrative': narrative,
        'notes': notes,
        'riskLevel': riskLevel.label,
        'lastUpdated': lastUpdated,
      };

  static Control fromJson(Map<String, dynamic> j) => Control(
        id: j['id'],
        familyCode: j['familyCode'],
        family: j['family'],
        practice: j['practice'],
        description: j['description'],
        ssp: j['ssp'],
        status: ControlStatus.fromLabel(j['status']),
        owner: j['owner'] ?? '',
        dueDate: j['dueDate'] ?? '',
        evidenceIds: List<String>.from(j['evidenceIds'] ?? []),
        poamId: j['poamId'],
        narrative: j['narrative'] ?? '',
        notes: j['notes'] ?? '',
        riskLevel: RiskLevel.fromLabel(j['riskLevel']),
        lastUpdated: j['lastUpdated'],
      );
}

enum EvidenceStatus { valid, expiringSoon, expired }

class Evidence {
  Evidence({
    required this.id,
    required this.controlId,
    required this.fileName,
    this.description = '',
    required this.uploadDate,
    this.expirationDate = '',
    this.uploadedBy = '',
    this.version = 1,
    List<String>? tags,
    this.validNaming = false,
    this.artifactKind = '',
  }) : tags = tags ?? [];

  final String id;
  String controlId;
  String fileName;
  String description;
  String uploadDate;
  String expirationDate;
  String uploadedBy;
  int version;
  List<String> tags;
  bool validNaming;

  /// Which acceptable-evidence artifact this file satisfies for its control
  /// (e.g. "AD/AAD Group Export"). Empty when the user uploaded free-form.
  String artifactKind;

  EvidenceStatus get status {
    if (expirationDate.isEmpty) return EvidenceStatus.valid;
    final diff = DateTime.parse(expirationDate)
        .difference(DateTime.now())
        .inDays;
    if (diff < 0) return EvidenceStatus.expired;
    if (diff <= 30) return EvidenceStatus.expiringSoon;
    return EvidenceStatus.valid;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'controlId': controlId,
        'fileName': fileName,
        'description': description,
        'uploadDate': uploadDate,
        'expirationDate': expirationDate,
        'uploadedBy': uploadedBy,
        'version': version,
        'tags': tags,
        'validNaming': validNaming,
        'artifactKind': artifactKind,
      };

  static Evidence fromJson(Map<String, dynamic> j) => Evidence(
        id: j['id'],
        controlId: j['controlId'],
        fileName: j['fileName'],
        description: j['description'] ?? '',
        uploadDate: j['uploadDate'],
        expirationDate: j['expirationDate'] ?? '',
        uploadedBy: j['uploadedBy'] ?? '',
        version: j['version'] ?? 1,
        tags: List<String>.from(j['tags'] ?? []),
        validNaming: j['validNaming'] ?? false,
        artifactKind: j['artifactKind'] ?? '',
      );
}

class PoamItem {
  PoamItem({
    required this.id,
    required this.controlId,
    this.finding = '',
    this.riskLevel = RiskLevel.medium,
    this.remediationPlan = '',
    this.dueDate = '',
    this.status = PoamStatus.open,
    this.assignedTo = '',
    String? createdDate,
  }) : createdDate =
            createdDate ?? DateTime.now().toIso8601String().substring(0, 10);

  final String id;
  String controlId;
  String finding;
  RiskLevel riskLevel;
  String remediationPlan;
  String dueDate;
  PoamStatus status;
  String assignedTo;
  String createdDate;

  PoamStatus get derivedStatus {
    if (status == PoamStatus.completed) return PoamStatus.completed;
    if (dueDate.isEmpty) return status;
    final diff = DateTime.parse(dueDate).difference(DateTime.now()).inDays;
    return diff < 0 ? PoamStatus.overdue : status;
  }

  int get ageDays =>
      DateTime.now().difference(DateTime.parse(createdDate)).inDays;

  Map<String, dynamic> toJson() => {
        'id': id,
        'controlId': controlId,
        'finding': finding,
        'riskLevel': riskLevel.label,
        'remediationPlan': remediationPlan,
        'dueDate': dueDate,
        'status': status.label,
        'assignedTo': assignedTo,
        'createdDate': createdDate,
      };

  static PoamItem fromJson(Map<String, dynamic> j) => PoamItem(
        id: j['id'],
        controlId: j['controlId'],
        finding: j['finding'] ?? '',
        riskLevel: RiskLevel.fromLabel(j['riskLevel']),
        remediationPlan: j['remediationPlan'] ?? '',
        dueDate: j['dueDate'] ?? '',
        status: PoamStatus.fromLabel(j['status']),
        assignedTo: j['assignedTo'] ?? '',
        createdDate: j['createdDate'],
      );
}

class Affirmation {
  Affirmation({
    required this.id,
    required this.year,
    this.submittedDate,
    required this.dueDate,
    this.status = 'Pending',
    this.affirmedBy = '',
    this.notes = '',
  });

  final String id;
  final int year;
  String? submittedDate;
  String dueDate;
  String status;
  String affirmedBy;
  String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'year': year,
        'submittedDate': submittedDate,
        'dueDate': dueDate,
        'status': status,
        'affirmedBy': affirmedBy,
        'notes': notes,
      };

  static Affirmation fromJson(Map<String, dynamic> j) => Affirmation(
        id: j['id'],
        year: j['year'],
        submittedDate: j['submittedDate'],
        dueDate: j['dueDate'],
        status: j['status'] ?? 'Pending',
        affirmedBy: j['affirmedBy'] ?? '',
        notes: j['notes'] ?? '',
      );
}

class ChecklistItem {
  ChecklistItem({
    required this.id,
    required this.phase,
    required this.label,
    this.done = false,
    this.blocker = '',
  });

  final String id;
  final AssessmentPhase phase;
  final String label;
  bool done;
  String blocker;

  Map<String, dynamic> toJson() => {
        'id': id,
        'phase': phase.label,
        'label': label,
        'done': done,
        'blocker': blocker,
      };

  static ChecklistItem fromJson(Map<String, dynamic> j) => ChecklistItem(
        id: j['id'],
        phase: AssessmentPhase.fromLabel(j['phase']),
        label: j['label'],
        done: j['done'] ?? false,
        blocker: j['blocker'] ?? '',
      );
}
