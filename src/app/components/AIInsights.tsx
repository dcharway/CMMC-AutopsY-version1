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

interface Insight {
  id: string;
  type: 'alert' | 'recommendation' | 'prediction' | 'achievement';
  priority: 'high' | 'medium' | 'low';
  title: string;
  description: string;
  action?: string;
  impact: string;
}

const insights: Insight[] = [
  {
    id: '1',
    type: 'alert',
    priority: 'high',
    title: 'POA&M Timeline Risk Detected',
    description: 'POAM-RA-004 has been open for 156 days. It will exceed the 180-day CMMC limit in 24 days.',
    action: 'Review and expedite remediation',
    impact: 'Assessment blocker if not resolved',
  },
  {
    id: '2',
    type: 'alert',
    priority: 'high',
    title: 'Evidence Expiration Warning',
    description: '2 evidence files will expire within 30 days: AC.1.001_UserAccessList (17 days) and audit logs.',
    action: 'Upload updated evidence',
    impact: 'Control validation failure',
  },
  {
    id: '3',
    type: 'recommendation',
    priority: 'medium',
    title: 'Control Family At Risk',
    description: 'Incident Response (IR) family is only 60% implemented. This is below the recommended 90% threshold.',
    action: 'Prioritize IR controls',
    impact: 'May delay assessment readiness',
  },
  {
    id: '4',
    type: 'prediction',
    priority: 'medium',
    title: 'Assessment Readiness Forecast',
    description: 'Based on current velocity, you will reach 90% readiness in approximately 45 days (June 29, 2026).',
    impact: 'On track for Q3 assessment',
  },
  {
    id: '5',
    type: 'recommendation',
    priority: 'low',
    title: 'Evidence Naming Convention Variance',
    description: '3 evidence files do not follow the standard naming convention. This may slow down assessor review.',
    action: 'Rename files to standard format',
    impact: 'Minor efficiency improvement',
  },
  {
    id: '6',
    type: 'achievement',
    priority: 'low',
    title: 'Milestone Achieved',
    description: 'All Access Control (AC) family controls are now fully implemented with valid evidence.',
    impact: 'Assessment progress: +20%',
  },
  {
    id: '7',
    type: 'alert',
    priority: 'medium',
    title: 'Annual Affirmation Due Soon',
    description: 'Annual compliance affirmation is due in 17 days (June 1, 2026). Prepare executive attestation.',
    action: 'Schedule affirmation submission',
    impact: 'Compliance requirement',
  },
];

const automatedReminders = [
  {
    id: 'r1',
    type: 'evidence',
    message: 'Evidence expiring within 30 days',
    count: 2,
    dueDate: '2026-06-01',
  },
  {
    id: 'r2',
    type: 'poam',
    message: 'POA&M nearing 180-day limit',
    count: 2,
    dueDate: '2026-06-08',
  },
  {
    id: 'r3',
    type: 'affirmation',
    message: 'Annual affirmation due',
    count: 1,
    dueDate: '2026-06-01',
  },
  {
    id: 'r4',
    type: 'control',
    message: 'Control reviews overdue',
    count: 5,
    dueDate: '2026-05-20',
  },
];

