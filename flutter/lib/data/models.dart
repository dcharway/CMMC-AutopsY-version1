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

// ── Readiness Checklist (org-level deliverables) ──────────────────────────

enum ReadinessStatus {
  notStarted('Not Started', Color(0xFF9CA3AF)),
  inProgress('In Progress', Color(0xFFF59E0B)),
  submitted('Submitted', Color(0xFF2563EB)),
  accepted('Accepted', Color(0xFF16A34A)),
  rejected('Rejected', Color(0xFFDC2626));

  const ReadinessStatus(this.label, this.color);
  final String label;
  final Color color;

  static ReadinessStatus fromLabel(String? s) =>
      ReadinessStatus.values.firstWhere((e) => e.label == s,
          orElse: () => ReadinessStatus.notStarted);
}

class ReadinessArtifact {
  ReadinessArtifact({
    required this.id,
    required this.fileName,
    required this.uploadDate,
    this.uploadedBy = '',
  });
  final String id;
  String fileName;
  String uploadDate;
  String uploadedBy;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'uploadDate': uploadDate,
        'uploadedBy': uploadedBy,
      };

  static ReadinessArtifact fromJson(Map<String, dynamic> j) => ReadinessArtifact(
        id: j['id'],
        fileName: j['fileName'],
        uploadDate: j['uploadDate'],
        uploadedBy: j['uploadedBy'] ?? '',
      );
}

class ReadinessChecklistItem {
  ReadinessChecklistItem({
    required this.id,
    required this.artifact,
    required this.relatedControls,
    required this.capPhase,
    required this.requiredFormat,
    required this.providedBy,
    required this.dueDate,
    this.status = ReadinessStatus.notStarted,
    this.notes = '',
    List<ReadinessArtifact>? files,
  }) : files = files ?? [];

  final String id;
  final String artifact;
  final List<String> relatedControls;
  final String capPhase;
  final String requiredFormat;
  String providedBy;
  String dueDate;
  ReadinessStatus status;
  String notes;
  List<ReadinessArtifact> files;

  Map<String, dynamic> toJson() => {
        'id': id,
        'artifact': artifact,
        'relatedControls': relatedControls,
        'capPhase': capPhase,
        'requiredFormat': requiredFormat,
        'providedBy': providedBy,
        'dueDate': dueDate,
        'status': status.label,
        'notes': notes,
        'files': files.map((f) => f.toJson()).toList(),
      };

  static ReadinessChecklistItem fromJson(Map<String, dynamic> j) =>
      ReadinessChecklistItem(
        id: j['id'],
        artifact: j['artifact'],
        relatedControls: List<String>.from(j['relatedControls'] ?? []),
        capPhase: j['capPhase'] ?? 'Readiness',
        requiredFormat: j['requiredFormat'] ?? '',
        providedBy: j['providedBy'] ?? '',
        dueDate: j['dueDate'] ?? '',
        status: ReadinessStatus.fromLabel(j['status']),
        notes: j['notes'] ?? '',
        files: (j['files'] as List? ?? [])
            .map((x) => ReadinessArtifact.fromJson(x as Map<String, dynamic>))
            .toList(),
      );
}

// ── Organization Profile (OSA enterprise profile) ────────────────────────

enum HostingType {
  onPrem('On-Prem'),
  cloud('Cloud'),
  hybrid('Hybrid');

  const HostingType(this.label);
  final String label;

  static HostingType fromLabel(String? s) =>
      HostingType.values.firstWhere((e) => e.label == s,
          orElse: () => HostingType.onPrem);
}

enum CloudProvider {
  awsGovCloud('AWS GovCloud'),
  azureGov('Azure Gov'),
  other('Other'),
  none('—');

  const CloudProvider(this.label);
  final String label;

  static CloudProvider fromLabel(String? s) =>
      CloudProvider.values.firstWhere((e) => e.label == s,
          orElse: () => CloudProvider.none);
}

enum CertStatus {
  notAssessed('Not Assessed', Color(0xFF6B7280)),
  inProgress('In Progress', Color(0xFFF59E0B)),
  certified('Certified', Color(0xFF16A34A)),
  poam('POA&M', Color(0xFF0EA5E9)),
  expired('Expired', Color(0xFFDC2626));

  const CertStatus(this.label, this.color);
  final String label;
  final Color color;

  static CertStatus fromLabel(String? s) =>
      CertStatus.values.firstWhere((e) => e.label == s,
          orElse: () => CertStatus.notAssessed);
}

class ContactPerson {
  ContactPerson({this.name = '', this.title = '', this.email = '', this.phone = ''});

  String name;
  String title;
  String email;
  String phone;

