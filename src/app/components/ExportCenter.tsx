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

interface ExportItem {
  id: string;
  label: string;
  description: string;
  selected: boolean;
}

export function ExportCenter() {
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

    // Simulate export process
    await new Promise(resolve => setTimeout(resolve, 3000));

    setExporting(false);
    setExportComplete(true);

    // Reset after 5 seconds
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
