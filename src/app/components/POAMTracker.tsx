import { useMemo, useState } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Button,
  Chip,
  Tabs,
  Tab,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  MenuItem,
  FormControl,
  InputLabel,
  Select,
  IconButton,
  Alert,
  Stack,
  LinearProgress,
  Tooltip,
} from '@mui/material';
import {
  Plus,
  Trash2,
  AlertTriangle,
  Calendar,
  GripVertical,
  ListTodo,
  LayoutGrid,
} from 'lucide-react';
import {
  POAMItem,
  RISK_COLORS,
  RISK_LEVELS,
  RiskLevel,
} from '../data/cmmcControls';
import { useGrc, computePoamDerivedStatus } from '../store/grcStore';

const STATUSES: POAMItem['status'][] = ['Open', 'In Progress', 'Completed', 'Overdue'];

const STATUS_COLOR: Record<POAMItem['status'], string> = {
  Open: '#6B7280',
  'In Progress': '#F59E0B',
  Completed: '#16A34A',
  Overdue: '#DC2626',
};

function daysRemaining(due: string) {
  if (!due) return null;
  return Math.round((new Date(due).getTime() - Date.now()) / 86400000);
}

function daysSinceCreated(created: string) {
  if (!created) return 0;
  return Math.round((Date.now() - new Date(created).getTime()) / 86400000);
}

export function POAMTracker() {
  const { poams, controls, addPoam, updatePoam, removePoam } = useGrc();
  const [view, setView] = useState<'table' | 'kanban'>('kanban');
  const [editing, setEditing] = useState<POAMItem | 'new' | null>(null);

  const enriched = useMemo(
    () =>
      poams.map((p) => ({
        ...p,
        status: computePoamDerivedStatus(p),
      })),
    [poams],
  );

  const summary = useMemo(() => {
    const open = enriched.filter((p) => p.status !== 'Completed').length;
    const overdue = enriched.filter((p) => p.status === 'Overdue').length;
    const at180 = enriched.filter((p) => {
      const age = daysSinceCreated(p.createdDate);
      return p.status !== 'Completed' && age > 150;
    }).length;
    const high = enriched.filter((p) => p.riskLevel === 'High' && p.status !== 'Completed').length;
    return { open, overdue, at180, high };
  }, [enriched]);

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 700, mb: 0.5 }}>
            POA&amp;M Tracker
          </Typography>
          <Typography variant="body2" sx={{ color: '#6B7280' }}>
            Plans of Action &amp; Milestones — max 180-day remediation window
          </Typography>
        </Box>
        <Button
          variant="contained"
          startIcon={<Plus size={16} />}
          onClick={() => setEditing('new')}
        >
          New POA&amp;M
        </Button>
      </Box>

      <Grid container spacing={2} sx={{ mb: 3 }}>
        <SummaryTile label="Open Items" value={summary.open} color="#2563EB" />
        <SummaryTile label="Overdue" value={summary.overdue} color="#DC2626" />
        <SummaryTile label="Approaching 180-day limit" value={summary.at180} color="#F59E0B" />
        <SummaryTile label="High Risk" value={summary.high} color="#7E22CE" />
      </Grid>

      {summary.at180 > 0 && (
        <Alert severity="warning" sx={{ mb: 2 }} icon={<AlertTriangle size={18} />}>
          {summary.at180} POA&amp;M item{summary.at180 !== 1 && 's'} approaching the 180-day CMMC
          remediation limit. Escalate or complete to avoid disqualification.
        </Alert>
      )}

      <Tabs
        value={view}
        onChange={(_, v) => setView(v)}
        sx={{ mb: 2, borderBottom: '1px solid #E5E7EB' }}
      >
        <Tab
          icon={<LayoutGrid size={16} />}
          iconPosition="start"
          label="Kanban"
          value="kanban"
          sx={{ minHeight: 40 }}
        />
        <Tab
          icon={<ListTodo size={16} />}
          iconPosition="start"
          label="Table"
          value="table"
          sx={{ minHeight: 40 }}
        />
      </Tabs>

      {view === 'kanban' ? (
        <KanbanBoard
          items={enriched}
          onMove={(id, status) => updatePoam(id, { status })}
          onEdit={(p) => setEditing(p)}
        />
      ) : (
        <PoamTable
          items={enriched}
          onEdit={(p) => setEditing(p)}
          onDelete={(id) => removePoam(id)}
        />
      )}

      <PoamEditor
        open={editing !== null}
        initial={editing === 'new' ? null : editing}
        controls={controls.map((c) => ({ id: c.id, label: `${c.id} — ${c.practice}` }))}
        onClose={() => setEditing(null)}
        onSave={(p) => {
          if (editing === 'new') addPoam(p);
          else if (editing) updatePoam(editing.id, p);
          setEditing(null);
        }}
      />
    </Box>
  );
}

