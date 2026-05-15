import { useMemo } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Chip,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  LinearProgress,
  Alert,
  Button,
  Divider,
} from '@mui/material';
import {
  Brain,
  TrendingUp,
  AlertTriangle,
  Clock,
  Target,
  Zap,
  CheckCircle,
  Bell,
  Calendar,
} from 'lucide-react';
import { controlFamilies } from '../data/cmmcControls';
import {
  useGrc,
  useReadinessScore,
  computeEvidenceStatus,
  computePoamDerivedStatus,
} from '../store/grcStore';

interface Insight {
  id: string;
  type: 'alert' | 'recommendation' | 'prediction' | 'achievement';
  priority: 'high' | 'medium' | 'low';
  title: string;
  description: string;
  action?: string;
  impact: string;
}

const PRIORITY_COLOR = { high: '#DC2626', medium: '#F59E0B', low: '#16A34A' };

function typeIcon(type: Insight['type']) {
  switch (type) {
    case 'alert':
      return <AlertTriangle size={20} />;
    case 'recommendation':
      return <Target size={20} />;
    case 'prediction':
      return <TrendingUp size={20} />;
    case 'achievement':
      return <CheckCircle size={20} />;
    default:
      return <Zap size={20} />;
  }
}

export function AIInsights() {
  const { controls, poams, evidence, affirmations } = useGrc();
  const readiness = useReadinessScore();

  const insights = useMemo<Insight[]>(() => {
    const out: Insight[] = [];

    // POA&M nearing 180-day limit
    const nearLimit = poams.filter((p) => {
      const status = computePoamDerivedStatus(p);
      const ageDays =
        (Date.now() - new Date(p.createdDate).getTime()) / 86400000;
      return status !== 'Completed' && ageDays > 150;
    });
    nearLimit.forEach((p) => {
      const ageDays = Math.round(
        (Date.now() - new Date(p.createdDate).getTime()) / 86400000,
      );
      out.push({
        id: `poam-180-${p.id}`,
        type: 'alert',
        priority: 'high',
        title: 'POA&M approaching 180-day limit',
        description: `${p.id} (control ${p.controlId}) has been open for ${ageDays} days. CMMC requires remediation within 180 days.`,
        action: 'Open POA&M Tracker',
        impact: 'Assessment blocker if not resolved',
      });
    });

    // Overdue POA&Ms
    const overduePoams = poams.filter(
      (p) => computePoamDerivedStatus(p) === 'Overdue',
    );
    if (overduePoams.length > 0) {
      out.push({
        id: 'overdue-poams',
        type: 'alert',
        priority: 'high',
        title: `${overduePoams.length} overdue POA&M${overduePoams.length !== 1 ? 's' : ''}`,
        description: overduePoams
          .slice(0, 3)
          .map((p) => `${p.id} (${p.controlId})`)
          .join(', '),
        action: 'Review POA&Ms',
        impact: 'Risk of remediation timeline violation',
      });
    }

    // Expired / expiring evidence
    const expired = evidence.filter((e) => computeEvidenceStatus(e) === 'Expired');
    const expiringSoon = evidence.filter(
      (e) => computeEvidenceStatus(e) === 'Expiring Soon',
    );
    if (expired.length > 0) {
      out.push({
        id: 'expired-ev',
        type: 'alert',
        priority: 'high',
        title: `${expired.length} expired evidence artifact${expired.length !== 1 ? 's' : ''}`,
        description:
          'Expired evidence will fail control validation. Refresh and re-upload before the assessment.',
        action: 'Open Evidence Repository',
        impact: 'Control validation failure',
      });
    }
    if (expiringSoon.length > 0) {
      out.push({
        id: 'expiring-ev',
        type: 'alert',
        priority: 'medium',
        title: `${expiringSoon.length} evidence file${expiringSoon.length !== 1 ? 's' : ''} expiring within 30 days`,
        description: expiringSoon
          .slice(0, 3)
          .map((e) => e.fileName)
          .join(', '),
        action: 'Upload updated evidence',
        impact: 'Avoid last-minute scramble before assessment',
      });
    }

    // Naming convention issues
    const misnamed = evidence.filter((e) => !e.validNaming).length;
    if (misnamed > 0) {
      out.push({
        id: 'naming-convention',
        type: 'recommendation',
        priority: 'low',
        title: 'Evidence naming convention variance',
        description: `${misnamed} evidence file${misnamed !== 1 ? 's' : ''} do not follow the ControlID_Description_YYYY-MM-DD pattern.`,
        action: 'Rename to standard format',
        impact: 'Speeds up assessor review',
      });
    }

    // Implemented controls without evidence
    const noEvidence = controls.filter(
      (c) => c.status === 'Implemented' && c.evidenceIds.length === 0,
    );
    if (noEvidence.length > 0) {
      out.push({
        id: 'no-evidence',
        type: 'recommendation',
        priority: 'medium',
        title: `${noEvidence.length} implemented control${noEvidence.length !== 1 ? 's' : ''} missing evidence`,
        description:
          'A control marked Implemented requires audit-proof evidence. Upload at least one artifact per implemented control.',
        action: 'Upload evidence',
        impact: 'Required for C3PAO acceptance',
      });
    }

    // Underperforming families
    controlFamilies.forEach((fam) => {
      const fc = controls.filter((c) => c.familyCode === fam.code);
      if (fc.length === 0) return;
      const impl = fc.filter(
        (c) => c.status === 'Implemented' || c.status === 'Not Applicable',
      ).length;
      const pct = (impl / fc.length) * 100;
      if (pct < 70) {
        out.push({
          id: `family-${fam.code}`,
          type: 'recommendation',
          priority: pct < 40 ? 'high' : 'medium',
          title: `${fam.code} – ${fam.name} family at ${Math.round(pct)}%`,
          description: `Only ${impl} of ${fc.length} controls are implemented. Prioritize this family to lift readiness.`,
          action: `Focus on ${fam.code}`,
          impact: 'Lifts overall readiness score',
        });
      } else if (pct === 100 && fc.length > 1) {
        out.push({
          id: `family-${fam.code}-done`,
          type: 'achievement',
          priority: 'low',
          title: `${fam.name} family fully implemented`,
          description: `All ${fc.length} controls in ${fam.code} are implemented or N/A. Great work.`,
          impact: 'Assessment progress momentum',
        });
      }
    });

    // Affirmation due
    affirmations.forEach((a) => {
      if (a.submittedDate) return;
      const due = Math.round(
        (new Date(a.dueDate).getTime() - Date.now()) / 86400000,
      );
      if (due <= 90) {
        out.push({
          id: `aff-${a.id}`,
          type: 'alert',
          priority: due < 0 ? 'high' : due <= 30 ? 'high' : 'medium',
          title:
            due < 0
              ? `Annual affirmation ${Math.abs(due)} days overdue`
              : `Annual affirmation due in ${due} days`,
          description: `${a.year} CMMC affirmation has not been submitted yet.`,
          action: 'Submit affirmation',
          impact: 'Compliance requirement',
        });
      }
    });

    // Forecast
    if (readiness.readiness < 90 && readiness.readiness > 0) {
      const remaining = 90 - readiness.readiness;
      const days = Math.max(7, remaining * 3);
      out.push({
        id: 'forecast',
        type: 'prediction',
        priority: 'medium',
        title: 'Assessment readiness forecast',
        description: `At current velocity, you should reach 90% readiness in approximately ${days} day${days !== 1 ? 's' : ''}.`,
        impact: 'Plan assessment scheduling',
      });
    }

    return out;
  }, [controls, poams, evidence, affirmations, readiness]);

  const highCount = insights.filter((i) => i.priority === 'high').length;
  const mediumCount = insights.filter((i) => i.priority === 'medium').length;

  // Compute live automated reminders
  const reminders = useMemo(() => {
    const expiring = evidence.filter((e) => computeEvidenceStatus(e) !== 'Valid');
    const near180 = poams.filter((p) => {
      const status = computePoamDerivedStatus(p);
      const age = (Date.now() - new Date(p.createdDate).getTime()) / 86400000;
      return status !== 'Completed' && age > 150;
    });
    const overdueControls = controls.filter((c) => {
      if (!c.dueDate || c.status === 'Implemented' || c.status === 'Not Applicable')
        return false;
      return new Date(c.dueDate).getTime() < Date.now();
    });
    const affPending = affirmations.filter((a) => !a.submittedDate);

    return [
      { id: 'r-ev', message: 'Evidence expiring within 30 days', count: expiring.length },
      { id: 'r-poam', message: 'POA&Ms nearing 180-day limit', count: near180.length },
      { id: 'r-aff', message: 'Annual affirmations pending', count: affPending.length },
      { id: 'r-controls', message: 'Control reviews overdue', count: overdueControls.length },
    ];
  }, [evidence, poams, controls, affirmations]);

  // Risk prioritization: top 3 highest-impact actions
  const prioritized = useMemo(() => {
    const items: { id: string; label: string; rationale: string; color: string }[] = [];
    const failedFam = controlFamilies
      .map((f) => {
        const fc = controls.filter((c) => c.familyCode === f.code);
        const impl = fc.filter(
          (c) => c.status === 'Implemented' || c.status === 'Not Applicable',
        ).length;
        return { f, pct: fc.length ? (impl / fc.length) * 100 : 100 };
      })
      .filter((x) => x.pct < 70)
      .sort((a, b) => a.pct - b.pct);
    if (failedFam.length) {
      items.push({
        id: 'p1',
        label: `Complete ${failedFam[0].f.code} controls`,
        rationale: `Family is at ${Math.round(failedFam[0].pct)}% — highest impact on readiness`,
        color: '#DC2626',
      });
    }
    const overdue = poams.filter(
      (p) => computePoamDerivedStatus(p) === 'Overdue',
    ).length;
    if (overdue > 0) {
      items.push({
        id: 'p2',
        label: `Resolve ${overdue} overdue POA&M${overdue !== 1 ? 's' : ''}`,
        rationale: 'Timeline compliance risk',
        color: '#F59E0B',
      });
    }
    const expiring = evidence.filter(
      (e) => computeEvidenceStatus(e) !== 'Valid',
    ).length;
    if (expiring > 0) {
      items.push({
        id: 'p3',
        label: `Refresh ${expiring} expiring evidence file${expiring !== 1 ? 's' : ''}`,
        rationale: 'Prevent validation failures',
        color: '#F59E0B',
      });
    }
    return items.slice(0, 3);
  }, [controls, poams, evidence]);

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
        <Brain size={32} color="#7C3AED" style={{ marginRight: 12 }} />
        <Typography variant="h4">AI-Powered Insights &amp; Alerts</Typography>
      </Box>

      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <Grid container spacing={2} sx={{ mb: 3 }}>
            <Grid item xs={12} sm={4}>
              <Card sx={{ borderLeft: '4px solid #DC2626' }}>
                <CardContent>
                  <Typography variant="body2" color="text.secondary">
                    High Priority
                  </Typography>
                  <Typography variant="h3" sx={{ color: '#DC2626' }}>
                    {highCount}
                  </Typography>
                  <Typography variant="caption">Require immediate action</Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} sm={4}>
              <Card sx={{ borderLeft: '4px solid #F59E0B' }}>
                <CardContent>
                  <Typography variant="body2" color="text.secondary">
                    Medium Priority
                  </Typography>
                  <Typography variant="h3" sx={{ color: '#F59E0B' }}>
                    {mediumCount}
                  </Typography>
                  <Typography variant="caption">Address soon</Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} sm={4}>
              <Card sx={{ borderLeft: '4px solid #16A34A' }}>
                <CardContent>
                  <Typography variant="body2" color="text.secondary">
                    Readiness Score
                  </Typography>
                  <Typography variant="h3" sx={{ color: readiness.readiness >= 90 ? '#16A34A' : readiness.readiness >= 70 ? '#F59E0B' : '#DC2626' }}>
                    {readiness.readiness}%
                  </Typography>
                  <Typography variant="caption">Assessment ready at 90%</Typography>
                </CardContent>
              </Card>
            </Grid>
          </Grid>

          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2 }}>
                Active Insights ({insights.length})
              </Typography>
              {insights.length === 0 ? (
                <Alert severity="success" icon={<CheckCircle size={18} />}>
                  No active insights — everything looks healthy. Add controls and evidence to
                  surface AI-generated recommendations.
                </Alert>
              ) : (
                <List>
                  {insights.map((insight, index) => (
                    <Box key={insight.id}>
                      <ListItem
                        sx={{
                          flexDirection: 'column',
                          alignItems: 'flex-start',
                          backgroundColor:
                            insight.priority === 'high'
                              ? '#FEF2F2'
                              : insight.priority === 'medium'
                                ? '#FFFBEB'
                                : '#F0FDF4',
                          borderRadius: 1,
                          mb: 2,
                          borderLeft: `4px solid ${PRIORITY_COLOR[insight.priority]}`,
                        }}
                      >
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1, width: '100%' }}>
                          <Box sx={{ color: PRIORITY_COLOR[insight.priority] }}>
                            {typeIcon(insight.type)}
                          </Box>
                          <Typography variant="subtitle1" sx={{ fontWeight: 600, flex: 1 }}>
                            {insight.title}
                          </Typography>
                          <Chip
                            label={insight.priority.toUpperCase()}
                            size="small"
                            sx={{
                              backgroundColor: PRIORITY_COLOR[insight.priority] + '20',
                              color: PRIORITY_COLOR[insight.priority],
                              fontWeight: 600,
                            }}
                          />
                        </Box>
                        <Typography variant="body2" sx={{ mb: 1, color: 'text.secondary' }}>
                          {insight.description}
                        </Typography>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, width: '100%' }}>
                          <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                            Impact: <strong>{insight.impact}</strong>
                          </Typography>
                          {insight.action && (
                            <Button size="small" variant="outlined" sx={{ ml: 'auto' }}>
                              {insight.action}
                            </Button>
                          )}
                        </Box>
                      </ListItem>
                      {index < insights.length - 1 && <Divider />}
                    </Box>
                  ))}
                </List>
              )}
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card sx={{ mb: 3 }}>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <Bell size={20} color="#7C3AED" style={{ marginRight: 8 }} />
                <Typography variant="h6">Automated Reminders</Typography>
              </Box>
              <List>
                {reminders.map((r) => (
                  <ListItem
                    key={r.id}
                    sx={{
                      flexDirection: 'column',
                      alignItems: 'flex-start',
                      backgroundColor: '#F9FAFB',
                      borderRadius: 1,
                      mb: 1,
                      p: 1.5,
                    }}
                  >
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, width: '100%' }}>
                      <Clock size={16} />
                      <Typography variant="body2" sx={{ fontWeight: 500, flex: 1 }}>
                        {r.message}
                      </Typography>
                      <Chip
                        label={r.count}
                        size="small"
                        color={r.count > 0 ? 'warning' : 'default'}
                      />
                    </Box>
                  </ListItem>
                ))}
              </List>
              <Button variant="outlined" size="small" fullWidth sx={{ mt: 2 }}>
                Configure Alerts
              </Button>
            </CardContent>
          </Card>

          <Card sx={{ mb: 3 }}>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <TrendingUp size={20} color="#2563EB" style={{ marginRight: 8 }} />
                <Typography variant="h6">Readiness Forecast</Typography>
              </Box>
              <Box sx={{ mb: 2 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
                  <Typography variant="body2">Current Progress</Typography>
                  <Typography variant="body2">
                    <strong>{readiness.readiness}%</strong>
                  </Typography>
                </Box>
                <LinearProgress
                  variant="determinate"
                  value={readiness.readiness}
                  sx={{ height: 8, borderRadius: 1 }}
                />
              </Box>
              <Divider sx={{ my: 2 }} />
              <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                Estimated 90% Readiness
              </Typography>
              {(() => {
                const days = Math.max(0, (90 - readiness.readiness) * 3);
                const target = new Date(Date.now() + days * 86400000);
                return (
                  <>
                    <Typography variant="h5" sx={{ color: '#16A34A', mb: 1 }}>
                      {target.toLocaleDateString(undefined, { dateStyle: 'medium' })}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      ~{days} days from now
                    </Typography>
                  </>
                );
              })()}
            </CardContent>
          </Card>

          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <Zap size={20} color="#F59E0B" style={{ marginRight: 8 }} />
                <Typography variant="h6">AI Risk Prioritization</Typography>
              </Box>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                Top risks to address for faster assessment readiness
              </Typography>
              {prioritized.length === 0 ? (
                <Alert severity="success">No critical risks identified.</Alert>
              ) : (
                <List dense>
                  {prioritized.map((p, idx) => (
                    <ListItem key={p.id} sx={{ px: 0 }}>
                      <ListItemIcon sx={{ minWidth: 32 }}>
                        <Box
                          sx={{
                            width: 24,
                            height: 24,
                            borderRadius: '50%',
                            backgroundColor: p.color,
                            color: 'white',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            fontSize: '0.75rem',
                            fontWeight: 600,
                          }}
                        >
                          {idx + 1}
                        </Box>
                      </ListItemIcon>
                      <ListItemText
                        primary={p.label}
                        secondary={p.rationale}
                        primaryTypographyProps={{ variant: 'body2', fontWeight: 500 }}
                        secondaryTypographyProps={{ variant: 'caption' }}
                      />
                    </ListItem>
                  ))}
                </List>
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
