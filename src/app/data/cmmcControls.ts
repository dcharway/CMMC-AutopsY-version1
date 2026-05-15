export interface Control {
  id: string;
  family: string;
  familyCode: string;
  practice: string;
  description: string;
  status: 'Not Started' | 'In Progress' | 'Implemented' | 'Not Applicable';
  owner: string;
  dueDate: string;
  evidenceIds: string[];
  poamId?: string;
  lastUpdated: string;
  riskLevel: 'Low' | 'Medium' | 'High';
}

export interface ControlFamily {
  code: string;
  name: string;
  controlCount: number;
  implementedCount: number;
  color: string;
}

export interface Evidence {
  id: string;
  controlId: string;
  fileName: string;
  uploadDate: string;
  expirationDate: string;
  status: 'Valid' | 'Expiring Soon' | 'Expired';
  uploadedBy: string;
  version: number;
}

export interface POAMItem {
  id: string;
  controlId: string;
  finding: string;
  riskLevel: 'Low' | 'Medium' | 'High';
  remediationPlan: string;
  dueDate: string;
  status: 'Open' | 'In Progress' | 'Completed' | 'Overdue';
  assignedTo: string;
  createdDate: string;
}

export interface Assessment {
  phase: 'Pre-Assessment' | 'Conformity Assessment' | 'Reporting' | 'Closeout';
  readiness: number;
  blockers: string[];
  completedChecklist: number;
  totalChecklist: number;
}

export const controlFamilies: ControlFamily[] = [
  { code: 'AC', name: 'Access Control', controlCount: 22, implementedCount: 18, color: '#16A34A' },
  { code: 'AT', name: 'Awareness and Training', controlCount: 5, implementedCount: 5, color: '#16A34A' },
  { code: 'AU', name: 'Audit and Accountability', controlCount: 9, implementedCount: 7, color: '#F59E0B' },
  { code: 'CA', name: 'Assessment, Authorization, and Monitoring', controlCount: 7, implementedCount: 5, color: '#F59E0B' },
  { code: 'CM', name: 'Configuration Management', controlCount: 11, implementedCount: 9, color: '#16A34A' },
  { code: 'IA', name: 'Identification and Authentication', controlCount: 11, implementedCount: 11, color: '#16A34A' },
  { code: 'IR', name: 'Incident Response', controlCount: 5, implementedCount: 3, color: '#DC2626' },
  { code: 'MA', name: 'Maintenance', controlCount: 6, implementedCount: 6, color: '#16A34A' },
  { code: 'MP', name: 'Media Protection', controlCount: 7, implementedCount: 6, color: '#F59E0B' },
  { code: 'PE', name: 'Physical Protection', controlCount: 6, implementedCount: 5, color: '#F59E0B' },
  { code: 'PS', name: 'Personnel Security', controlCount: 2, implementedCount: 2, color: '#16A34A' },
  { code: 'RA', name: 'Risk Assessment', controlCount: 5, implementedCount: 3, color: '#DC2626' },
  { code: 'SC', name: 'System and Communications Protection', controlCount: 20, implementedCount: 15, color: '#F59E0B' },
  { code: 'SI', name: 'System and Information Integrity', controlCount: 16, implementedCount: 12, color: '#F59E0B' },
];

// Sample controls (abbreviated for brevity - would contain all 110)
export const controls: Control[] = Array.from({ length: 110 }, (_, i) => {
  const familyIndex = Math.floor(i / 8) % controlFamilies.length;
  const family = controlFamilies[familyIndex];
  const statusOptions: Control['status'][] = ['Implemented', 'In Progress', 'Not Started'];
  const status = i < 86 ? 'Implemented' : i < 100 ? 'In Progress' : 'Not Started';

  return {
    id: `${family.code}.${Math.floor(i / controlFamilies.length) + 1}.${String((i % 8) + 1).padStart(3, '0')}`,
    family: family.name,
    familyCode: family.code,
    practice: `${family.code}.L2-3.${Math.floor(i / controlFamilies.length) + 1}.${(i % 8) + 1}`,
    description: `Control practice for ${family.name} - Practice ${(i % 8) + 1}`,
    status,
    owner: ['John Smith', 'Sarah Johnson', 'Michael Chen'][i % 3],
    dueDate: '2026-06-30',
    evidenceIds: status === 'Implemented' ? [`EV-${String(i + 1).padStart(3, '0')}`] : [],
    lastUpdated: '2026-05-01',
    riskLevel: ['Low', 'Medium', 'High'][i % 3] as Control['riskLevel'],
  };
});

export const evidenceList: Evidence[] = [
  {
    id: 'EV-001',
    controlId: 'AC.1.001',
    fileName: 'AC.1.001_AccessControlPolicy_2026-04-01.pdf',
    uploadDate: '2026-04-01',
    expirationDate: '2027-04-01',
    status: 'Valid',
    uploadedBy: 'John Smith',
    version: 2,
  },
  {
    id: 'EV-002',
    controlId: 'AC.1.001',
    fileName: 'AC.1.001_UserAccessList_2026-05-01.xlsx',
    uploadDate: '2026-05-01',
    expirationDate: '2026-06-01',
    status: 'Expiring Soon',
    uploadedBy: 'John Smith',
    version: 1,
  },
];

export const poamList: POAMItem[] = [
  {
    id: 'POAM-001',
    controlId: controls[2].id,
    finding: 'CUI flow controls not fully documented across all system boundaries',
    riskLevel: 'Medium',
    remediationPlan: 'Complete documentation of CUI flows and implement additional controls',
    dueDate: '2026-06-15',
    status: 'In Progress',
    assignedTo: 'Sarah Johnson',
    createdDate: '2026-01-15',
  },
  {
    id: 'POAM-002',
    controlId: controls[95].id,
    finding: 'Incident response procedures lack CUI-specific protocols',
    riskLevel: 'High',
    remediationPlan: 'Develop CUI-specific IR procedures and conduct training',
    dueDate: '2026-07-15',
    status: 'Open',
    assignedTo: 'Amanda Taylor',
    createdDate: '2025-11-01',
  },
  {
    id: 'POAM-003',
    controlId: controls[88].id,
    finding: 'Risk assessment missing supply chain analysis',
    riskLevel: 'High',
    remediationPlan: 'Conduct comprehensive supply chain risk assessment',
    dueDate: '2026-08-01',
    status: 'Open',
    assignedTo: 'Kevin White',
    createdDate: '2025-12-01',
  },
  {
    id: 'POAM-004',
    controlId: controls[102].id,
    finding: 'Vulnerability scanning not performed quarterly',
    riskLevel: 'Medium',
    remediationPlan: 'Establish quarterly scanning schedule',
    dueDate: '2026-08-01',
    status: 'In Progress',
    assignedTo: 'Kevin White',
    createdDate: '2026-02-15',
  },
  {
    id: 'POAM-005',
    controlId: controls[72].id,
    finding: 'Media sanitization procedures incomplete',
    riskLevel: 'Low',
    remediationPlan: 'Update and document media sanitization procedures',
    dueDate: '2026-06-20',
    status: 'In Progress',
    assignedTo: 'Michelle Garcia',
    createdDate: '2026-03-01',
  },
];

export const assessmentData: Assessment = {
  phase: 'Pre-Assessment',
  readiness: 78,
  blockers: [
    'IR controls at 60% implementation',
    'RA.12.004 - Supply chain risk assessment pending',
    '2 POA&Ms approaching 180-day limit',
  ],
  completedChecklist: 23,
  totalChecklist: 32,
};
