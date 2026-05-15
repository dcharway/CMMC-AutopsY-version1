import { useMemo, useState } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  TextField,
  MenuItem,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  Paper,
  IconButton,
  Drawer,
  Divider,
  Button,
  Select,
  FormControl,
  InputLabel,
  Stack,
  Tooltip,
  TablePagination,
  Alert,
} from '@mui/material';
import {
  Search,
  Filter,
  Eye,
  Edit3,
  CheckCircle2,
  FileText,
  AlertTriangle,
  Save,
  X,
} from 'lucide-react';
import {
  Control,
  ControlStatus,
  RiskLevel,
  controlFamilies,
  STATUS_OPTIONS,
  STATUS_COLORS,
  RISK_LEVELS,
  RISK_COLORS,
} from '../data/cmmcControls';
import { useGrc } from '../store/grcStore';

function StatusChip({ status }: { status: ControlStatus }) {
  return (
    <Chip
      label={status}
      size="small"
      sx={{
        backgroundColor: `${STATUS_COLORS[status]}1A`,
        color: STATUS_COLORS[status],
        fontWeight: 600,
        border: `1px solid ${STATUS_COLORS[status]}55`,
      }}
    />
  );
}

function StatusSelect({
  value,
  onChange,
  size = 'small',
}: {
  value: ControlStatus;
  onChange: (s: ControlStatus) => void;
  size?: 'small' | 'medium';
}) {
  return (
    <Select
      value={value}
      size={size}
      onChange={(e) => onChange(e.target.value as ControlStatus)}
      sx={{
        minWidth: 150,
        backgroundColor: `${STATUS_COLORS[value]}10`,
        '& .MuiSelect-select': {
          color: STATUS_COLORS[value],
          fontWeight: 600,
        },
      }}
    >
      {STATUS_OPTIONS.map((s) => (
        <MenuItem key={s} value={s}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Box
              sx={{
                width: 10,
                height: 10,
                borderRadius: '50%',
                backgroundColor: STATUS_COLORS[s],
              }}
            />
            {s}
          </Box>
        </MenuItem>
      ))}
    </Select>
  );
}

