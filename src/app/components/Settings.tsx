import { useState } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  TextField,
  Button,
  Avatar,
  Divider,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Switch,
  Chip,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Tab,
  Tabs,
  Alert,
} from '@mui/material';
import {
  User,
  Shield,
  Bell,
  Mail,
  Lock,
  Users,
  Settings as SettingsIcon,
  CheckCircle,
} from 'lucide-react';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`settings-tabpanel-${index}`}
      aria-labelledby={`settings-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ py: 3 }}>{children}</Box>}
    </div>
  );
}

export function Settings() {
  const [activeTab, setActiveTab] = useState(0);
  const [notifications, setNotifications] = useState({
    evidenceExpiring: true,
    poamDeadlines: true,
    affirmationReminders: true,
    controlUpdates: false,
    weeklyReports: true,
  });

  const handleTabChange = (_event: React.SyntheticEvent, newValue: number) => {
    setActiveTab(newValue);
  };

  const handleNotificationToggle = (key: keyof typeof notifications) => {
    setNotifications(prev => ({ ...prev, [key]: !prev[key] }));
  };

  const currentUser = {
    name: 'John Smith',
    email: 'john.smith@company.com',
    role: 'Administrator',
    department: 'Information Security',
    phone: '+1 (555) 123-4567',
    joined: '2024-01-15',
  };

  const teamMembers = [
    {
      name: 'Sarah Johnson',
      email: 'sarah.johnson@company.com',
      role: 'Assessor',
      controls: 45,
      status: 'Active',
    },
    {
      name: 'Michael Chen',
      email: 'michael.chen@company.com',
      role: 'Contributor',
      controls: 32,
      status: 'Active',
    },
    {
      name: 'Emily Davis',
      email: 'emily.davis@company.com',
      role: 'Assessor',
      controls: 28,
      status: 'Active',
    },
    {
      name: 'Robert Wilson',
      email: 'robert.wilson@company.com',
      role: 'Contributor',
      controls: 15,
      status: 'Active',
    },
  ];

  const rolePermissions = {
    Administrator: ['Full system access', 'User management', 'Export reports', 'Edit all controls', 'Approve POA&Ms'],
    Assessor: ['View all controls', 'Edit assigned controls', 'Upload evidence', 'Create POA&Ms', 'Export reports'],
    Contributor: ['View assigned controls', 'Upload evidence', 'Comment on controls', 'View reports'],
    Executive: ['View dashboards', 'View reports', 'View compliance status', 'Approve affirmations'],
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" sx={{ mb: 3 }}>
        Settings & User Management
      </Typography>

      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}>
        <Tabs value={activeTab} onChange={handleTabChange}>
          <Tab icon={<User size={18} />} iconPosition="start" label="Profile" />
          <Tab icon={<Bell size={18} />} iconPosition="start" label="Notifications" />
          <Tab icon={<Users size={18} />} iconPosition="start" label="Team" />
          <Tab icon={<Shield size={18} />} iconPosition="start" label="Security" />
        </Tabs>
      </Box>

      {/* Profile Tab */}
      <TabPanel value={activeTab} index={0}>
        <Grid container spacing={3}>
          <Grid item xs={12} md={4}>
            <Card>
              <CardContent sx={{ textAlign: 'center' }}>
                <Avatar
                  sx={{
                    width: 120,
                    height: 120,
                    margin: '0 auto',
                    mb: 2,
                    backgroundColor: '#2563EB',
                    fontSize: '3rem',
                  }}
                >
                  {currentUser.name.split(' ').map(n => n[0]).join('')}
                </Avatar>
                <Typography variant="h5" sx={{ mb: 1 }}>
                  {currentUser.name}
                </Typography>
                <Chip label={currentUser.role} color="primary" sx={{ mb: 2 }} />
                <Typography variant="body2" color="text.secondary">
                  {currentUser.department}
                </Typography>
                <Button variant="outlined" fullWidth sx={{ mt: 2 }}>
                  Change Photo
                </Button>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} md={8}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 3 }}>
                  Profile Information
                </Typography>

                <Grid container spacing={2}>
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      fullWidth
                      label="Full Name"
                      defaultValue={currentUser.name}
                      variant="outlined"
                    />
                  </Grid>
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      fullWidth
                      label="Email Address"
                      defaultValue={currentUser.email}
                      variant="outlined"
                      type="email"
                    />
                  </Grid>
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      fullWidth
                      label="Phone Number"
                      defaultValue={currentUser.phone}
                      variant="outlined"
                    />
                  </Grid>
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      fullWidth
                      label="Department"
                      defaultValue={currentUser.department}
                      variant="outlined"
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <FormControl fullWidth>
                      <InputLabel>Role</InputLabel>
                      <Select defaultValue={currentUser.role} label="Role">
                        <MenuItem value="Administrator">Administrator</MenuItem>
                        <MenuItem value="Assessor">Assessor</MenuItem>
                        <MenuItem value="Contributor">Contributor</MenuItem>
                        <MenuItem value="Executive">Executive</MenuItem>
                      </Select>
                    </FormControl>
                  </Grid>
                </Grid>

                <Divider sx={{ my: 3 }} />

                <Typography variant="subtitle2" sx={{ mb: 2 }}>
                  Role Permissions
                </Typography>
                <List dense>
                  {rolePermissions[currentUser.role as keyof typeof rolePermissions].map((permission, index) => (
                    <ListItem key={index}>
                      <ListItemIcon>
                        <CheckCircle size={18} color="#16A34A" />
                      </ListItemIcon>
                      <ListItemText primary={permission} />
                    </ListItem>
                  ))}
                </List>

                <Box sx={{ mt: 3, display: 'flex', gap: 2 }}>
                  <Button variant="contained">Save Changes</Button>
                  <Button variant="outlined">Cancel</Button>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      </TabPanel>

      {/* Notifications Tab */}
      <TabPanel value={activeTab} index={1}>
        <Grid container spacing={3}>
          <Grid item xs={12} md={8}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 3 }}>
                  Notification Preferences
                </Typography>

                <Alert severity="info" sx={{ mb: 3 }}>
                  Configure automated reminders and alerts to stay on top of compliance deadlines.
                </Alert>

                <List>
                  <ListItem>
                    <ListItemIcon>
                      <Bell size={20} />
                    </ListItemIcon>
                    <ListItemText
                      primary="Evidence Expiring Soon"
                      secondary="Notify when evidence files will expire within 30 days"
                    />
                    <Switch
                      checked={notifications.evidenceExpiring}
                      onChange={() => handleNotificationToggle('evidenceExpiring')}
                    />
                  </ListItem>
                  <Divider />

                  <ListItem>
                    <ListItemIcon>
                      <Bell size={20} />
                    </ListItemIcon>
                    <ListItemText
                      primary="POA&M Deadlines"
                      secondary="Notify when POA&M items are nearing due dates or 180-day limit"
                    />
                    <Switch
                      checked={notifications.poamDeadlines}
                      onChange={() => handleNotificationToggle('poamDeadlines')}
                    />
                  </ListItem>
                  <Divider />

                  <ListItem>
                    <ListItemIcon>
                      <Bell size={20} />
                    </ListItemIcon>
                    <ListItemText
                      primary="Affirmation Reminders"
                      secondary="Notify 90 days before annual affirmation is due"
                    />
                    <Switch
                      checked={notifications.affirmationReminders}
                      onChange={() => handleNotificationToggle('affirmationReminders')}
                    />
                  </ListItem>
                  <Divider />

                  <ListItem>
                    <ListItemIcon>
                      <Bell size={20} />
                    </ListItemIcon>
                    <ListItemText
                      primary="Control Updates"
                      secondary="Notify when controls assigned to you are updated"
                    />
                    <Switch
                      checked={notifications.controlUpdates}
                      onChange={() => handleNotificationToggle('controlUpdates')}
                    />
                  </ListItem>
                  <Divider />

                  <ListItem>
                    <ListItemIcon>
                      <Mail size={20} />
                    </ListItemIcon>
                    <ListItemText
                      primary="Weekly Summary Reports"
                      secondary="Receive weekly compliance status summary via email"
                    />
                    <Switch
                      checked={notifications.weeklyReports}
                      onChange={() => handleNotificationToggle('weeklyReports')}
                    />
                  </ListItem>
                </List>

                <Box sx={{ mt: 3 }}>
                  <Button variant="contained">Save Preferences</Button>
                </Box>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} md={4}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>
                  Notification Channels
                </Typography>

                <List dense>
                  <ListItem>
                    <ListItemIcon>
                      <Mail size={18} />
                    </ListItemIcon>
                    <ListItemText primary="Email Notifications" secondary="Enabled" />
                  </ListItem>
                  <ListItem>
                    <ListItemIcon>
                      <Bell size={18} />
                    </ListItemIcon>
                    <ListItemText primary="In-App Notifications" secondary="Enabled" />
                  </ListItem>
                </List>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      </TabPanel>

      {/* Team Tab */}
      <TabPanel value={activeTab} index={2}>
        <Card>
          <CardContent>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
              <Typography variant="h6">Team Members</Typography>
              <Button variant="contained" startIcon={<Users size={18} />}>
                Invite User
              </Button>
            </Box>

            <Grid container spacing={2}>
              {teamMembers.map((member, index) => (
                <Grid item xs={12} md={6} key={index}>
                  <Card variant="outlined">
                    <CardContent>
                      <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                        <Avatar sx={{ mr: 2, backgroundColor: '#7C3AED' }}>
                          {member.name.split(' ').map(n => n[0]).join('')}
                        </Avatar>
                        <Box sx={{ flex: 1 }}>
                          <Typography variant="subtitle1" sx={{ fontWeight: 600 }}>
                            {member.name}
                          </Typography>
                          <Typography variant="body2" color="text.secondary">
                            {member.email}
                          </Typography>
                        </Box>
                        <Chip label={member.status} size="small" color="success" />
                      </Box>

                      <Divider sx={{ my: 1 }} />

                      <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 2 }}>
                        <Box>
                          <Typography variant="caption" color="text.secondary">
                            Role
                          </Typography>
                          <Typography variant="body2">{member.role}</Typography>
                        </Box>
                        <Box>
                          <Typography variant="caption" color="text.secondary">
                            Assigned Controls
                          </Typography>
                          <Typography variant="body2">{member.controls}</Typography>
                        </Box>
                      </Box>
                    </CardContent>
                  </Card>
                </Grid>
              ))}
            </Grid>
          </CardContent>
        </Card>
      </TabPanel>

      {/* Security Tab */}
      <TabPanel value={activeTab} index={3}>
        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <Card>
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
                  <Lock size={24} style={{ marginRight: 8 }} />
                  <Typography variant="h6">Change Password</Typography>
                </Box>

                <Grid container spacing={2}>
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label="Current Password"
                      type="password"
                      variant="outlined"
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label="New Password"
                      type="password"
                      variant="outlined"
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label="Confirm New Password"
                      type="password"
                      variant="outlined"
                    />
                  </Grid>
                </Grid>

                <Button variant="contained" sx={{ mt: 3 }}>
                  Update Password
                </Button>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} md={6}>
            <Card>
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
                  <Shield size={24} style={{ marginRight: 8 }} />
                  <Typography variant="h6">Security Settings</Typography>
                </Box>

                <List>
                  <ListItem>
                    <ListItemIcon>
                      <SettingsIcon size={20} />
                    </ListItemIcon>
                    <ListItemText
                      primary="Two-Factor Authentication"
                      secondary="Add an extra layer of security"
                    />
                    <Button size="small" variant="outlined">
                      Enable
                    </Button>
                  </ListItem>
                  <Divider />

                  <ListItem>
                    <ListItemIcon>
                      <SettingsIcon size={20} />
                    </ListItemIcon>
                    <ListItemText
                      primary="Session Timeout"
                      secondary="Auto-logout after 30 minutes of inactivity"
                    />
                    <Switch defaultChecked />
                  </ListItem>
                  <Divider />

                  <ListItem>
                    <ListItemIcon>
                      <SettingsIcon size={20} />
                    </ListItemIcon>
                    <ListItemText
                      primary="Login Notifications"
                      secondary="Get notified of new login attempts"
                    />
                    <Switch defaultChecked />
                  </ListItem>
                </List>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      </TabPanel>
    </Box>
  );
}
