/// Per-control acceptable-evidence catalogue.
///
/// Sourced from the C3PAO evidence-needed table — one record per CMMC
/// Level 2 control listing the artifacts an assessor will accept, the
/// expected evidence type, sample size, and key notes.
library;

class EvidenceRequirement {
  const EvidenceRequirement({
    required this.controlId,
    required this.artifacts,
    required this.evidenceType,
    required this.sample,
    required this.notes,
  });

  /// The control this requirement is attached to (e.g. "AC.1.1.1").
  final String controlId;

  /// Accepted artifact names — at least one is expected per control.
  final List<String> artifacts;

  /// Type bundle (e.g. "Config Export + Policy").
  final String evidenceType;

  /// Sample size / scope the assessor expects.
  final String sample;

  /// Key notes / acceptance criteria for the C3PAO.
  final String notes;
}

const _raw = <List<String>>[
  // controlId, artifacts (";"-separated), evidenceType, sample, notes
  ['AC.1.1.1', 'AD/AAD Group Export;Access Control Policy', 'Config Export + Policy', 'All priv groups + 10 random users', 'Show member names, last review date. Policy defines who authorizes access'],
  ['AC.1.1.2', 'RBAC Role Matrix;App Permission Screenshot', 'Matrix + Screenshot', '3 apps + 5 roles', 'Prove a user can’t access functions outside their role'],
  ['AC.1.1.3', 'Network Diagram;Firewall Rules for CUI', 'Diagram + Config Export', 'All CUI egress points', 'Diagram must show boundary. Rules = allow by exception only'],
  ['AC.1.1.4', 'SOD Matrix;Job Descriptions', 'Policy + Matrix', 'All privileged roles', 'No 1 person can approve + execute. Finance/IT fails here most'],
  ['AC.1.1.5', 'Privileged Account List;Justification Forms;Review Logs', 'Config + Doc + Log', 'All priv accounts', 'Quarterly review required. Admin account ≠ daily use account'],
  ['AC.1.1.6', 'Non-Privileged Account Use Policy;Login Logs', 'Policy + Log', '5 priv users, 30 days', 'Show admins use standard account for email/web'],
  ['AC.1.1.7', 'Priv Functions List;Block Test Log;Audit Log', 'List + Test + Log', 'Test with std user', 'Log must show denied attempt + successful priv use'],
  ['AC.1.1.8', 'GPO/Config Export;Lockout Screenshot', 'Config + Screenshot', '3 systems', 'Max 5 attempts. Must show actual lockout'],
  ['AC.1.1.9', 'Logon Banner Screenshot;System Use Notification Policy', 'Screenshot + Policy', 'All CUI systems', 'Must mention CUI + monitoring + penalties'],
  ['AC.1.1.10', 'GPO/MDM Session Lock Policy;Locked Screen Screenshot', 'Config + Screenshot', '5 random workstations', '15 min max. Screen blanks/hides data'],
  ['AC.1.1.11', 'VPN/RDP Timeout Config;Disconnect Log', 'Config + Log', 'All remote access', '30 min idle typical. Log shows disconnect'],
  ['AC.1.1.12', 'Remote Access Policy;Session Logs', 'Policy + Log', 'All remote users, 30 days', 'SIEM/VPN logs: source IP, user, duration'],
  ['AC.1.1.13', 'VPN Config;Protocol Screenshot', 'Config Export', 'All VPN concentrators', 'TLS 1.2+, IPSec, FIPS 140-2. No PPTP'],
  ['AC.1.1.14', 'Network Diagram;Firewall Rules', 'Diagram + Config', 'All remote entry', 'No split tunnel. All traffic via corp firewall'],
  ['AC.1.1.15', 'Priv Access Policy;Approval Tickets', 'Policy + Ticket', 'Last 10 priv sessions', 'Need approval/ticket for each remote admin session'],
  ['AC.1.1.16', 'Wireless Policy;Controller Config;Auth Logs', 'Policy + Config + Log', 'All SSIDs', '802.1x or captive portal. MAC auth not enough'],
  ['AC.1.1.17', 'Wireless Controller Config;Packet Capture', 'Config + PCAP', 'All CUI SSIDs', 'WPA2-Enterprise AES min. No WEP/WPA'],
  ['AC.1.1.18', 'MDM Policy;MDM Enrollment Report', 'Policy + Report', 'All BYOD + corp', 'MDM required. Must check compliance before access'],
  ['AC.1.1.19', 'MDM Encryption Policy;Device Encryption Report', 'Config + Report', 'All devices with CUI', 'AES-256. iOS/Android native OK if enforced'],
  ['AC.1.1.20', 'External System Approval Forms;Connection Agreements', 'Forms + Agreements', 'All external CUI connections', 'Cloud/vendor/customer. Need ATO or contract'],
  ['AC.1.1.21', 'DLP/USB Policy;Block Event Logs', 'Policy + Log', '30 days logs', 'Block or encrypt USB. Logs must show blocks'],
  ['AC.1.1.22', 'Public Posting Policy;DLP Scan Results', 'Policy + Report', 'DLP reports 90 days', 'No CUI in public Slack, GitHub, etc'],

  ['AT.1.1.1', 'Security Awareness Training Content;Completion Records;Phishing Test Results', 'Training + Records', '100% of users', 'Annual. Must cover CUI + insider threat'],
  ['AT.1.1.2', 'Role-Based Training Curriculum;Completion by Role', 'Training + Records', 'All admins, devs, execs', 'Admins=priv training. Devs=secure coding'],
  ['AT.1.1.3', 'Insider Threat Training Module;Completion Records', 'Training + Records', '100% of users', 'Include reporting process'],

  ['AU.1.1.1', 'Audit Policy;SIEM Config;7 Days of Logs', 'Policy + Config + Logs', '3 systems, 7 days', 'Must log: user, action, time, success/fail, object'],
  ['AU.1.1.2', 'Audit Log Samples', 'Log Sample', '10 random events', 'Must show username, not just IP'],
  ['AU.1.1.3', 'Audit Review Procedure;Review Tickets', 'Procedure + Records', '90 days tickets', 'Weekly review. Show who reviewed'],
  ['AU.1.1.4', 'SIEM Alert Config;Test Alert Screenshot', 'Config + Screenshot', 'Test', 'Stop logging service, show alert fires'],
  ['AU.1.1.5', 'SIEM Correlation Rules;IR Report', 'Config + Report', 'Last incident', 'Show how logs used in real investigation'],
  ['AU.1.1.6', 'SIEM Dashboard Screenshot;Report Export', 'Screenshot + Report', 'Live demo', 'Analyst must demo on-demand query'],
  ['AU.1.1.7', 'NTP Config;Time Sync Log', 'Config + Log', 'All CUI systems', 'pool.ntp.org or internal. Same time in logs'],
  ['AU.1.1.8', 'SIEM RBAC;Audit Integrity Test', 'Config + Test', 'Test with std user', 'Std user cannot delete/modify logs'],
  ['AU.1.1.9', 'SIEM Admin Group;SIEM Access Logs', 'Config + Log', '90 days logs', 'Only SIEM admins can manage logging'],

  ['CA.1.1.1', 'System Security Plan (SSP)', 'Doc', 'Current version', 'SSP must cover all 110 controls + boundary'],
  ['CA.1.1.2', 'SSP Version History;Assessment Reports', 'Doc + Report', 'Annual updates', 'Show assessment done in last year'],

  ['CM.1.1.1', 'Asset Inventory;CIS Benchmark Scan;Baseline Configuration Doc', 'Inventory + Scan + Doc', '10% of CUI assets', 'Hardware, software, firmware. Scan <30 days old'],
  ['CM.1.1.2', 'STIG/GPO Baseline;Compliance Scan', 'Config + Scan', 'All CUI systems', 'No default passwords, unneeded services off'],
  ['CM.1.1.3', 'Change Management Policy;Change Tickets', 'Policy + Tickets', 'Last 20 changes', 'No emergency changes without retro approval'],
  ['CM.1.1.4', 'Change Ticket with Security Impact Analysis', 'Ticket', 'Last 10 changes', 'Must assess CUI impact before change'],
  ['CM.1.1.5', 'Change System RBAC;Change System Access Logs', 'Config + Log', '90 days', 'Only CAB can approve changes'],
  ['CM.1.1.6', 'System Hardening Config;Port Scan', 'Config + Scan', '5 systems', 'Show unneeded services disabled'],
  ['CM.1.1.7', 'Application Control Policy;Block Logs', 'Policy + Log', '30 days logs', 'AppLocker/WDAC. Logs show blocks'],
  ['CM.1.1.8', 'Application Control Policy;Live Block Demo', 'Policy + Demo', 'Live demo', 'Run unapproved exe, show block'],
  ['CM.1.1.9', 'User-Installed Software Policy;Software Inventory;Install Alerts', 'Policy + Inventory + Log', '90 days', 'Users cannot install without approval'],

  ['CP.1.1.1', 'Contingency Plan;Business Impact Analysis (BIA)', 'Doc', 'Current', 'Include RTO/RPO. Must address CUI'],
  ['CP.1.1.2', 'Contingency Test Plan;After-Action Report (AAR)', 'Doc + Report', 'Test <1 year old', 'Tabletop or full failover'],
  ['CP.1.1.3', 'Alternate Storage Site Contract;Restore Log', 'Agreement + Log', 'Last test', 'Cloud backup OK. Show restore works'],
  ['CP.1.1.4', 'Alternate Processing Site Agreement;DR Test Results', 'Agreement + Report', 'Last test', 'DR site/cloud. Show RTO met'],
  ['CP.1.1.5', 'ISP Agreement;Telecom Failover Test', 'Agreement + Report', 'Last test', 'Secondary ISP or LTE backup'],
  ['CP.1.1.6', 'Backup Policy;Backup Logs;Restore Test Results', 'Policy + Log + Report', '30 days logs', 'Daily backups, monthly restore test'],
  ['CP.1.1.7', 'System Backup Policy;Bare Metal Recovery Test', 'Policy + Report', 'Last test', 'OS + apps, not just data'],
  ['CP.1.1.8', 'Backup Encryption Config;Backup Access Logs', 'Config + Log', '30 days', 'AES-256. Access limited'],
  ['CP.1.1.9', 'Key Management Policy;Backup Crypto Config', 'Policy + Config', 'Current', 'Keys stored separate from backup'],

  ['IA.1.1.1', 'IAM Policy;User List Export', 'Policy + Config', 'Full export', 'Unique usernames. Service accounts documented'],
  ['IA.1.1.2', 'Authentication Policy;Auth Config Export', 'Policy + Config', 'All systems', 'Password + MFA or cert'],
  ['IA.1.1.3', 'MFA Policy;MFA Config;Login Demo', 'Policy + Config + Demo', 'Live demo', 'MFA for network + privileged. Windows Hello OK'],
  ['IA.1.1.4', 'Replay-Resistant Auth Protocol Config', 'Config', 'All network logins', 'Kerberos, TLS cert. NTLMv1 fails'],
  ['IA.1.1.5', 'IAM Identifier Policy;Disabled Account List', 'Policy + Export', 'All accounts', '90 days inactive=disable. No username reuse 2yr'],
  ['IA.1.1.6', 'Inactivity Disable Config', 'Config', '3 systems', '90 days typical'],
  ['IA.1.1.7', 'Password Policy;Password Test Screenshot', 'Policy + Screenshot', '3 systems', '12 char, complexity, no username'],
  ['IA.1.1.8', 'Password Reuse Policy Config', 'Config', '3 systems', '24 generations typical'],
  ['IA.1.1.9', 'Helpdesk Password Reset Procedure;Audit Log', 'Procedure + Log', 'Last 10 resets', 'Must force change at next logon'],
  ['IA.1.1.10', 'Password Hashing Config;Penetration Test Report', 'Config + Report', 'Pen test', 'No plaintext. No reversible encryption'],
  ['IA.1.1.11', 'Login Screenshot (Password Obscured)', 'Screenshot', '3 systems', 'Password shows dots, not chars'],

  ['IR.1.1.1', 'Incident Response Plan;Tabletop Exercise Report;Incident Ticket', 'Plan + Report + Ticket', 'Last incident', '72hr DoD reporting if CUI involved'],
  ['IR.1.1.2', 'IR Policy;DIBNet Reporting Email', 'Policy + Email', 'Last report', '32 CFR 170 requirement'],
  ['IR.1.1.3', 'IR Test Plan;Tabletop After-Action Report', 'Plan + Report', 'Annual', 'Tabletop OK. Must test comms'],

  ['MA.1.1.1', 'Maintenance Policy;Maintenance Logs', 'Policy + Log', '90 days logs', 'Patch, repair, updates'],
  ['MA.1.1.2', 'Maintenance Tool Inventory;Tool Approval Records', 'Inventory + Record', 'All tools', 'Check tools for malware before use'],
  ['MA.1.1.3', 'Off-Site Sanitization Procedure;Sanitization Certificates', 'Procedure + Cert', 'Last 5', 'Per NIST 800-88'],
  ['MA.1.1.4', 'AV Scan Logs (Maintenance Media)', 'Log', 'Last 5 uses', 'USB with diag tools scanned'],
  ['MA.1.1.5', 'Nonlocal Maintenance VPN Config;Session Logs', 'Config + Log', 'Last 5 sessions', 'MFA + timeout'],
  ['MA.1.1.6', 'Vendor Escort Logs', 'Log', 'All vendor visits', 'Escort required'],

  ['MP.1.1.1', 'Media Protection Policy;Media Storage Photos;Media Access Logs', 'Policy + Photo + Log', 'Site walkthrough', 'Locked cabinet, clean desk'],
  ['MP.1.1.2', 'Media Handling Policy;Marked Media Photo', 'Policy + Photo', 'Sample media', 'CUI markings visible'],
  ['MP.1.1.3', 'Sanitization Procedure;Destruction Certificates', 'Procedure + Cert', 'Last 10', 'Degauss, shred, crypto erase per 800-88'],
  ['MP.1.1.4', 'Media Transport Log;Chain of Custody Form', 'Log', 'Last 5 shipments', 'Locked container, signed form'],
  ['MP.1.1.5', 'Media Sanitization Logs', 'Log', 'All media', 'Per 800-88'],
  ['MP.1.1.6', 'Destruction Certificates;Witness Sign-off', 'Cert', 'All destroyed', 'Certificate from vendor or witness'],
  ['MP.1.1.7', 'Removable Media Policy;DLP Logs', 'Policy + Log', '30 days', 'Block or allowlist only'],
  ['MP.1.1.8', 'Unknown Media Block Policy;Unknown USB Block Test', 'Policy + Demo', 'Test', 'Plug unknown USB, show block'],

  ['PE.1.1.1', 'Physical Access List;Access Approval Records', 'List + Record', 'All CUI areas', 'List reviewed quarterly'],
  ['PE.1.1.2', 'Facility Photos;Badge System Config', 'Photo + Config', 'Walkthrough', 'Badges, cameras, locks'],
  ['PE.1.1.3', 'Visitor Log;Escort Policy', 'Log + Policy', '90 days', 'Visitors signed in/out, escorted in CUI'],
  ['PE.1.1.4', 'Badge Reader / Physical Access Logs', 'Log', '90 days', 'Badge reader logs'],
  ['PE.1.1.5', 'Camera System Config;Camera Review Logs', 'Config + Log', '30 days', 'Cameras, badge readers reviewed'],
  ['PE.1.1.6', 'Remote Work Policy;CUI Attestation Form', 'Policy + Form', 'All remote staff', 'CUI not left unattended, locked storage'],

  ['PS.1.1.1', 'HR Screening Policy;Background Check Records', 'Policy + Record', 'All CUI users', 'Background check before access'],
  ['PS.1.1.2', 'Termination Checklist;Access Revocation Logs', 'Checklist + Log', 'Last 10 terms', 'Access removed same day'],

  ['RA.1.1.1', 'Risk Assessment Report;Risk Register', 'Report', 'Annual', 'Identify threats, vulns, impact'],
  ['RA.1.1.2', 'Vulnerability Scan Policy;Scan Reports', 'Policy + Report', 'Last 4 scans', 'Monthly + after zero-day'],
  ['RA.1.1.3', 'Vulnerability Remediation Policy;Patch Tickets', 'Policy + Ticket', '30 days tickets', 'Critical 15 days, High 30 days'],

  ['SC.1.1.1', 'Network Diagram;Firewall Config;IPS Logs', 'Diagram + Config + Log', 'All boundaries', 'IDS/IPS, firewall deny-all'],
  ['SC.1.1.2', 'Secure SDLC Policy;Design / Threat Model Docs', 'Policy + Doc', '3 projects', 'Threat modeling, secure coding'],
  ['SC.1.1.3', 'Network Diagram (User/Admin Separation);ACL Config', 'Diagram + Config', 'All systems', 'Admin VLAN separate from user'],
  ['SC.1.1.4', 'VDI/VM Isolation Config;Shared Resource Test', 'Config + Demo', 'Test', 'Copy/paste disabled between CUI VM and host'],
  ['SC.1.1.5', 'DMZ Network Diagram;Firewall Rules', 'Diagram + Config', 'All DMZ', 'Web server in DMZ, not internal'],
  ['SC.1.1.6', 'Default-Deny Firewall Config', 'Config', 'All firewalls', 'Show default deny, explicit allows'],
  ['SC.1.1.7', 'Split-Tunnel Prevention Config;Public Boundary Test', 'Config + Demo', 'Test', 'VPN connect, try direct internet - should fail'],
  ['SC.1.1.8', 'Transit Encryption Config;Packet Capture', 'Config + PCAP', 'Sample traffic', 'TLS 1.2+, IPSec. Show encrypted'],
  ['SC.1.1.9', 'Network Idle Timeout Config;Disconnect Log', 'Config + Log', 'Sample sessions', '30 min idle timeout'],
  ['SC.1.1.10', 'Key Management Policy;Key Inventory', 'Policy + Inventory', 'All keys', 'Keys rotated, stored separate'],
  ['SC.1.1.11', 'Cryptographic Module Config;FIPS 140-2 Certificate', 'Config + Cert', 'All crypto modules', 'FIPS 140-2 cert numbers'],
  ['SC.1.1.12', 'Collaborative Device Policy;Camera/Mic Disabled Config', 'Policy + Config', 'All conference rooms', 'Camera/mic cannot be remote activated'],
  ['SC.1.1.13', 'Mobile Code Policy;Browser Config;Block Logs', 'Policy + Config + Log', '30 days', 'Java, Flash blocked. Logs show blocks'],
  ['SC.1.1.14', 'VoIP Policy;VoIP Firewall Rules', 'Policy + Config', 'All VoIP', 'VLAN separation, encryption'],
  ['SC.1.1.15', 'DNSSEC/DKIM/SPF Config', 'Config', 'All email/DNS', 'Prevent spoofing'],
  ['SC.1.1.16', 'Disk Encryption Config;Encryption Status Screenshot', 'Config + Screenshot', '5 systems', 'BitLocker, FileVault, AES-256'],

  ['SI.1.1.1', 'Patch Management Policy;Patch Reports', 'Policy + Report', '90 days', 'Critical 15 days, High 30 days'],
  ['SI.1.1.2', 'Anti-Malware Policy;AV Console Screenshot', 'Policy + Screenshot', 'All entry/exit', 'Email, web, endpoint'],
  ['SI.1.1.3', 'Security Alert Feed Config;Alert Response Ticket', 'Config + Ticket', 'Last 3 alerts', 'CISA, vendor alerts. Show response'],
  ['SI.1.1.4', 'AV Update Config;Update Logs', 'Config + Log', '30 days', 'Definitions <7 days old'],
  ['SI.1.1.5', 'Email Security Config;Spam Block Report', 'Config + Report', '30 days', 'Scan downloads, email attachments'],
  ['SI.1.1.6', 'IDS/IPS Config;Alert Logs', 'Config + Log', '30 days', 'Signature + anomaly detection'],
  ['SI.1.1.7', 'Error Logging Config;Error Log Sample', 'Config + Log', '30 days', 'Failed logins, priv escalation attempts'],
  ['SI.1.1.8', 'File Integrity Monitoring Config;FIM Alert Log', 'Config + Log', '30 days', 'File integrity monitoring'],
  ['SI.1.1.9', 'Memory Protection OS Config;DEP/ASLR Test', 'Config + Demo', '3 systems', 'DEP/ASLR enabled'],
  ['SI.1.1.10', 'SIEM Use Cases;SIEM Dashboard Screenshot', 'Config + Screenshot', 'Live', 'Use cases defined and running'],
  ['SI.1.1.11', 'IR Playbook;Incident Detection Ticket', 'Playbook + Ticket', 'Last incident', 'Show detection to containment'],
];

final Map<String, EvidenceRequirement> _byControlId = {
  for (final r in _raw)
    r[0]: EvidenceRequirement(
      controlId: r[0],
      artifacts: r[1].split(';').map((s) => s.trim()).toList(),
      evidenceType: r[2],
      sample: r[3],
      notes: r[4],
    ),
};

/// Look up the C3PAO-acceptable evidence requirement for a control. Returns
/// null when no requirement is on file (the catalogue is exhaustive for the
/// 120-row CMMC Level 2 dataset, so this is mostly a safety net).
EvidenceRequirement? requirementFor(String controlId) =>
    _byControlId[controlId];

/// All artifact names referenced anywhere in the catalogue, deduped.
List<String> allArtifactNames() {
  final set = <String>{};
  for (final r in _byControlId.values) {
    set.addAll(r.artifacts);
  }
  return set.toList()..sort();
}
