import { useMemo } from 'react';
import { BarChart, Bar, Cell, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Legend, LineChart, Line, Area, AreaChart } from 'recharts';
import { Card, CardContent, Grid, Box, Typography, Chip, LinearProgress } from '@mui/material';
import { CheckCircle, AlertTriangle, XCircle, Clock, FileText, AlertCircle, TrendingUp, TrendingDown } from 'lucide-react';
import { controlFamilies, controls, poamList, evidenceList, assessmentData } from '../data/cmmcControls';

export function EnhancedDashboard() {
  const kpis = useMemo(() => {
    const totalControls = controls.length;
    const implementedControls = controls.filter(c => c.status === 'Implemented').length;
    const inProgressControls = controls.filter(c => c.status === 'In Progress').length;
    const notStartedControls = controls.filter(c => c.status === 'Not Started').length;
    const openPoams = poamList.filter(p => p.status === 'Open' || p.status === 'In Progress').length;
    const expiringEvidence = evidenceList.filter(e => e.status === 'Expiring Soon' || e.status === 'Expired').length;

    const sprsScore = implementedControls;

    return {
      totalControls,
      implementedControls,
      inProgressControls,
      notStartedControls,
      openPoams,
      expiringEvidence,
      sprsScore,
      compliancePercentage: Math.round((implementedControls / totalControls) * 100),
    };
  }, []);

  const familyStatusData = useMemo(() => {
    return controlFamilies.map(family => {
      const familyControls = controls.filter(c => c.familyCode === family.code);
      const implemented = familyControls.filter(c => c.status === 'Implemented').length;
      const total = familyControls.length;
      const percentage = Math.round((implemented / total) * 100);

      let status = 'Met';
      let color = '#16A34A';

      if (percentage < 70) {
        status = 'Failed';
        color = '#DC2626';
      } else if (percentage < 100) {
        status = 'At Risk';
        color = '#F59E0B';
      }

      return {
        name: family.code,
        fullName: family.name,
        implemented,
        total,
        percentage,
        status,
        color,
      };
    });
  }, []);

  const statusDistribution = useMemo(() => [
    { name: 'Implemented', value: kpis.implementedControls, color: '#16A34A' },
    { name: 'In Progress', value: kpis.inProgressControls, color: '#F59E0B' },
    { name: 'Not Started', value: kpis.notStartedControls, color: '#DC2626' },
  ], [kpis]);

  const riskDistribution = useMemo(() => {
    const high = poamList.filter(p => p.riskLevel === 'High').length;
    const medium = poamList.filter(p => p.riskLevel === 'Medium').length;
    const low = poamList.filter(p => p.riskLevel === 'Low').length;

    return [
      { name: 'High', value: high, color: '#DC2626' },
      { name: 'Medium', value: medium, color: '#F59E0B' },
      { name: 'Low', value: low, color: '#16A34A' },
    ];
  }, []);

  // Simulated trend data for compliance progress over time
  const complianceTrend = [
    { month: 'Jan', compliance: 45, controls: 50 },
    { month: 'Feb', compliance: 58, controls: 64 },
    { month: 'Mar', compliance: 65, controls: 72 },
    { month: 'Apr', compliance: 72, controls: 79 },
    { month: 'May', compliance: 78, controls: 86 },
  ];

  // Simulated evidence trend
  const evidenceTrend = [
    { month: 'Jan', valid: 40, expiring: 8, expired: 2 },
    { month: 'Feb', valid: 55, expiring: 6, expired: 1 },
    { month: 'Mar', valid: 68, expiring: 5, expired: 2 },
    { month: 'Apr', valid: 75, expiring: 4, expired: 1 },
    { month: 'May', valid: 82, expiring: 2, expired: 0 },
  ];

  // POA&M remediation velocity
  const poamVelocity = [
    { week: 'Week 1', opened: 2, closed: 1, total: 8 },
    { week: 'Week 2', opened: 1, closed: 2, total: 7 },
    { week: 'Week 3', opened: 0, closed: 1, total: 6 },
    { week: 'Week 4', opened: 1, closed: 2, total: 5 },
  ];

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" sx={{ mb: 3 }}>
        CMMC Level 2 Executive Dashboard
      </Typography>

      {/* KPI Cards */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                <CheckCircle size={24} color="#16A34A" />
                <Typography variant="h6" sx={{ ml: 1 }}>
                  SPRS Score
                </Typography>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 1 }}>
                <Typography variant="h3" sx={{ color: '#16A34A' }}>
                  {kpis.sprsScore}
                </Typography>
                <Box sx={{ display: 'flex', alignItems: 'center', color: '#16A34A' }}>
                  <TrendingUp size={16} />
                  <Typography variant="caption" sx={{ ml: 0.5 }}>+8</Typography>
                </Box>
              </Box>
              <Typography variant="body2" color="text.secondary">
                out of 110 points
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                <FileText size={24} color="#2563EB" />
                <Typography variant="h6" sx={{ ml: 1 }}>
                  Controls Met
                </Typography>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 1 }}>
                <Typography variant="h3">
                  {kpis.implementedControls}/{kpis.totalControls}
                </Typography>
                <Box sx={{ display: 'flex', alignItems: 'center', color: '#16A34A' }}>
                  <TrendingUp size={16} />
                  <Typography variant="caption" sx={{ ml: 0.5 }}>+6%</Typography>
                </Box>
              </Box>
              <Typography variant="body2" color="text.secondary">
                {kpis.compliancePercentage}% compliance
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                <AlertTriangle size={24} color="#F59E0B" />
                <Typography variant="h6" sx={{ ml: 1 }}>
                  Open POA&Ms
                </Typography>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 1 }}>
                <Typography variant="h3" sx={{ color: '#F59E0B' }}>
                  {kpis.openPoams}
                </Typography>
                <Box sx={{ display: 'flex', alignItems: 'center', color: '#16A34A' }}>
                  <TrendingDown size={16} />
                  <Typography variant="caption" sx={{ ml: 0.5 }}>-2</Typography>
                </Box>
              </Box>
              <Typography variant="body2" color="text.secondary">
                requires attention
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                <Clock size={24} color="#DC2626" />
                <Typography variant="h6" sx={{ ml: 1 }}>
                  Evidence Issues
                </Typography>
              </Box>
              <Typography variant="h3" sx={{ color: '#DC2626' }}>
                {kpis.expiringEvidence}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                expiring or expired
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Assessment Readiness */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Typography variant="h6" sx={{ mb: 2 }}>
            Assessment Readiness
          </Typography>
          <Box sx={{ mb: 2 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
              <Typography variant="body2">
                Phase: <strong>{assessmentData.phase}</strong>
              </Typography>
              <Typography variant="body2">
                <strong>{assessmentData.readiness}%</strong> Ready
              </Typography>
            </Box>
            <LinearProgress
              variant="determinate"
              value={assessmentData.readiness}
              sx={{
                height: 10,
                borderRadius: 1,
                backgroundColor: '#E5E7EB',
                '& .MuiLinearProgress-bar': {
                  backgroundColor: assessmentData.readiness >= 90 ? '#16A34A' : assessmentData.readiness >= 70 ? '#F59E0B' : '#DC2626',
                }
              }}
            />
          </Box>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Checklist: {assessmentData.completedChecklist}/{assessmentData.totalChecklist} items completed
          </Typography>

          {assessmentData.blockers.length > 0 && (
            <Box>
              <Typography variant="subtitle2" sx={{ mb: 1, display: 'flex', alignItems: 'center' }}>
                <AlertCircle size={18} color="#DC2626" style={{ marginRight: 8 }} />
                Blockers
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                {assessmentData.blockers.map((blocker, index) => (
                  <Chip
                    key={index}
                    label={blocker}
                    size="small"
                    color="error"
                    variant="outlined"
                  />
                ))}
              </Box>
            </Box>
          )}
        </CardContent>
      </Card>

      {/* Trend Charts Row */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        {/* Compliance Trend */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2 }}>
                Compliance Progress Trend
              </Typography>
              <ResponsiveContainer width="100%" height={250}>
                <AreaChart data={complianceTrend}>
                  <CartesianGrid key="grid-compliance" strokeDasharray="3 3" />
                  <XAxis key="xaxis-compliance" dataKey="month" />
                  <YAxis key="yaxis-compliance" />
                  <Tooltip key="tooltip-compliance" />
                  <Area key="area-compliance" type="monotone" dataKey="compliance" stroke="#2563EB" fill="#DBEAFE" name="Compliance %" />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </Grid>

        {/* POA&M Burndown */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2 }}>
                POA&M Remediation Velocity
              </Typography>
              <ResponsiveContainer width="100%" height={250}>
                <LineChart data={poamVelocity}>
                  <CartesianGrid key="grid-poam" strokeDasharray="3 3" />
                  <XAxis key="xaxis-poam" dataKey="week" />
                  <YAxis key="yaxis-poam" />
                  <Tooltip key="tooltip-poam" />
                  <Legend key="legend-poam" />
                  <Line key="line-total" type="monotone" dataKey="total" stroke="#DC2626" name="Open POA&Ms" strokeWidth={2} />
                  <Line key="line-closed" type="monotone" dataKey="closed" stroke="#16A34A" name="Closed" strokeWidth={2} />
                  <Line key="line-opened" type="monotone" dataKey="opened" stroke="#F59E0B" name="Opened" strokeWidth={2} />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </Grid>

        {/* Evidence Trend */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2 }}>
                Evidence Status Trend
              </Typography>
              <ResponsiveContainer width="100%" height={250}>
                <AreaChart data={evidenceTrend}>
                  <CartesianGrid key="grid-evidence" strokeDasharray="3 3" />
                  <XAxis key="xaxis-evidence" dataKey="month" />
                  <YAxis key="yaxis-evidence" />
                  <Tooltip key="tooltip-evidence" />
                  <Legend key="legend-evidence" />
                  <Area key="area-valid" type="monotone" dataKey="valid" stackId="1" stroke="#16A34A" fill="#16A34A" name="Valid" />
                  <Area key="area-expiring" type="monotone" dataKey="expiring" stackId="1" stroke="#F59E0B" fill="#F59E0B" name="Expiring Soon" />
                  <Area key="area-expired" type="monotone" dataKey="expired" stackId="1" stroke="#DC2626" fill="#DC2626" name="Expired" />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </Grid>

        {/* Status Distribution Pie */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2 }}>
                Control Status Distribution
              </Typography>
              <ResponsiveContainer width="100%" height={250}>
                <PieChart>
                  <Pie
                    key="pie-status"
                    data={statusDistribution}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, value, percent }) => `${name}: ${value} (${(percent * 100).toFixed(0)}%)`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {statusDistribution.map((entry) => (
                      <Cell key={`pie-cell-${entry.name}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip key="tooltip-pie-status" />
                </PieChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Control Family Heatmap */}
      <Card>
        <CardContent>
          <Typography variant="h6" sx={{ mb: 3 }}>
            Control Family Status Heatmap
          </Typography>
          <ResponsiveContainer width="100%" height={400}>
            <BarChart
              data={familyStatusData}
              layout="vertical"
              margin={{ top: 5, right: 30, left: 120, bottom: 5 }}
            >
              <CartesianGrid key="grid-heatmap" strokeDasharray="3 3" />
              <XAxis key="xaxis-heatmap" type="number" domain={[0, 100]} />
              <YAxis
                key="yaxis-heatmap"
                dataKey="name"
                type="category"
                tick={{ fontSize: 12 }}
              />
              <Tooltip
                key="tooltip-heatmap"
                content={({ active, payload }) => {
                  if (active && payload && payload.length) {
                    const data = payload[0].payload;
                    return (
                      <Box sx={{
                        backgroundColor: 'white',
                        border: '1px solid #ccc',
                        p: 2,
                        borderRadius: 1,
                      }}>
                        <Typography variant="subtitle2">{data.fullName}</Typography>
                        <Typography variant="body2">
                          Implemented: {data.implemented}/{data.total}
                        </Typography>
                        <Typography variant="body2">
                          Status: <strong>{data.status}</strong>
                        </Typography>
                        <Typography variant="body2">
                          Completion: {data.percentage}%
                        </Typography>
                      </Box>
                    );
                  }
                  return null;
                }}
              />
              <Bar key="bar-heatmap" dataKey="percentage" radius={[0, 4, 4, 0]}>
                {familyStatusData.map((entry) => (
                  <Cell key={`bar-cell-${entry.name}`} fill={entry.color} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>

          {/* Legend */}
          <Box sx={{ display: 'flex', justifyContent: 'center', gap: 3, mt: 2 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Box sx={{ width: 16, height: 16, backgroundColor: '#16A34A', borderRadius: 1 }} />
              <Typography variant="body2">Met (100%)</Typography>
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Box sx={{ width: 16, height: 16, backgroundColor: '#F59E0B', borderRadius: 1 }} />
              <Typography variant="body2">At Risk (70-99%)</Typography>
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Box sx={{ width: 16, height: 16, backgroundColor: '#DC2626', borderRadius: 1 }} />
              <Typography variant="body2">Failed (&lt;70%)</Typography>
            </Box>
          </Box>
        </CardContent>
      </Card>
    </Box>
  );
}