  bool get isEmpty =>
      name.isEmpty && title.isEmpty && email.isEmpty && phone.isEmpty;

  Map<String, dynamic> toJson() =>
      {'name': name, 'title': title, 'email': email, 'phone': phone};

  static ContactPerson fromJson(Map<String, dynamic>? j) => ContactPerson(
        name: j?['name'] ?? '',
        title: j?['title'] ?? '',
        email: j?['email'] ?? '',
        phone: j?['phone'] ?? '',
      );
}

class EnterpriseProfile {
  EnterpriseProfile({
    // Identifiers
    this.organizationName = '',
    this.dbaName = '',
    this.cageCode = '',
    this.dunsNumber = '',
    this.uei = '',
    this.tin = '',
    // Contract scope
    this.isPrimeContractor = false,
    this.isSubcontractor = false,
    this.primeCageCode = '',
    List<String>? dodContractNumbers,
    this.handlesCUI = false,
    List<String>? cuiCategories,
    this.estimatedCUIUsers = 0,
    // System boundary
    this.systemName = '',
    this.systemBoundaryDescription = '',
    this.authorizationBoundary = '',
    ContactPerson? systemOwner,
    ContactPerson? isso,
    this.hostingType = HostingType.onPrem,
    this.cloudProvider = CloudProvider.none,
    this.fedrampId = '',
    // Assessment history
    this.cmmcLevel = 2,
    this.currentCertificationStatus = CertStatus.notAssessed,
    this.lastAssessmentDate = '',
    this.lastAssessmentC3PAO = '',
    this.lastAssessmentReportId = '',
    this.currentSPRSScore = 0,
    this.sprsSubmissionDate = '',
    this.sprsExpirationDate = '',
    // Affirmation
    this.lastAffirmationDate = '',
    this.nextAffirmationDue = '',
    ContactPerson? affirmationPOC,
    // POA&M
    this.activePoamCount = 0,
    this.oldestPoamDate = '',
    this.poamCloseoutPlanDate = '',
    // Contacts
    ContactPerson? technicalPOC,
    ContactPerson? businessPOC,
    ContactPerson? incidentResponsePOC,
    // Metadata
    String? lastUpdated,
    this.lastUpdatedBy = '',
  })  : dodContractNumbers = dodContractNumbers ?? [],
        cuiCategories = cuiCategories ?? [],
        systemOwner = systemOwner ?? ContactPerson(),
        isso = isso ?? ContactPerson(),
        affirmationPOC = affirmationPOC ?? ContactPerson(),
        technicalPOC = technicalPOC ?? ContactPerson(),
        businessPOC = businessPOC ?? ContactPerson(),
        incidentResponsePOC = incidentResponsePOC ?? ContactPerson(),
        lastUpdated =
            lastUpdated ?? DateTime.now().toIso8601String().substring(0, 10);

  String organizationName;
  String dbaName;
  String cageCode;
  String dunsNumber;
  String uei;
  String tin;

  bool isPrimeContractor;
  bool isSubcontractor;
  String primeCageCode;
  List<String> dodContractNumbers;
  bool handlesCUI;
  List<String> cuiCategories;
  int estimatedCUIUsers;

  String systemName;
  String systemBoundaryDescription;
  String authorizationBoundary;
  ContactPerson systemOwner;
  ContactPerson isso;
  HostingType hostingType;
  CloudProvider cloudProvider;
  String fedrampId;

  int cmmcLevel; // 1, 2, 3
  CertStatus currentCertificationStatus;
  String lastAssessmentDate;
  String lastAssessmentC3PAO;
  String lastAssessmentReportId;
  int currentSPRSScore;
  String sprsSubmissionDate;
  String sprsExpirationDate;

  String lastAffirmationDate;
  String nextAffirmationDue;
  ContactPerson affirmationPOC;

  int activePoamCount;
  String oldestPoamDate;
  String poamCloseoutPlanDate;

  ContactPerson technicalPOC;
  ContactPerson businessPOC;
  ContactPerson incidentResponsePOC;

  String lastUpdated;
  String lastUpdatedBy;