function SummaryTile({
  label,
  value,
  color,
}: {
  label: string;
  value: number;
  color: string;
}) {
  return (
    <Grid item xs={6} md={3}>
      <Card variant="outlined">
        <CardContent>
          <Typography variant="caption" sx={{ color: '#6B7280', textTransform: 'uppercase' }}>
            {label}
          </Typography>
          <Typography variant="h4" sx={{ fontWeight: 700, color, mt: 0.5 }}>
            {value}
          </Typography>
        </CardContent>
      </Card>
    </Grid>
  );
}

function KanbanBoard({
  items,
  onMove,
  onEdit,
}: {
  items: POAMItem[];
  onMove: (id: string, status: POAMItem['status']) => void;
  onEdit: (p: POAMItem) => void;
}) {
  const [dragId, setDragId] = useState<string | null>(null);
  return (
    <Grid container spacing={2}>
      {STATUSES.map((status) => {
        const col = items.filter((p) => p.status === status);
        return (
          <Grid item xs={12} md={3} key={status}>
            <Box
              onDragOver={(e) => e.preventDefault()}
              onDrop={() => {
                if (dragId) onMove(dragId, status);
                setDragId(null);
              }}
              sx={{
                p: 1.5,
                borderRadius: 2,
                backgroundColor: '#F9FAFB',
                border: '1px solid #E5E7EB',
                minHeight: 400,
              }}
            >
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 1.5, gap: 1 }}>
                <Box
                  sx={{
                    width: 10,
                    height: 10,
                    borderRadius: '50%',
                    backgroundColor: STATUS_COLOR[status],
                  }}
                />
                <Typography variant="subtitle2" sx={{ fontWeight: 700 }}>
                  {status}
                </Typography>
                <Chip label={col.length} size="small" sx={{ ml: 'auto' }} />
              </Box>
              <Stack spacing={1.5}>
                {col.map((p) => {
                  const dr = daysRemaining(p.dueDate);
                  const age = daysSinceCreated(p.createdDate);
                  const at180 = age > 150 && status !== 'Completed';
                  return (
                    <Card
                      key={p.id}
                      variant="outlined"
                      draggable
                      onDragStart={() => setDragId(p.id)}
                      onClick={() => onEdit(p)}
                      sx={{
                        cursor: 'grab',
                        '&:hover': { borderColor: '#2563EB' },
                        borderLeft: `4px solid ${RISK_COLORS[p.riskLevel]}`,
                      }}
                    >
                      <CardContent sx={{ p: 1.5, '&:last-child': { pb: 1.5 } }}>
                        <Box
                          sx={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'flex-start',
                            mb: 0.5,
                          }}
                        >
                          <Typography
                            variant="caption"
                            sx={{ color: '#6B7280', fontFamily: 'monospace' }}
                          >
                            {p.id} · {p.controlId}
                          </Typography>
                          <GripVertical size={14} color="#9CA3AF" />
                        </Box>
                        <Typography variant="body2" sx={{ fontWeight: 500, mb: 1 }}>
                          {p.finding || '(no finding)'}
                        </Typography>
                        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                          <Chip
                            label={p.riskLevel}
                            size="small"
                            sx={{
                              backgroundColor: `${RISK_COLORS[p.riskLevel]}1A`,
                              color: RISK_COLORS[p.riskLevel],
                              fontWeight: 600,
                              height: 20,
                            }}
                          />
                          {p.dueDate && dr !== null && (
                            <Chip
                              icon={<Calendar size={10} />}
                              label={
                                dr < 0 ? `${Math.abs(dr)}d overdue` : `${dr}d left`
                              }
                              size="small"
                              color={dr < 0 ? 'error' : dr < 14 ? 'warning' : 'default'}
                              sx={{ height: 20 }}
                            />
                          )}
                          {at180 && (
                            <Chip
                              icon={<AlertTriangle size={10} />}
                              label="180d"
                              size="small"
                              color="error"
                              sx={{ height: 20 }}
                            />
                          )}
                        </Box>
                        {p.assignedTo && (
                          <Typography
                            variant="caption"
                            sx={{ color: '#6B7280', mt: 1, display: 'block' }}
                          >
                            @{p.assignedTo}
                          </Typography>
                        )}
                      </CardContent>
                    </Card>
                  );
                })}
                {col.length === 0 && (
                  <Typography
                    variant="caption"
                    sx={{ color: '#9CA3AF', textAlign: 'center', py: 2, display: 'block' }}
                  >
                    Drop here
                  </Typography>
                )}
              </Stack>
            </Box>
          </Grid>
        );
      })}
    </Grid>
  );
}

