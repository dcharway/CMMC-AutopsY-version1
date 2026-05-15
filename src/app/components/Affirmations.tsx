import { useMemo } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Button,
  Chip,
  Stack,
  Alert,
  TextField,
  LinearProgress,
} from '@mui/material';
import { ShieldCheck, AlertTriangle, CalendarClock } from 'lucide-react';
import { useGrc, useReadinessScore } from '../store/grcStore';

function daysUntil(date: string) {
  return Math.round((new Date(date).getTime() - Date.now()) / 86400000);
}

export function Affirmations() {
  const { affirmations, updateAffirmation, controls, poams } = useGrc();
  const readiness = useReadinessScore();

  const eligibility = useMemo(() => {
    const unmet = controls.filter(
      (c) =>
        c.status !== 'Implemented' &&
        c.status !== 'Not Applicable' &&
        !poams.some((p) => p.id === c.poamId && p.status !== 'Completed'),
    );
    return { ready: unmet.length === 0, gapControls: unmet };
  }, [controls, poams]);

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" sx={{ fontWeight: 700, mb: 0.5 }}>
        Annual Affirmations
      </Typography>
      <Typography variant="body2" sx={{ color: '#6B7280', mb: 3 }}>
        Submit and track yearly attestations that all CMMC controls are met or covered by an
        approved POA&amp;M.
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <Stack spacing={2}>
            {affirmations.map((a) => {
              const due = daysUntil(a.dueDate);
              const isOverdue = !a.submittedDate && due < 0;
              const isSoon = !a.submittedDate && due >= 0 && due <= 90;
              return (
                <Card key={a.id} variant="outlined">
                  <CardContent>
                    <Box
                      sx={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'flex-start',
                        mb: 2,
                      }}
                    >
                      <Box>
                        <Typography variant="overline" sx={{ color: '#6B7280' }}>
                          {a.id}
                        </Typography>
                        <Typography variant="h5" sx={{ fontWeight: 700 }}>
                          {a.year} Annual Affirmation
                        </Typography>
                      </Box>
                      <Chip
                        label={
                          a.submittedDate
                            ? 'Submitted'
                            : isOverdue
                              ? 'Overdue'
                              : 'Pending'
                        }
                        color={
                          a.submittedDate ? 'success' : isOverdue ? 'error' : 'warning'
                        }
                      />
                    </Box>

                    {isOverdue && (
                      <Alert severity="error" sx={{ mb: 2 }} icon={<AlertTriangle size={18} />}>
                        Affirmation is {Math.abs(due)} days overdue. Submit immediately.
                      </Alert>
                    )}
                    {isSoon && !isOverdue && (
                      <Alert
                        severity="warning"
                        sx={{ mb: 2 }}
                        icon={<CalendarClock size={18} />}
                      >
                        Affirmation due in {due} days.
                      </Alert>
                    )}

                    <Grid container spacing={2}>
                      <Grid item xs={12} md={6}>
                        <TextField
                          size="small"
                          label="Affirmed by (Senior Official)"
                          value={a.affirmedBy}
                          onChange={(e) =>
                            updateAffirmation(a.id, { affirmedBy: e.target.value })
                          }
                          fullWidth
                        />
                      </Grid>
                      <Grid item xs={12} md={6}>
                        <TextField
                          size="small"
                          label="Due date"
                          type="date"
                          value={a.dueDate}
                          onChange={(e) => updateAffirmation(a.id, { dueDate: e.target.value })}
                          fullWidth
                          InputLabelProps={{ shrink: true }}
                        />
                      </Grid>
                      <Grid item xs={12}>
                        <TextField
                          size="small"
                          label="Notes"
                          value={a.notes}
                          onChange={(e) => updateAffirmation(a.id, { notes: e.target.value })}
                          fullWidth
                          multiline
                          minRows={2}
                        />
                      </Grid>
                    </Grid>

                    <Box
                      sx={{
                        mt: 2,
                        p: 2,
                        backgroundColor: '#F9FAFB',
                        borderRadius: 1,
                        border: '1px solid #E5E7EB',
                      }}
                    >
                      <Typography variant="caption" sx={{ color: '#6B7280' }}>
                        Affirmation statement
                      </Typography>
                      <Typography variant="body2" sx={{ mt: 0.5 }}>
                        I affirm that all 110 CMMC Level 2 (NIST SP 800-171) practices applicable
                        to our system are currently <strong>implemented</strong>, or have an{' '}
                        <strong>approved POA&amp;M with remediation within 180 days</strong>. I
                        attest the information provided is accurate as of the submission date.
                      </Typography>
                    </Box>

                    <Stack
                      direction="row"
                      spacing={1}
                      sx={{ mt: 2 }}
                      justifyContent="flex-end"
                    >
                      {a.submittedDate && (
                        <Chip
                          icon={<ShieldCheck size={14} />}
                          label={`Submitted ${a.submittedDate}`}
                          color="success"
                          variant="outlined"
                        />
                      )}
                      {!a.submittedDate ? (
                        <Button
                          variant="contained"
                          startIcon={<ShieldCheck size={16} />}
                          disabled={!a.affirmedBy || !eligibility.ready}
                          onClick={() =>
                            updateAffirmation(a.id, {
                              submittedDate: new Date().toISOString().slice(0, 10),
                              status: 'Submitted',
                            })
                          }
                        >
                          Submit Affirmation
                        </Button>
                      ) : (
                        <Button
                          variant="outlined"
                          color="warning"
                          onClick={() =>
                            updateAffirmation(a.id, {
                              submittedDate: null,
                              status: 'Pending',
                            })
                          }
                        >
                          Revoke
                        </Button>
                      )}
                    </Stack>
                  </CardContent>
                </Card>
              );
            })}
          </Stack>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card variant="outlined">
            <CardContent>
              <Typography variant="subtitle1" sx={{ fontWeight: 700, mb: 1.5 }}>
                Eligibility Check
              </Typography>
              <Box sx={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
                <Typography variant="caption" sx={{ color: '#6B7280' }}>
                  Readiness
                </Typography>
                <Typography
                  variant="h5"
                  sx={{
                    fontWeight: 700,
                    color:
                      readiness.readiness >= 90
                        ? '#16A34A'
                        : readiness.readiness >= 70
                          ? '#F59E0B'
                          : '#DC2626',
                  }}
                >
                  {readiness.readiness}%
                </Typography>
              </Box>
              <LinearProgress
                variant="determinate"
                value={readiness.readiness}
                sx={{ height: 6, borderRadius: 1, mt: 0.5 }}
              />
              <Box sx={{ mt: 2 }}>
                {eligibility.ready ? (
                  <Alert severity="success" icon={<ShieldCheck size={18} />}>
                    All controls are implemented, N/A, or covered by an active POA&amp;M. You can
                    submit the affirmation.
                  </Alert>
                ) : (
                  <Alert severity="warning" icon={<AlertTriangle size={18} />}>
                    {eligibility.gapControls.length} control
                    {eligibility.gapControls.length !== 1 && 's'} not yet implemented and missing a
                    POA&amp;M. Resolve before submission.
                  </Alert>
                )}
              </Box>

              {eligibility.gapControls.length > 0 && (
                <Box sx={{ mt: 2, maxHeight: 200, overflow: 'auto' }}>
                  <Typography variant="caption" sx={{ color: '#6B7280', fontWeight: 600 }}>
                    GAP CONTROLS
                  </Typography>
                  <Stack spacing={0.5} sx={{ mt: 0.5 }}>
                    {eligibility.gapControls.slice(0, 12).map((c) => (
                      <Typography
                        key={c.id}
                        variant="caption"
                        sx={{ color: '#475569', fontFamily: 'monospace' }}
                      >
                        {c.id} · {c.status}
                      </Typography>
                    ))}
                    {eligibility.gapControls.length > 12 && (
                      <Typography variant="caption" sx={{ color: '#6B7280' }}>
                        … and {eligibility.gapControls.length - 12} more
                      </Typography>
                    )}
                  </Stack>
                </Box>
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