  Map<String, dynamic> toJson() => {
        'organizationName': organizationName,
        'dbaName': dbaName,
        'cageCode': cageCode,
        'dunsNumber': dunsNumber,
        'uei': uei,
        'tin': tin,
        'isPrimeContractor': isPrimeContractor,
        'isSubcontractor': isSubcontractor,
        'primeCageCode': primeCageCode,
        'dodContractNumbers': dodContractNumbers,
        'handlesCUI': handlesCUI,
        'cuiCategories': cuiCategories,
        'estimatedCUIUsers': estimatedCUIUsers,
        'systemName': systemName,
        'systemBoundaryDescription': systemBoundaryDescription,
        'authorizationBoundary': authorizationBoundary,
        'systemOwner': systemOwner.toJson(),
        'isso': isso.toJson(),
        'hostingType': hostingType.label,
        'cloudProvider': cloudProvider.label,
        'fedrampId': fedrampId,
        'cmmcLevel': cmmcLevel,
        'currentCertificationStatus': currentCertificationStatus.label,
        'lastAssessmentDate': lastAssessmentDate,
        'lastAssessmentC3PAO': lastAssessmentC3PAO,
        'lastAssessmentReportId': lastAssessmentReportId,
        'currentSPRSScore': currentSPRSScore,
        'sprsSubmissionDate': sprsSubmissionDate,
        'sprsExpirationDate': sprsExpirationDate,
        'lastAffirmationDate': lastAffirmationDate,
        'nextAffirmationDue': nextAffirmationDue,
        'affirmationPOC': affirmationPOC.toJson(),
        'activePoamCount': activePoamCount,
        'oldestPoamDate': oldestPoamDate,
        'poamCloseoutPlanDate': poamCloseoutPlanDate,
        'technicalPOC': technicalPOC.toJson(),
        'businessPOC': businessPOC.toJson(),
        'incidentResponsePOC': incidentResponsePOC.toJson(),
        'lastUpdated': lastUpdated,
        'lastUpdatedBy': lastUpdatedBy,
      };

  static EnterpriseProfile fromJson(Map<String, dynamic>? j) {
    if (j == null) return EnterpriseProfile();
    return EnterpriseProfile(
      organizationName: j['organizationName'] ?? '',
      dbaName: j['dbaName'] ?? '',
      cageCode: j['cageCode'] ?? '',
      dunsNumber: j['dunsNumber'] ?? '',
      uei: j['uei'] ?? '',
      tin: j['tin'] ?? '',
      isPrimeContractor: j['isPrimeContractor'] ?? false,
      isSubcontractor: j['isSubcontractor'] ?? false,
      primeCageCode: j['primeCageCode'] ?? '',
      dodContractNumbers: List<String>.from(j['dodContractNumbers'] ?? []),
      handlesCUI: j['handlesCUI'] ?? false,
      cuiCategories: List<String>.from(j['cuiCategories'] ?? []),
      estimatedCUIUsers: j['estimatedCUIUsers'] ?? 0,
      systemName: j['systemName'] ?? '',
      systemBoundaryDescription: j['systemBoundaryDescription'] ?? '',
      authorizationBoundary: j['authorizationBoundary'] ?? '',
      systemOwner:
          ContactPerson.fromJson(j['systemOwner'] as Map<String, dynamic>?),
      isso: ContactPerson.fromJson(j['isso'] as Map<String, dynamic>?),
      hostingType: HostingType.fromLabel(j['hostingType']),
      cloudProvider: CloudProvider.fromLabel(j['cloudProvider']),
      fedrampId: j['fedrampId'] ?? '',
      cmmcLevel: j['cmmcLevel'] ?? 2,
      currentCertificationStatus:
          CertStatus.fromLabel(j['currentCertificationStatus']),
      lastAssessmentDate: j['lastAssessmentDate'] ?? '',
      lastAssessmentC3PAO: j['lastAssessmentC3PAO'] ?? '',
      lastAssessmentReportId: j['lastAssessmentReportId'] ?? '',
      currentSPRSScore: j['currentSPRSScore'] ?? 0,
      sprsSubmissionDate: j['sprsSubmissionDate'] ?? '',
      sprsExpirationDate: j['sprsExpirationDate'] ?? '',
      lastAffirmationDate: j['lastAffirmationDate'] ?? '',
      nextAffirmationDue: j['nextAffirmationDue'] ?? '',
      affirmationPOC: ContactPerson.fromJson(
          j['affirmationPOC'] as Map<String, dynamic>?),
      activePoamCount: j['activePoamCount'] ?? 0,
      oldestPoamDate: j['oldestPoamDate'] ?? '',
      poamCloseoutPlanDate: j['poamCloseoutPlanDate'] ?? '',
      technicalPOC:
          ContactPerson.fromJson(j['technicalPOC'] as Map<String, dynamic>?),
      businessPOC:
          ContactPerson.fromJson(j['businessPOC'] as Map<String, dynamic>?),
      incidentResponsePOC: ContactPerson.fromJson(
          j['incidentResponsePOC'] as Map<String, dynamic>?),
      lastUpdated: j['lastUpdated'],
      lastUpdatedBy: j['lastUpdatedBy'] ?? '',
    );
  }
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
