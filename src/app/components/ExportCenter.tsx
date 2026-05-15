import { useState } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Button,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Checkbox,
  Divider,
  Alert,
  CircularProgress,
  Chip,
} from '@mui/material';
import { Download, FileText, FolderArchive, CheckCircle } from 'lucide-react';
import { useGrc, useReadinessScore, computePoamDerivedStatus, computeEvidenceStatus } from '../store/grcStore';
import { controlFamilies } from '../data/cmmcControls';

interface ExportItem {
  id: string;
  label: string;
  description: string;
  selected: boolean;
}

function downloadBlob(content: string, filename: string, type = 'text/plain') {
  const blob = new Blob([content], { type });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

function escapeCsv(v: unknown): string {
  if (v === null || v === undefined) return '';
  const s = String(v);
  if (s.includes(',') || s.includes('"') || s.includes('\n')) {
    return `"${s.replace(/"/g, '""')}"`;
  }
  return s;
}

function toCsv(rows: Record<string, unknown>[], headers: string[]): string {
  const head = headers.map(escapeCsv).join(',');
  const body = rows
    .map((r) => headers.map((h) => escapeCsv(r[h])).join(','))
    .join('\n');
  return `${head}\n${body}`;
}

export function ExportCenter() {
  const { controls, poams, evidence, affirmations, checklist } = useGrc();
  const readiness = useReadinessScore();
  const [exporting, setExporting] = useState(false);
  const [exportComplete, setExportComplete] = useState(false);
  const [exportItems, setExportItems] = useState<ExportItem[]>([
    {
      id: 'ssp',
      label: 'System Security Plan (SSP) Appendix',
      description: 'Complete SSP with all control implementations',
      selected: true,
    },
    {
      id: 'controls',
      label: 'Control Implementation Matrix',
      description: 'Detailed status of all 110 controls',
      selected: true,
    },
    {
      id: 'poam',
      label: 'Plans of Action & Milestones (POA&M)',
      description: 'All open and closed POA&M items with timelines',
      selected: true,
    },
    {
      id: 'evidence',
      label: 'Evidence Repository Index',
      description: 'Catalog of all evidence files with metadata',
      selected: true,
    },
    {
      id: 'evidence-files',
      label: 'Evidence Files (ZIP)',
      description: 'All uploaded evidence documents packaged',
      selected: true,
    },
    {
      id: 'sprs',
      label: 'SPRS Score Report',
      description: 'Supplier Performance Risk System score calculation',
      selected: true,
    },
    {
      id: 'affirmations',
      label: 'Annual Affirmations',
      description: 'History of compliance affirmations',
      selected: true,
    },
    {
      id: 'system-boundary',
      label: 'System Boundary Documentation',
      description: 'Network diagrams and data flow documentation',
      selected: false,
    },
    {
      id: 'audit-logs',
      label: 'Audit Activity Logs',
      description: 'System access and change logs',
      selected: false,
    },
  ]);

  const handleToggle = (id: string) => {
    setExportItems(prev =>
      prev.map(item =>
        item.id === id ? { ...item, selected: !item.selected } : item
      )
    );
  };

  const handleExport = async () => {
    setExporting(true);
    setExportComplete(false);

    const selectedIds = new Set(exportItems.filter((i) => i.selected).map((i) => i.id));
    const stamp = new Date().toISOString().slice(0, 10);

    if (selectedIds.has('controls') || selectedIds.has('ssp')) {
      const rows = controls.map((c) => ({
        'Control ID': c.id,
        Family: c.familyCode,
        'Family Name': c.family,
        'Control Name': c.practice,
        'Requirement Text': c.description,
        'Implementation Status': c.status,
        'In SSP Section': c.ssp,
        'Implementation Narrative': c.narrative,
        'Evidence Artifacts': c.evidenceIds.join('; '),
        'POA&M ID': c.poamId ?? '',
        Owner: c.owner,
        'Last Reviewed': c.lastUpdated,
        Notes: c.notes,
      }));
      downloadBlob(
        toCsv(rows, [
          'Control ID',
          'Family',
          'Family Name',
          'Control Name',
          'Requirement Text',
          'Implementation Status',
          'In SSP Section',
          'Implementation Narrative',
          'Evidence Artifacts',
          'POA&M ID',
          'Owner',
          'Last Reviewed',
          'Notes',
        ]),
        `SSP_AppendixD_ControlSummary_${stamp}.csv`,
        'text/csv',
      );
    }

    if (selectedIds.has('poam')) {
      const rows = poams.map((p) => ({
        'POA&M ID': p.id,
        'Control ID': p.controlId,
        Finding: p.finding,
        Risk: p.riskLevel,
        'Remediation Plan': p.remediationPlan,
        Status: computePoamDerivedStatus(p),
        'Due Date': p.dueDate,
        'Assigned To': p.assignedTo,
        'Created Date': p.createdDate,
      }));
      downloadBlob(
        toCsv(rows, [
          'POA&M ID',
          'Control ID',
          'Finding',
          'Risk',
          'Remediation Plan',
          'Status',
          'Due Date',
          'Assigned To',
          'Created Date',
        ]),
        `POAM_${stamp}.csv`,
        'text/csv',
      );
    }

    if (selectedIds.has('evidence')) {
      const rows = evidence.map((e) => ({
        'Evidence ID': e.id,
        'Control ID': e.controlId,
        'File Name': e.fileName,
        Description: e.description,
        Tags: e.tags.join('; '),
        'Upload Date': e.uploadDate,
        'Expiration Date': e.expirationDate,
        Status: computeEvidenceStatus(e),
        'Uploaded By': e.uploadedBy,
        Version: e.version,
        'Naming Valid': e.validNaming ? 'Yes' : 'No',
      }));
      downloadBlob(
        toCsv(rows, [
          'Evidence ID',
          'Control ID',
          'File Name',
          'Description',
          'Tags',
          'Upload Date',
          'Expiration Date',
          'Status',
          'Uploaded By',
          'Version',
          'Naming Valid',
        ]),
        `Evidence_Index_${stamp}.csv`,
        'text/csv',
      );
    }

    if (selectedIds.has('sprs')) {
      const familyBreakdown = controlFamilies
        .map((f) => {
          const fc = controls.filter((c) => c.familyCode === f.code);
          const impl = fc.filter(
            (c) => c.status === 'Implemented' || c.status === 'Not Applicable',
          ).length;
          return `${f.code} (${f.name}): ${impl}/${fc.length}`;
        })
        .join('\n');
      const report = `CMMC Level 2 — SPRS Score Report
Generated: ${stamp}

SPRS Score: ${readiness.sprs} / 110
Readiness Score: ${readiness.readiness}%
Controls Implemented: ${readiness.implemented} / ${readiness.total}
Open POA&Ms: ${readiness.openPoams}
Overdue POA&Ms: ${readiness.overduePoams}
Evidence Coverage: ${readiness.evidenceCoverage}%

Family Breakdown:
${familyBreakdown}
`;
      downloadBlob(report, `SPRS_Score_${stamp}.txt`, 'text/plain');
    }

    if (selectedIds.has('affirmations')) {
      const rows = affirmations.map((a) => ({
        'Affirmation ID': a.id,
        Year: a.year,
        'Submitted Date': a.submittedDate ?? '',
        'Due Date': a.dueDate,
        Status: a.status,
        'Affirmed By': a.affirmedBy,
        Notes: a.notes,
      }));
      downloadBlob(
        toCsv(rows, [
          'Affirmation ID',
          'Year',
          'Submitted Date',
          'Due Date',
          'Status',
          'Affirmed By',
          'Notes',
        ]),
        `Affirmations_${stamp}.csv`,
        'text/csv',
      );
    }

    // Always include a JSON manifest with everything (single audit packet)
    const manifest = {
      generated: new Date().toISOString(),
      cmmcLevel: 2,
      summary: {
        sprsScore: readiness.sprs,
        readiness: readiness.readiness,
        controlsImplemented: readiness.implemented,
        controlsTotal: readiness.total,
        openPoams: readiness.openPoams,
        overduePoams: readiness.overduePoams,
        evidenceCoverage: readiness.evidenceCoverage,
      },
      controls,
      poams,
      evidence,
      affirmations,
      assessmentChecklist: checklist,
    };
    downloadBlob(
      JSON.stringify(manifest, null, 2),
      `CMMC_AssessmentPacket_${stamp}.json`,
      'application/json',
    );

    setExporting(false);
    setExportComplete(true);

    setTimeout(() => setExportComplete(false), 5000);
  };

  const selectedCount = exportItems.filter(item => item.selected).length;

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" sx={{ mb: 3 }}>
        Export Assessment Package
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2 }}>
                Select Documents to Export
              </Typography>

              <Alert severity="info" sx={{ mb: 3 }}>
                This export package is designed for C3PAO (CMMC Third Party Assessment Organization) handoff and includes all required documentation for CMMC Level 2 assessment.
              </Alert>

              <List>
                {exportItems.map((item, index) => (
                  <Box key={item.id}>
                    <ListItem
                      sx={{
                        backgroundColor: item.selected ? '#F0F9FF' : 'transparent',
                        borderRadius: 1,
                        mb: 1,
                        cursor: 'pointer',
                      }}
                      onClick={() => handleToggle(item.id)}
                    >
                      <ListItemIcon>
                        <Checkbox
                          edge="start"
                          checked={item.selected}
                          tabIndex={-1}
                          disableRipple
                        />
                      </ListItemIcon>
                      <ListItemText
                        primary={
                          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                            <FileText size={18} />
                            <Typography variant="body1" sx={{ fontWeight: 500 }}>
                              {item.label}
                            </Typography>
                          </Box>
                        }
                        secondary={item.description}
                      />
                    </ListItem>
                    {index < exportItems.length - 1 && <Divider />}
                  </Box>
                ))}
              </List>

              <Box sx={{ mt: 3, display: 'flex', gap: 2, alignItems: 'center' }}>
                <Button
                  variant="contained"
                  size="large"
                  startIcon={exporting ? <CircularProgress size={20} color="inherit" /> : <Download size={20} />}
                  onClick={handleExport}
                  disabled={selectedCount === 0 || exporting}
                  sx={{ minWidth: 200 }}
                >
                  {exporting ? 'Exporting...' : `Export ${selectedCount} Document${selectedCount !== 1 ? 's' : ''}`}
                </Button>

                {exportComplete && (
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <CheckCircle size={20} color="#16A34A" />
                    <Typography variant="body2" sx={{ color: '#16A34A' }}>
                      Export complete!
                    </Typography>
                  </Box>
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          {/* Export Summary */}
          <Card sx={{ mb: 3 }}>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2 }}>
                Export Summary
              </Typography>

              <Box sx={{ mb: 2 }}>
                <Typography variant="body2" color="text.secondary">
                  Selected Items
                </Typography>
                <Typography variant="h4" sx={{ color: '#2563EB' }}>
                  {selectedCount}
                </Typography>
              </Box>

              <Divider sx={{ my: 2 }} />

              <Box sx={{ mb: 2 }}>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                  Estimated Size
                </Typography>
                <Chip label="~125 MB" size="small" />
              </Box>

              <Box>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                  Format
                </Typography>
                <Chip label="ZIP Archive" size="small" icon={<FolderArchive size={16} />} />
              </Box>
            </CardContent>
          </Card>

          {/* Export Formats */}
          <Card sx={{ mb: 3 }}>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2 }}>
                Available Formats
              </Typography>

              <List dense>
                <ListItem>
                  <ListItemIcon>
                    <FileText size={18} />
                  </ListItemIcon>
                  <ListItemText
                    primary="PDF Reports"
                    secondary="Human-readable documents"
                  />
                </ListItem>
                <ListItem>
                  <ListItemIcon>
                    <FileText size={18} />
                  </ListItemIcon>
                  <ListItemText
                    primary="Excel Spreadsheets"
                    secondary="Control matrices and tracking"
                  />
                </ListItem>
                <ListItem>
                  <ListItemIcon>
                    <FileText size={18} />
                  </ListItemIcon>
                  <ListItemText
                    primary="JSON Data"
                    secondary="Machine-readable format"
                  />
                </ListItem>
              </List>
            </CardContent>
          </Card>

          {/* Quick Actions */}
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2 }}>
                Quick Actions
              </Typography>

              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Button variant="outlined" size="small" fullWidth>
                  Export SPRS Score Only
                </Button>
                <Button variant="outlined" size="small" fullWidth>
                  Export POA&M Summary
                </Button>
                <Button variant="outlined" size="small" fullWidth>
                  Export Control Status
                </Button>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
