import { useState } from 'react';
import {
  Box,
  AppBar,
  Toolbar,
  Typography,
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  CssBaseline,
  ThemeProvider,
  createTheme,
  Badge,
} from '@mui/material';
import {
  LayoutDashboard,
  FileText,
  AlertTriangle,
  FolderOpen,
  ClipboardCheck,
  ShieldCheck,
  Shield,
  Download,
  Brain,
  Settings as SettingsIcon,
  Bell,
} from 'lucide-react';
import { EnhancedDashboard } from './components/EnhancedDashboard';
import { ControlRegistry } from './components/ControlRegistry';
import { POAMTracker } from './components/POAMTracker';
import { EvidenceRepository } from './components/EvidenceRepository';
import { AssessmentWorkflow } from './components/AssessmentWorkflow';
import { ExportCenter } from './components/ExportCenter';
import { AIInsights } from './components/AIInsights';
import { Settings } from './components/Settings';
import { Affirmations } from './components/Affirmations';
import { GrcProvider } from './store/grcStore';

const drawerWidth = 280;

const theme = createTheme({
  palette: {
    primary: {
      main: '#2563EB',
    },
    secondary: {
      main: '#7C3AED',
    },
    success: {
      main: '#16A34A',
    },
    warning: {
      main: '#F59E0B',
    },
    error: {
      main: '#DC2626',
    },
  },
  typography: {
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
  },
});

const menuItems = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'controls', label: 'Control Registry', icon: FileText },
  { id: 'poam', label: 'POA&M Tracker', icon: AlertTriangle },
  { id: 'evidence', label: 'Evidence Repository', icon: FolderOpen },
  { id: 'assessment', label: 'Assessment Workflow', icon: ClipboardCheck },
  { id: 'affirmations', label: 'Affirmations', icon: ShieldCheck },
  { id: 'ai-insights', label: 'AI Insights', icon: Brain, badge: 'NEW' },
  { id: 'export', label: 'Export Center', icon: Download },
  { id: 'settings', label: 'Settings', icon: SettingsIcon },
];

export default function App() {
  const [activeView, setActiveView] = useState('dashboard');

  const renderContent = () => {
    switch (activeView) {
      case 'dashboard':
        return <EnhancedDashboard />;
      case 'controls':
        return <ControlRegistry />;
      case 'poam':
        return <POAMTracker />;
      case 'evidence':
        return <EvidenceRepository />;
      case 'assessment':
        return <AssessmentWorkflow />;
      case 'affirmations':
        return <Affirmations />;
      case 'ai-insights':
        return <AIInsights />;
      case 'export':
        return <ExportCenter />;
      case 'settings':
        return <Settings />;
      default:
        return <EnhancedDashboard />;
    }
  };

  return (
    <ThemeProvider theme={theme}>
      <GrcProvider>
      <CssBaseline />
      <Box sx={{ display: 'flex', height: '100vh' }}>
        {/* App Bar */}
        <AppBar
          position="fixed"
          sx={{
            zIndex: (theme) => theme.zIndex.drawer + 1,
            backgroundColor: '#030213',
          }}
        >
          <Toolbar>
            <Shield size={32} color="#FFFFFF" style={{ marginRight: 16 }} />
            <Typography variant="h6" noWrap component="div" sx={{ fontWeight: 600 }}>
              cyberAutopsy
            </Typography>
            <Box sx={{ flexGrow: 1 }} />
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              <Badge
                badgeContent={5}
                color="error"
                sx={{ cursor: 'pointer', '&:hover': { opacity: 0.8 } }}
                onClick={() => setActiveView('ai-insights')}
              >
                <Bell size={24} color="#9CA3AF" />
              </Badge>
              <Typography variant="body2" sx={{ color: '#9CA3AF' }}>
                Enterprise Compliance Management
              </Typography>
            </Box>
          </Toolbar>
        </AppBar>

        {/* Sidebar Drawer */}
        <Drawer
          variant="permanent"
          sx={{
            width: drawerWidth,
            flexShrink: 0,
            '& .MuiDrawer-paper': {
              width: drawerWidth,
              boxSizing: 'border-box',
              backgroundColor: '#F9FAFB',
              borderRight: '1px solid #E5E7EB',
            },
          }}
        >
          <Toolbar />
          <Box sx={{ overflow: 'auto', mt: 2 }}>
            <List>
              {menuItems.map((item) => {
                const Icon = item.icon;
                const isActive = activeView === item.id;

                return (
                  <ListItem key={item.id} disablePadding sx={{ px: 2, mb: 0.5 }}>
                    <ListItemButton
                      onClick={() => setActiveView(item.id)}
                      sx={{
                        borderRadius: 2,
                        backgroundColor: isActive ? '#EEF2FF' : 'transparent',
                        '&:hover': {
                          backgroundColor: isActive ? '#E0E7FF' : '#F3F4F6',
                        },
                      }}
                    >
                      <ListItemIcon sx={{ minWidth: 40 }}>
                        <Icon
                          size={20}
                          color={isActive ? '#2563EB' : '#6B7280'}
                        />
                      </ListItemIcon>
                      <ListItemText
                        primary={
                          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                            <span>{item.label}</span>
                            {item.badge && (
                              <Box
                                sx={{
                                  px: 0.75,
                                  py: 0.25,
                                  borderRadius: 0.5,
                                  backgroundColor: '#7C3AED',
                                  color: 'white',
                                  fontSize: '0.65rem',
                                  fontWeight: 600,
                                }}
                              >
                                {item.badge}
                              </Box>
                            )}
                          </Box>
                        }
                        primaryTypographyProps={{
                          fontSize: '0.95rem',
                          fontWeight: isActive ? 600 : 400,
                          color: isActive ? '#2563EB' : '#1F2937',
                        }}
                      />
                    </ListItemButton>
                  </ListItem>
                );
              })}
            </List>
          </Box>

          {/* Info Card */}
          <Box sx={{ p: 2, mt: 'auto', mb: 2 }}>
            <Box
              sx={{
                p: 2,
                backgroundColor: '#EEF2FF',
                borderRadius: 2,
                border: '1px solid #DBEAFE',
              }}
            >
              <Typography variant="subtitle2" sx={{ mb: 1, color: '#2563EB', fontWeight: 600 }}>
                CMMC Level 2
              </Typography>
              <Typography variant="body2" sx={{ fontSize: '0.85rem', color: '#475569', mb: 1 }}>
                110 practices across 14 control families
              </Typography>
              <Typography variant="caption" sx={{ color: '#64748B' }}>
                Based on NIST SP 800-171
              </Typography>
            </Box>
          </Box>
        </Drawer>

        {/* Main Content */}
        <Box
          component="main"
          sx={{
            flexGrow: 1,
            backgroundColor: '#FFFFFF',
            overflow: 'auto',
          }}
        >
          <Toolbar />
          {renderContent()}
        </Box>
      </Box>
      </GrcProvider>
    </ThemeProvider>
  );
}
