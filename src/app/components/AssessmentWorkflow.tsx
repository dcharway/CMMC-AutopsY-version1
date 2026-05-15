import { useMemo, useState } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Checkbox,
  Stepper,
  Step,
  StepLabel,
  StepContent,
  Stack,
  Alert,
  LinearProgress,
  TextField,
  Chip,
  Button,
} from '@mui/material';
import { CheckCircle2, AlertTriangle, Lock, Unlock } from 'lucide-react';
import { AssessmentPhase } from '../data/cmmcControls';
import { useGrc, useReadinessScore } from '../store/grcStore';

const PHASES: AssessmentPhase[] = [
  'Pre-Assessment',
  'Conformity Assessment',
  'Reporting',
  'Closeout',
];

const PHASE_DESCRIPTIONS: Record<AssessmentPhase, string> = {
  'Pre-Assessment':
    'Establish scope, document the system boundary, draft the SSP, and reach internal readiness.',
  'Conformity Assessment':
    'C3PAO performs the formal assessment of all 110 practices against NIST SP 800-171A.',
  Reporting:
    'Receive findings, draft POA&Ms for any gaps (≤180-day remediation), and finalize the report.',
  Closeout:
    'Submit SPRS score, enter annual affirmation, and archive the issued certificate.',
};

export function AssessmentWorkflow() {
  const { checklist, toggleChecklist, setChecklistBlocker } = useGrc();
  const readiness = useReadinessScore();

  const phaseStats = useMemo(() => {
    return PHASES.map((phase) => {
      const items = checklist.filter((i) => i.phase === phase);
      const done = items.filter((i) => i.done).length;
      return { phase, items, done, total: items.length };
    });
  }, [checklist]);

  // First phase that is incomplete = "active step"
  const activeStep = phaseStats.findIndex((p) => p.done < p.total);

  const readyForAudit = readiness.readiness >= 90 && phaseStats[0].done === phaseStats[0].total;

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" sx={{ fontWeight: 700, mb: 0.5 }}>
        Assessment Workflow
      </Typography>
      <Typography variant="body2" sx={{ color: '#6B7280', mb: 3 }}>
        CMMC Assessment Process (CAP) — 4-phase readiness tracker
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <Card variant="outlined">
            <CardContent>
              <Stepper activeStep={activeStep < 0 ? PHASES.length : activeStep} orientation="vertical">
                {phaseStats.map((p, idx) => (
                  <Step key={p.phase} active expanded>
                    <StepLabel
                      icon={
                        p.done === p.total ? (
                          <CheckCircle2 size={24} color="#16A34A" />
                        ) : (
                          <Box
                            sx={{
                              width: 24,
                              height: 24,
                              borderRadius: '50%',
                              backgroundColor:
                                idx === activeStep ? '#2563EB' : '#E5E7EB',
                              color: 'white',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                              fontWeight: 600,
                              fontSize: 12,
                            }}
                          >
                            {idx + 1}
                          </Box>
                        )
                      }
                    >
                      <Stack direction="row" alignItems="center" spacing={2}>
                        <Typography sx={{ fontWeight: 600 }}>{p.phase}</Typography>
                        <Chip
                          size="small"
                          label={`${p.done}/${p.total}`}
                          color={p.done === p.total ? 'success' : 'default'}
                        />
                      </Stack>
                    </StepLabel>
                    <StepContent>
                      <Typography variant="body2" sx={{ color: '#6B7280', mb: 1.5 }}>
                        {PHASE_DESCRIPTIONS[p.phase]}
                      </Typography>
                      <Stack spacing={1}>
                        {p.items.map((item) => (
                          <Box
                            key={item.id}
                            sx={{
                              p: 1.25,
                              border: '1px solid #E5E7EB',
                              borderRadius: 1,
                              backgroundColor: item.done ? '#F0FDF4' : '#FFFFFF',
                            }}
                          >
                            <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 1 }}>
                              <Checkbox
                                size="small"
                                checked={item.done}
                                onChange={() => toggleChecklist(item.id)}
                              />
                              <Box sx={{ flexGrow: 1 }}>
                                <Typography
                                  variant="body2"
                                  sx={{
                                    fontWeight: 500,
                                    textDecoration: item.done ? 'line-through' : 'none',
                                    color: item.done ? '#16A34A' : '#1F2937',
                                  }}
                                >
                                  {item.label}
                                </Typography>
                                {!item.done && (
                                  <TextField
                                    size="small"
                                    placeholder="Blocker (optional)"
                                    value={item.blocker ?? ''}
                                    onChange={(e) =>
                                      setChecklistBlocker(item.id, e.target.value)
                                    }
                                    fullWidth
                                    variant="standard"
                                    sx={{ mt: 0.5 }}
                                  />
                                )}
                              </Box>
                            </Box>
                          </Box>
                        ))}
                      </Stack>
                    </StepContent>
                  </Step>
                ))}
              </Stepper>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Stack spacing={2}>
            <Card variant="outlined">
              <CardContent>
                <Typography variant="caption" sx={{ color: '#6B7280', textTransform: 'uppercase' }}>
                  Readiness Score
                </Typography>
                <Typography
                  variant="h2"
                  sx={{
                    fontWeight: 700,
                    color: readiness.readiness >= 90 ? '#16A34A' : readiness.readiness >= 70 ? '#F59E0B' : '#DC2626',
                  }}
                >
                  {readiness.readiness}%
                </Typography>
                <LinearProgress
                  variant="determinate"
                  value={readiness.readiness}
                  sx={{ height: 8, borderRadius: 1, mt: 1 }}
                  color={readiness.readiness >= 90 ? 'success' : readiness.readiness >= 70 ? 'warning' : 'error'}
                />
                <Stack spacing={0.5} sx={{ mt: 2 }}>
                  <Row label="Controls implemented" value={`${readiness.implemented} / ${readiness.total}`} />
                  <Row label="Open POA&Ms" value={`${readiness.openPoams}`} />
                  <Row label="Overdue POA&Ms" value={`${readiness.overduePoams}`} />
                  <Row label="Evidence coverage" value={`${readiness.evidenceCoverage}%`} />
                  <Row label="Pre-assessment checklist" value={`${readiness.checklistPct}%`} />
                </Stack>
              </CardContent>
            </Card>

            <Card
              variant="outlined"
              sx={{
                borderColor: readyForAudit ? '#16A34A' : '#F59E0B',
                backgroundColor: readyForAudit ? '#F0FDF4' : '#FFFBEB',
              }}
            >
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                  {readyForAudit ? (
                    <Unlock size={20} color="#16A34A" />
                  ) : (
                    <Lock size={20} color="#F59E0B" />
                  )}
                  <Typography variant="subtitle1" sx={{ fontWeight: 700 }}>
                    {readyForAudit ? 'Ready for C3PAO Audit' : 'Not Audit-Ready'}
                  </Typography>
                </Box>
                <Typography variant="body2" sx={{ color: '#475569' }}>
                  {readyForAudit
                    ? 'All Pre-Assessment criteria are met and readiness score is ≥90%. You may schedule the formal assessment.'
                    : 'Complete Pre-Assessment checklist items and reach ≥90% readiness before marking ready for audit.'}
                </Typography>
                <Button
                  variant={readyForAudit ? 'contained' : 'outlined'}
                  color={readyForAudit ? 'success' : 'warning'}
                  disabled={!readyForAudit}
                  sx={{ mt: 1.5 }}
                  fullWidth
                >
                  {readyForAudit ? 'Mark Ready for Audit' : 'Locked'}
                </Button>
              </CardContent>
            </Card>

            {(() => {
              const blockers = checklist.filter((i) => i.blocker && !i.done);
              if (blockers.length === 0) return null;
              return (
                <Alert severity="warning" icon={<AlertTriangle size={18} />}>
                  <Typography variant="subtitle2" sx={{ fontWeight: 700, mb: 0.5 }}>
                    Active blockers
                  </Typography>
                  <Stack spacing={0.5}>
                    {blockers.map((b) => (
                      <Typography key={b.id} variant="caption">
                        • {b.blocker} <span style={{ color: '#92400E' }}>({b.phase})</span>
                      </Typography>
                    ))}
                  </Stack>
                </Alert>
              );
            })()}
          </Stack>
        </Grid>
      </Grid>
    </Box>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
      <Typography variant="caption" sx={{ color: '#6B7280' }}>
        {label}
      </Typography>
      <Typography variant="caption" sx={{ fontWeight: 600 }}>
        {value}
      </Typography>
    </Box>
  );
}