function PoamTable({
  items,
  onEdit,
  onDelete,
}: {
  items: POAMItem[];
  onEdit: (p: POAMItem) => void;
  onDelete: (id: string) => void;
}) {
  return (
    <TableContainer component={Paper} variant="outlined">
      <Table size="small">
        <TableHead>
          <TableRow sx={{ backgroundColor: '#F9FAFB' }}>
            <TableCell sx={{ fontWeight: 600 }}>POA&amp;M ID</TableCell>
            <TableCell sx={{ fontWeight: 600 }}>Control</TableCell>
            <TableCell sx={{ fontWeight: 600 }}>Finding</TableCell>
            <TableCell sx={{ fontWeight: 600 }}>Risk</TableCell>
            <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
            <TableCell sx={{ fontWeight: 600 }}>Due</TableCell>
            <TableCell sx={{ fontWeight: 600 }}>Owner</TableCell>
            <TableCell sx={{ fontWeight: 600 }}>Age</TableCell>
            <TableCell sx={{ fontWeight: 600, textAlign: 'right' }}>Actions</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {items.map((p) => {
            const dr = daysRemaining(p.dueDate);
            const age = daysSinceCreated(p.createdDate);
            const ageColor = age > 180 ? '#DC2626' : age > 150 ? '#F59E0B' : '#6B7280';
            return (
              <TableRow key={p.id} hover sx={{ cursor: 'pointer' }} onClick={() => onEdit(p)}>
                <TableCell sx={{ fontFamily: 'monospace', fontWeight: 600 }}>{p.id}</TableCell>
                <TableCell sx={{ fontFamily: 'monospace' }}>{p.controlId}</TableCell>
                <TableCell>{p.finding || <span style={{ color: '#9CA3AF' }}>—</span>}</TableCell>
                <TableCell>
                  <Chip
                    label={p.riskLevel}
                    size="small"
                    sx={{
                      backgroundColor: `${RISK_COLORS[p.riskLevel]}1A`,
                      color: RISK_COLORS[p.riskLevel],
                      fontWeight: 600,
                    }}
                  />
                </TableCell>
                <TableCell>
                  <Chip
                    label={p.status}
                    size="small"
                    sx={{
                      backgroundColor: `${STATUS_COLOR[p.status]}1A`,
                      color: STATUS_COLOR[p.status],
                      fontWeight: 600,
                    }}
                  />
                </TableCell>
                <TableCell>
                  {p.dueDate ? (
                    <Box>
                      <Typography variant="body2">{p.dueDate}</Typography>
                      {dr !== null && (
                        <Typography
                          variant="caption"
                          sx={{ color: dr < 0 ? '#DC2626' : '#6B7280' }}
                        >
                          {dr < 0 ? `${Math.abs(dr)}d overdue` : `${dr}d left`}
                        </Typography>
                      )}
                    </Box>
                  ) : (
                    <span style={{ color: '#9CA3AF' }}>—</span>
                  )}
                </TableCell>
                <TableCell>{p.assignedTo || <span style={{ color: '#9CA3AF' }}>—</span>}</TableCell>
                <TableCell sx={{ color: ageColor, fontWeight: age > 150 ? 600 : 400 }}>
                  {age}d
                </TableCell>
                <TableCell sx={{ textAlign: 'right' }} onClick={(e) => e.stopPropagation()}>
                  <Tooltip title="Delete">
                    <IconButton size="small" onClick={() => onDelete(p.id)}>
                      <Trash2 size={14} />
                    </IconButton>
                  </Tooltip>
                </TableCell>
              </TableRow>
            );
          })}
          {items.length === 0 && (
            <TableRow>
              <TableCell colSpan={9} sx={{ textAlign: 'center', py: 4, color: '#9CA3AF' }}>
                No POA&amp;Ms yet — click “New POA&amp;M” to add one.
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </TableContainer>
  );
}

interface EditorProps {
  open: boolean;
  initial: POAMItem | null;
  controls: { id: string; label: string }[];
  onClose: () => void;
  onSave: (p: Omit<POAMItem, 'id'>) => void;
}

function PoamEditor({ open, initial, controls, onClose, onSave }: EditorProps) {
  const [draft, setDraft] = useState<Omit<POAMItem, 'id'>>(() =>
    initial
      ? { ...initial }
      : {
          controlId: '',
          finding: '',
          riskLevel: 'Medium',
          remediationPlan: '',
          dueDate: '',
          status: 'Open',
          assignedTo: '',
          createdDate: new Date().toISOString().slice(0, 10),
        },
  );

  const sig = initial?.id ?? 'new';
  const [openSig, setOpenSig] = useState(sig);
  if (open && openSig !== sig) {
    setOpenSig(sig);
    setDraft(
      initial
        ? { ...initial }
        : {
            controlId: '',
            finding: '',
            riskLevel: 'Medium',
            remediationPlan: '',
            dueDate: '',
            status: 'Open',
            assignedTo: '',
            createdDate: new Date().toISOString().slice(0, 10),
          },
    );
  }

  const age = daysSinceCreated(draft.createdDate);
  const ageProgress = Math.min((age / 180) * 100, 100);

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>{initial ? `Edit ${initial.id}` : 'New POA&M'}</DialogTitle>
      <DialogContent dividers>
        <Stack spacing={2}>
          {initial && (
            <Box>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                <Typography variant="caption">180-day remediation window</Typography>
                <Typography variant="caption" sx={{ fontWeight: 600 }}>
                  Day {age} / 180
                </Typography>
              </Box>
              <LinearProgress
                variant="determinate"
                value={ageProgress}
                color={age > 180 ? 'error' : age > 150 ? 'warning' : 'primary'}
                sx={{ height: 6, borderRadius: 1 }}
              />
            </Box>
          )}
          <FormControl size="small" fullWidth required>
            <InputLabel>Related control</InputLabel>
            <Select
              value={draft.controlId}
              label="Related control"
              onChange={(e) => setDraft({ ...draft, controlId: e.target.value })}
            >
              {controls.map((c) => (
                <MenuItem key={c.id} value={c.id}>
                  {c.label}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
          <TextField
            label="Finding"
            value={draft.finding}
            onChange={(e) => setDraft({ ...draft, finding: e.target.value })}
            multiline
            minRows={2}
            fullWidth
            size="small"
          />
          <Stack direction="row" spacing={2}>
            <FormControl size="small" fullWidth>
              <InputLabel>Risk level</InputLabel>
              <Select
                value={draft.riskLevel}
                label="Risk level"
                onChange={(e) => setDraft({ ...draft, riskLevel: e.target.value as RiskLevel })}
              >
                {RISK_LEVELS.map((r) => (
                  <MenuItem key={r} value={r}>
                    {r}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
            <FormControl size="small" fullWidth>
              <InputLabel>Status</InputLabel>
              <Select
                value={draft.status}
                label="Status"
                onChange={(e) =>
                  setDraft({ ...draft, status: e.target.value as POAMItem['status'] })
                }
              >
                {STATUSES.map((s) => (
                  <MenuItem key={s} value={s}>
                    {s}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Stack>
          <TextField
            label="Remediation plan"
            value={draft.remediationPlan}
            onChange={(e) => setDraft({ ...draft, remediationPlan: e.target.value })}
            multiline
            minRows={3}
            fullWidth
            size="small"
          />
          <Stack direction="row" spacing={2}>
            <TextField
              size="small"
              label="Owner"
              value={draft.assignedTo}
              onChange={(e) => setDraft({ ...draft, assignedTo: e.target.value })}
              fullWidth
            />
            <TextField
              size="small"
              type="date"
              label="Due date"
              value={draft.dueDate}
              onChange={(e) => setDraft({ ...draft, dueDate: e.target.value })}
              fullWidth
              InputLabelProps={{ shrink: true }}
            />
          </Stack>
        </Stack>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Cancel</Button>
        <Button
          variant="contained"
          disabled={!draft.controlId || !draft.finding}
          onClick={() => onSave(draft)}
        >
          Save
        </Button>
      </DialogActions>
    </Dialog>
  );
}