export function ControlRegistry() {
  const { controls, evidence, poams, updateControl } = useGrc();
  const [query, setQuery] = useState('');
  const [familyFilter, setFamilyFilter] = useState('All');
  const [statusFilter, setStatusFilter] = useState<'All' | ControlStatus>('All');
  const [selected, setSelected] = useState<Control | null>(null);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(25);

  const filtered = useMemo(() => {
    return controls.filter((c) => {
      const matchesQuery = query
        ? `${c.id} ${c.practice} ${c.family} ${c.description}`
            .toLowerCase()
            .includes(query.toLowerCase())
        : true;
      const matchesFamily = familyFilter === 'All' || c.familyCode === familyFilter;
      const matchesStatus = statusFilter === 'All' || c.status === statusFilter;
      return matchesQuery && matchesFamily && matchesStatus;
    });
  }, [controls, query, familyFilter, statusFilter]);

  const paged = useMemo(
    () => filtered.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage),
    [filtered, page, rowsPerPage],
  );

  const counts = useMemo(() => {
    const byStatus: Record<string, number> = {};
    STATUS_OPTIONS.forEach((s) => (byStatus[s] = 0));
    controls.forEach((c) => byStatus[c.status]++);
    return byStatus;
  }, [controls]);

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ mb: 3 }}>
        <Typography variant="h4" sx={{ fontWeight: 700, mb: 0.5 }}>
          Control Registry
        </Typography>
        <Typography variant="body2" sx={{ color: '#6B7280' }}>
          {controls.length} controls · NIST SP 800-171 mapping for CMMC Level 2
        </Typography>
      </Box>

      {/* Status summary cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        {STATUS_OPTIONS.map((s) => (
          <Grid item xs={6} md={2.4} key={s}>
            <Card variant="outlined" sx={{ borderColor: `${STATUS_COLORS[s]}55` }}>
              <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
                <Typography variant="caption" sx={{ color: '#6B7280', textTransform: 'uppercase' }}>
                  {s}
                </Typography>
                <Typography
                  variant="h4"
                  sx={{ fontWeight: 700, color: STATUS_COLORS[s], mt: 0.5 }}
                >
                  {counts[s]}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* Filters */}
      <Card variant="outlined" sx={{ mb: 3 }}>
        <CardContent>
          <Stack direction={{ xs: 'column', md: 'row' }} spacing={2}>
            <TextField
              size="small"
              fullWidth
              placeholder="Search by ID, name, family, or text…"
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                setPage(0);
              }}
              InputProps={{
                startAdornment: <Search size={16} style={{ marginRight: 8, color: '#6B7280' }} />,
              }}
            />
            <FormControl size="small" sx={{ minWidth: 200 }}>
              <InputLabel>Family</InputLabel>
              <Select
                value={familyFilter}
                label="Family"
                onChange={(e) => {
                  setFamilyFilter(e.target.value);
                  setPage(0);
                }}
              >
                <MenuItem value="All">All families</MenuItem>
                {controlFamilies.map((f) => (
                  <MenuItem key={f.code} value={f.code}>
                    {f.code} – {f.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
            <FormControl size="small" sx={{ minWidth: 180 }}>
              <InputLabel>Status</InputLabel>
              <Select
                value={statusFilter}
                label="Status"
                onChange={(e) => {
                  setStatusFilter(e.target.value as ControlStatus | 'All');
                  setPage(0);
                }}
              >
                <MenuItem value="All">All statuses</MenuItem>
                {STATUS_OPTIONS.map((s) => (
                  <MenuItem key={s} value={s}>
                    {s}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
            {(query || familyFilter !== 'All' || statusFilter !== 'All') && (
              <Button
                size="small"
                onClick={() => {
                  setQuery('');
                  setFamilyFilter('All');
                  setStatusFilter('All');
                  setPage(0);
                }}
              >
                Clear
              </Button>
            )}
          </Stack>
          <Typography variant="caption" sx={{ color: '#6B7280', mt: 1.5, display: 'block' }}>
            Showing {filtered.length} of {controls.length} controls
          </Typography>
        </CardContent>
      </Card>

      {/* Table */}
      <TableContainer component={Paper} variant="outlined">
        <Table size="small">
          <TableHead>
            <TableRow sx={{ backgroundColor: '#F9FAFB' }}>
              <TableCell sx={{ fontWeight: 600 }}>Control ID</TableCell>
              <TableCell sx={{ fontWeight: 600 }}>Family</TableCell>
              <TableCell sx={{ fontWeight: 600 }}>Practice</TableCell>
              <TableCell sx={{ fontWeight: 600 }}>SSP §</TableCell>
              <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
              <TableCell sx={{ fontWeight: 600 }}>Risk</TableCell>
              <TableCell sx={{ fontWeight: 600 }}>Owner</TableCell>
              <TableCell sx={{ fontWeight: 600, textAlign: 'center' }}>Evidence</TableCell>
              <TableCell sx={{ fontWeight: 600, textAlign: 'center' }}>POA&amp;M</TableCell>
              <TableCell sx={{ fontWeight: 600, textAlign: 'right' }}>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {paged.map((c) => {
              const family = controlFamilies.find((f) => f.code === c.familyCode);
              const evCount = c.evidenceIds.length;
              return (
                <TableRow key={c.id} hover>
                  <TableCell sx={{ fontFamily: 'monospace', fontWeight: 600 }}>{c.id}</TableCell>
                  <TableCell>
                    <Chip
                      label={c.familyCode}
                      size="small"
                      sx={{
                        backgroundColor: `${family?.color ?? '#6B7280'}1A`,
                        color: family?.color ?? '#374151',
                        fontWeight: 600,
                      }}
                    />
                  </TableCell>
                  <TableCell sx={{ maxWidth: 240 }}>
                    <Typography variant="body2" sx={{ fontWeight: 500 }}>
                      {c.practice}
                    </Typography>
                  </TableCell>
                  <TableCell sx={{ color: '#6B7280', fontFamily: 'monospace' }}>{c.ssp}</TableCell>
                  <TableCell>
                    <StatusSelect
                      value={c.status}
                      onChange={(s) => updateControl(c.id, { status: s })}
                    />
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={c.riskLevel}
                      size="small"
                      sx={{
                        backgroundColor: `${RISK_COLORS[c.riskLevel]}1A`,
                        color: RISK_COLORS[c.riskLevel],
                        fontWeight: 600,
                      }}
                    />
                  </TableCell>
                  <TableCell sx={{ color: c.owner ? '#1F2937' : '#9CA3AF' }}>
                    {c.owner || '—'}
                  </TableCell>
                  <TableCell sx={{ textAlign: 'center' }}>
                    {evCount > 0 ? (
                      <Chip
                        icon={<FileText size={12} />}
                        label={evCount}
                        size="small"
                        color="primary"
                        variant="outlined"
                      />
                    ) : (
                      <Typography variant="caption" sx={{ color: '#9CA3AF' }}>
                        —
                      </Typography>
                    )}
                  </TableCell>
                  <TableCell sx={{ textAlign: 'center' }}>
                    {c.poamId ? (
                      <Chip
                        icon={<AlertTriangle size={12} />}
                        label={c.poamId}
                        size="small"
                        color="warning"
                        variant="outlined"
                      />
                    ) : (
                      <Typography variant="caption" sx={{ color: '#9CA3AF' }}>
                        —
                      </Typography>
                    )}
                  </TableCell>
                  <TableCell sx={{ textAlign: 'right' }}>
                    <Tooltip title="View / edit">
                      <IconButton size="small" onClick={() => setSelected(c)}>
                        <Edit3 size={16} />
                      </IconButton>
                    </Tooltip>
                  </TableCell>
                </TableRow>
              );
            })}
            {paged.length === 0 && (
              <TableRow>
                <TableCell colSpan={10} sx={{ textAlign: 'center', py: 4, color: '#9CA3AF' }}>
                  No controls match the current filters.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
        <TablePagination
          rowsPerPageOptions={[10, 25, 50, 100]}
          component="div"
          count={filtered.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={(_, p) => setPage(p)}
          onRowsPerPageChange={(e) => {
            setRowsPerPage(parseInt(e.target.value, 10));
            setPage(0);
          }}
        />
      </TableContainer>

      {/* Detail/edit drawer */}
      <ControlDetailDrawer
        control={selected}
        onClose={() => setSelected(null)}
        evidenceList={evidence}
        poamList={poams}
        onSave={(patch) => {
          if (selected) updateControl(selected.id, patch);
          setSelected(null);
        }}
      />
    </Box>
  );
}

interface DrawerProps {
  control: Control | null;
  onClose: () => void;
  evidenceList: ReturnType<typeof useGrc>['evidence'];
  poamList: ReturnType<typeof useGrc>['poams'];
  onSave: (patch: Partial<Control>) => void;
}

function ControlDetailDrawer({
  control,
  onClose,
  evidenceList,
  poamList,
  onSave,
}: DrawerProps) {
  const [draft, setDraft] = useState<Control | null>(control);

  // Re-seed draft whenever a different control is selected
  if (control && (!draft || draft.id !== control.id)) {
    setDraft(control);
  }
  if (!control || !draft) {
    return (
      <Drawer anchor="right" open={false} onClose={onClose}>
        <Box />
      </Drawer>
    );
  }

  const relatedEvidence = evidenceList.filter((e) => e.controlId === control.id);
  const relatedPoam = poamList.find((p) => p.id === control.poamId);

  return (
    <Drawer
      anchor="right"
      open={!!control}
      onClose={onClose}
      PaperProps={{ sx: { width: { xs: '100%', md: 560 } } }}
    >
      <Box sx={{ p: 3, display: 'flex', flexDirection: 'column', height: '100%' }}>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 1 }}>
          <Box>
            <Typography variant="caption" sx={{ color: '#6B7280', fontFamily: 'monospace' }}>
              {control.id} · SSP §{control.ssp}
            </Typography>
            <Typography variant="h6" sx={{ fontWeight: 700 }}>
              {control.practice}
            </Typography>
            <Typography variant="caption" sx={{ color: '#6B7280' }}>
              {control.family}
            </Typography>
          </Box>
          <IconButton onClick={onClose}>
            <X size={20} />
          </IconButton>
        </Box>
        <Divider sx={{ mb: 2 }} />

        <Stack spacing={2} sx={{ flexGrow: 1, overflow: 'auto', pr: 0.5 }}>
          <Alert severity="info" icon={<FileText size={16} />}>
            {control.description}
          </Alert>

          <FormControl size="small" fullWidth>
            <InputLabel>Implementation Status</InputLabel>
            <Select
              value={draft.status}
              label="Implementation Status"
              onChange={(e) => setDraft({ ...draft, status: e.target.value as ControlStatus })}
            >
              {STATUS_OPTIONS.map((s) => (
                <MenuItem key={s} value={s}>
                  {s}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

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

          <TextField
            size="small"
            label="Owner"
            value={draft.owner}
            onChange={(e) => setDraft({ ...draft, owner: e.target.value })}
            placeholder="e.g. Security Engineering"
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

          <TextField
            size="small"
            label="Implementation narrative"
            value={draft.narrative}
            onChange={(e) => setDraft({ ...draft, narrative: e.target.value })}
            multiline
            minRows={4}
            placeholder="Describe how this control is implemented in the system…"
            fullWidth
          />

          <TextField
            size="small"
            label="Notes"
            value={draft.notes}
            onChange={(e) => setDraft({ ...draft, notes: e.target.value })}
            multiline
            minRows={2}
            fullWidth
          />

          <Box>
            <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1 }}>
              Evidence ({relatedEvidence.length})
            </Typography>
            {relatedEvidence.length === 0 ? (
              <Typography variant="body2" sx={{ color: '#9CA3AF' }}>
                No evidence linked yet. Upload from the Evidence Repository.
              </Typography>
            ) : (
              <Stack spacing={1}>
                {relatedEvidence.map((e) => (
                  <Box
                    key={e.id}
                    sx={{
                      p: 1,
                      border: '1px solid #E5E7EB',
                      borderRadius: 1,
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <Box>
                      <Typography variant="body2" sx={{ fontWeight: 500 }}>
                        {e.fileName}
                      </Typography>
                      <Typography variant="caption" sx={{ color: '#6B7280' }}>
                        Uploaded {e.uploadDate} · v{e.version}
                      </Typography>
                    </Box>
                    <Chip
                      size="small"
                      label={e.status}
                      color={
                        e.status === 'Valid'
                          ? 'success'
                          : e.status === 'Expiring Soon'
                            ? 'warning'
                            : 'error'
                      }
                    />
                  </Box>
                ))}
              </Stack>
            )}
          </Box>

          {relatedPoam && (
            <Box>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1 }}>
                Linked POA&amp;M
              </Typography>
              <Box sx={{ p: 1.5, border: '1px solid #FCD34D', borderRadius: 1, backgroundColor: '#FFFBEB' }}>
                <Typography variant="caption" sx={{ color: '#92400E', fontFamily: 'monospace' }}>
                  {relatedPoam.id} · Due {relatedPoam.dueDate || '—'}
                </Typography>
                <Typography variant="body2">{relatedPoam.finding}</Typography>
              </Box>
            </Box>
          )}

          <Box sx={{ color: '#9CA3AF', fontSize: '0.75rem' }}>
            Last reviewed {draft.lastUpdated}
          </Box>
        </Stack>

        <Divider sx={{ my: 2 }} />
        <Stack direction="row" spacing={1} justifyContent="flex-end">
          <Button onClick={onClose}>Cancel</Button>
          <Button
            variant="contained"
            startIcon={<Save size={16} />}
            onClick={() => onSave(draft)}
          >
            Save changes
          </Button>
        </Stack>
      </Box>
    </Drawer>
  );
}