export function AIInsights() {
  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high':
        return '#DC2626';
      case 'medium':
        return '#F59E0B';
      case 'low':
        return '#16A34A';
      default:
        return '#6B7280';
    }
  };

  const getTypeIcon = (type: string) => {
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
  };

  const highPriorityInsights = insights.filter(i => i.priority === 'high').length;
  const mediumPriorityInsights = insights.filter(i => i.priority === 'medium').length;

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
        <Brain size={32} color="#7C3AED" style={{ marginRight: 12 }} />
        <Typography variant="h4">
          AI-Powered Insights & Alerts
        </Typography>
      </Box>

      <Grid container spacing={3}>
        {/* Left Column - Insights */}
        <Grid item xs={12} md={8}>
          {/* Priority Summary */}
          <Grid container spacing={2} sx={{ mb: 3 }}>
            <Grid item xs={12} sm={4}>
              <Card sx={{ borderLeft: '4px solid #DC2626' }}>
                <CardContent>
                  <Typography variant="body2" color="text.secondary">
                    High Priority
                  </Typography>
                  <Typography variant="h3" sx={{ color: '#DC2626' }}>
                    {highPriorityInsights}
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
                    {mediumPriorityInsights}
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
                  <Typography variant="h3" sx={{ color: '#16A34A' }}>
                    78%
                  </Typography>
                  <Typography variant="caption">Assessment ready at 90%</Typography>
                </CardContent>
              </Card>
            </Grid>
          </Grid>

          {/* Insights List */}
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2 }}>
                Active Insights
              </Typography>

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
                        borderLeft: `4px solid ${getPriorityColor(insight.priority)}`,
                      }}
                    >
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1, width: '100%' }}>
                        <Box sx={{ color: getPriorityColor(insight.priority) }}>
                          {getTypeIcon(insight.type)}
                        </Box>
                        <Typography variant="subtitle1" sx={{ fontWeight: 600, flex: 1 }}>
                          {insight.title}
                        </Typography>
                        <Chip
                          label={insight.priority.toUpperCase()}
                          size="small"
                          sx={{
                            backgroundColor: getPriorityColor(insight.priority) + '20',
                            color: getPriorityColor(insight.priority),
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
            </CardContent>
          </Card>
        </Grid>

        {/* Right Column - Automated Reminders & Analytics */}
        <Grid item xs={12} md={4}>
          {/* Automated Reminders */}
          <Card sx={{ mb: 3 }}>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <Bell size={20} color="#7C3AED" style={{ marginRight: 8 }} />
                <Typography variant="h6">
                  Automated Reminders
                </Typography>
              </Box>

              <List>
                {automatedReminders.map(reminder => (
                  <ListItem
                    key={reminder.id}
                    sx={{
                      flexDirection: 'column',
                      alignItems: 'flex-start',
                      backgroundColor: '#F9FAFB',
                      borderRadius: 1,
                      mb: 1,
                      p: 1.5,
                    }}
                  >
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, width: '100%', mb: 0.5 }}>
                      <Clock size={16} />
                      <Typography variant="body2" sx={{ fontWeight: 500, flex: 1 }}>
                        {reminder.message}
                      </Typography>
                      <Chip label={reminder.count} size="small" color="warning" />
                    </Box>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                      <Calendar size={14} color="#6B7280" />
                      <Typography variant="caption" color="text.secondary">
                        Due: {reminder.dueDate}
                      </Typography>
                    </Box>
                  </ListItem>
                ))}
              </List>

              <Button variant="outlined" size="small" fullWidth sx={{ mt: 2 }}>
                Configure Alerts
              </Button>
            </CardContent>
          </Card>

          {/* AI Readiness Prediction */}
          <Card sx={{ mb: 3 }}>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <TrendingUp size={20} color="#2563EB" style={{ marginRight: 8 }} />
                <Typography variant="h6">
                  Readiness Forecast
                </Typography>
              </Box>

              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                AI prediction based on current completion velocity
              </Typography>

              <Box sx={{ mb: 2 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
                  <Typography variant="body2">Current Progress</Typography>
                  <Typography variant="body2"><strong>78%</strong></Typography>
                </Box>
                <LinearProgress variant="determinate" value={78} sx={{ height: 8, borderRadius: 1 }} />
              </Box>

              <Divider sx={{ my: 2 }} />

              <Box>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                  Estimated 90% Readiness
                </Typography>
                <Typography variant="h5" sx={{ color: '#16A34A', mb: 1 }}>
                  June 29, 2026
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  45 days from now
                </Typography>
              </Box>

              <Alert severity="success" sx={{ mt: 2 }}>
                On track for Q3 2026 assessment
              </Alert>
            </CardContent>
          </Card>

          {/* Risk Prioritization */}
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <Zap size={20} color="#F59E0B" style={{ marginRight: 8 }} />
                <Typography variant="h6">
                  AI Risk Prioritization
                </Typography>
              </Box>

              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                Top risks to address for faster assessment readiness
              </Typography>

              <List dense>
                <ListItem key="risk-1" sx={{ px: 0 }}>
                  <ListItemIcon sx={{ minWidth: 32 }}>
                    <Box
                      sx={{
                        width: 24,
                        height: 24,
                        borderRadius: '50%',
                        backgroundColor: '#DC2626',
                        color: 'white',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '0.75rem',
                        fontWeight: 600,
                      }}
                    >
                      1
                    </Box>
                  </ListItemIcon>
                  <ListItemText
                    primary="Complete IR controls"
                    secondary="Highest impact on readiness"
                    primaryTypographyProps={{ variant: 'body2', fontWeight: 500 }}
                    secondaryTypographyProps={{ variant: 'caption' }}
                  />
                </ListItem>

                <ListItem key="risk-2" sx={{ px: 0 }}>
                  <ListItemIcon sx={{ minWidth: 32 }}>
                    <Box
                      sx={{
                        width: 24,
                        height: 24,
                        borderRadius: '50%',
                        backgroundColor: '#F59E0B',
                        color: 'white',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '0.75rem',
                        fontWeight: 600,
                      }}
                    >
                      2
                    </Box>
                  </ListItemIcon>
                  <ListItemText
                    primary="Resolve overdue POA&Ms"
                    secondary="Timeline compliance risk"
                    primaryTypographyProps={{ variant: 'body2', fontWeight: 500 }}
                    secondaryTypographyProps={{ variant: 'caption' }}
                  />
                </ListItem>

                <ListItem key="risk-3" sx={{ px: 0 }}>
                  <ListItemIcon sx={{ minWidth: 32 }}>
                    <Box
                      sx={{
                        width: 24,
                        height: 24,
                        borderRadius: '50%',
                        backgroundColor: '#F59E0B',
                        color: 'white',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '0.75rem',
                        fontWeight: 600,
                      }}
                    >
                      3
                    </Box>
                  </ListItemIcon>
                  <ListItemText
                    primary="Update expiring evidence"
                    secondary="Prevent validation failures"
                    primaryTypographyProps={{ variant: 'body2', fontWeight: 500 }}
                    secondaryTypographyProps={{ variant: 'caption' }}
                  />
                </ListItem>
              </List>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
