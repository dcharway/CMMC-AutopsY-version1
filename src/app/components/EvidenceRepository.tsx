import { useMemo, useState } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Button,
  Chip,
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
  Tooltip,
  Autocomplete,
} from '@mui/material';
import {
  Upload,
  Trash2,
  CheckCircle2,
  AlertTriangle,
  XCircle,
  FileText,
  Tag as TagIcon,
  Search,
  ShieldCheck,
  ShieldAlert,
} from 'lucide-react';
import { Evidence } from '../data/cmmcControls';
import { useGrc, computeEvidenceStatus, checkNaming } from '../store/grcStore';

const COMMON_TAGS = ['policy', 'procedure', 'screenshot', 'log', 'audit', 'training', 'config'];

function inferTags(fileName: string, description: string): string[] {
  const blob = `${fileName} ${description}`.toLowerCase();
  return COMMON_TAGS.filter((t) => blob.includes(t));
}

export function EvidenceRepository() {
  const { evidence, controls, addEvidence, removeEvidence } = useGrc();
  const [query, setQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'All' | Evidence['status']>('All');
  const [showUpload, setShowUpload] = useState(false);

  const enriched = useMemo(
    () => evidence.map((e) => ({ ...e, status: computeEvidenceStatus(e) })),
    [evidence],
  );

  const filtered = enriched.filter((e) => {
    const matchesQuery = query
      ? `${e.fileName} ${e.controlId} ${e.description} ${e.tags.join(' ')}`
          .toLowerCase()
          .includes(query.toLowerCase())
      : true;
    const matchesStatus = statusFilter === 'All' || e.status === statusFilter;
    return matchesQuery && matchesStatus;
  });

  const summary = useMemo(() => {
    return {
      total: enriched.length,
      valid: enriched.filter((e) => e.status === 'Valid').length,
      expiring: enriched.filter((e) => e.status === 'Expiring Soon').length,
      expired: enriched.filter((e) => e.status === 'Expired').length,
      misnamed: enriched.filter((e) => !e.validNaming).length,
    };
  }, [enriched]);

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 700, mb: 0.5 }}>
            Evidence Repository
          </Typography>
          <Typography variant="body2" sx={{ color: '#6B7280' }}>
            Upload, tag, version, and validate evidence per control
          </Typography>
        </Box>
        <Button
          variant="contained"
          startIcon={<Upload size={16} />}
          onClick={() => setShowUpload(true)}
        >
          Upload Evidence
        </Button>
      </Box>

      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Tile label="Total Artifacts" value={summary.total} color="#2563EB" />
        <Tile label="Valid" value={summary.valid} color="#16A34A" />
        <Tile label="Expiring ≤30d" value={summary.expiring} color="#F59E0B" />
        <Tile label="Expired" value={summary.expired} color="#DC2626" />
        <Tile label="Naming issues" value={summary.misnamed} color="#7E22CE" />
      </Grid>

      {summary.expiring + summary.expired > 0 && (
        <Alert severity="warning" sx={{ mb: 2 }} icon={<AlertTriangle size={18} />}>
          {summary.expired} expired and {summary.expiring} expiring evidence artifact
          {summary.expiring !== 1 && 's'} — refresh before assessment.
        </Alert>
      )}

      <Card variant="outlined" sx={{ mb: 2 }}>
        <CardContent>
          <Stack direction={{ xs: 'column', md: 'row' }} spacing={2}>
            <TextField
              size="small"
              fullWidth
              placeholder="Search by file name, control, tag…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              InputProps={{
                startAdornment: <Search size={16} style={{ marginRight: 8, color: '#6B7280' }} />,
              }}
            />
            <FormControl size="small" sx={{ minWidth: 200 }}>
              <InputLabel>Status</InputLabel>
              <Select
                value={statusFilter}
                label="Status"
                onChange={(e) => setStatusFilter(e.target.value as Evidence['status'] | 'All')}
              >
                <MenuItem value="All">All statuses</MenuItem>
                <MenuItem value="Valid">Valid</MenuItem>
                <MenuItem value="Expiring Soon">Expiring Soon</MenuItem>
                <MenuItem value="Expired">Expired</MenuItem>
              </Select>
            </FormControl>
          </Stack>
        </CardContent>
      </Card>

      <TableContainer component={Paper} variant="outlined">
        <Table size="small">
          <TableHead>
            <TableRow sx={{ backgroundColor: '#F9FAFB' }}>
              <TableCell sx={{ fontWeight: 600 }}>File</TableCell>
              <TableCell sx={{ fontWeight: 600 }}>Control</TableCell>
              <TableCell sx={{ fontWeight: 600 }}>Tags</TableCell>
              <TableCell sx={{ fontWeight: 600 }}>Uploaded</TableCell>
              <TableCell sx={{ fontWeight: 600 }}>Expires</TableCell>
              <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
              <TableCell sx={{ fontWeight: 600, textAlign: 'center' }}>Naming</TableCell>
              <TableCell sx={{ fontWeight: 600, textAlign: 'right' }}>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filtered.map((e) => (
              <TableRow key={e.id} hover>
                <TableCell>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <FileText size={16} color="#6B7280" />
                    <Box>
                      <Typography variant="body2" sx={{ fontWeight: 500 }}>
                        {e.fileName}
                      </Typography>
                      {e.description && (
                        <Typography variant="caption" sx={{ color: '#6B7280' }}>
                          {e.description}
                        </Typography>
                      )}
                    </Box>
                  </Box>
                </TableCell>
                <TableCell sx={{ fontFamily: 'monospace' }}>{e.controlId}</TableCell>
                <TableCell>
                  <Stack direction="row" spacing={0.5} flexWrap="wrap">
                    {e.tags.map((t) => (
                      <Chip
                        key={t}
                        label={t}
                        size="small"
                        icon={<TagIcon size={10} />}
                        sx={{ height: 20, fontSize: '0.7rem' }}
                      />
                    ))}
                  </Stack>
                </TableCell>
                <TableCell>
                  <Typography variant="body2">{e.uploadDate}</Typography>
                  <Typography variant="caption" sx={{ color: '#6B7280' }}>
                    v{e.version} · {e.uploadedBy || 'unknown'}
                  </Typography>
                </TableCell>
                <TableCell>{e.expirationDate || <span style={{ color: '#9CA3AF' }}>—</span>}</TableCell>
                <TableCell>
                  <StatusBadge status={e.status} />
                </TableCell>
                <TableCell sx={{ textAlign: 'center' }}>
                  {e.validNaming ? (
                    <Tooltip title="Matches CMMC convention">
                      <Box sx={{ display: 'inline-flex' }}>
                        <ShieldCheck size={18} color="#16A34A" />
                      </Box>
                    </Tooltip>
                  ) : (
                    <Tooltip title="Expected: ControlID_Description_YYYY-MM-DD.ext">
                      <Box sx={{ display: 'inline-flex' }}>
                        <ShieldAlert size={18} color="#DC2626" />
                      </Box>
                    </Tooltip>
                  )}
                </TableCell>
                <TableCell sx={{ textAlign: 'right' }}>
                  <Tooltip title="Delete">
                    <IconButton size="small" onClick={() => removeEvidence(e.id)}>
                      <Trash2 size={14} />
                    </IconButton>
                  </Tooltip>
                </TableCell>
              </TableRow>
            ))}
            {filtered.length === 0 && (
              <TableRow>
                <TableCell colSpan={8} sx={{ textAlign: 'center', py: 4, color: '#9CA3AF' }}>
                  No evidence yet — click “Upload Evidence” to add an artifact.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>

      <UploadDialog
        open={showUpload}
        onClose={() => setShowUpload(false)}
        controls={controls.map((c) => ({ id: c.id, label: `${c.id} — ${c.practice}` }))}
        onUpload={(e) => {
          addEvidence(e);
          setShowUpload(false);
        }}
      />
    </Box>
  );
}

function Tile({ label, value, color }: { label: string; value: number; color: string }) {
  return (
    <Grid item xs={6} md={2.4}>
      <Card variant="outlined">
        <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
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

function StatusBadge({ status }: { status: Evidence['status'] }) {
  const map: Record<Evidence['status'], { icon: JSX.Element; color: 'success' | 'warning' | 'error' }> = {
    Valid: { icon: <CheckCircle2 size={12} />, color: 'success' },
    'Expiring Soon': { icon: <AlertTriangle size={12} />, color: 'warning' },
    Expired: { icon: <XCircle size={12} />, color: 'error' },
  };
  const m = map[status];
  return <Chip icon={m.icon} label={status} size="small" color={m.color} />;
}

interface UploadProps {
  open: boolean;
  onClose: () => void;
  controls: { id: string; label: string }[];
  onUpload: (e: Omit<Evidence, 'id'>) => void;
}

function UploadDialog({ open, onClose, controls, onUpload }: UploadProps) {
  const today = new Date().toISOString().slice(0, 10);
  const [controlId, setControlId] = useState('');
  const [fileName, setFileName] = useState('');
  const [description, setDescription] = useState('');
  const [uploadedBy, setUploadedBy] = useState('');
  const [expirationDate, setExpirationDate] = useState('');
  const [tags, setTags] = useState<string[]>([]);

  // simulate file picker — name only (no backend in this MVP)
  const onFile = (file: File) => {
    setFileName(file.name);
    const suggested = inferTags(file.name, description);
    if (suggested.length && tags.length === 0) setTags(suggested);
  };

  const reset = () => {
    setControlId('');
    setFileName('');
    setDescription('');
    setUploadedBy('');
    setExpirationDate('');
    setTags([]);
  };

  const namingValid = fileName ? checkNaming(fileName) : true;

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>Upload Evidence</DialogTitle>
      <DialogContent dividers>
        <Stack spacing={2}>
          <Alert severity="info">
            <strong>Naming convention:</strong>{' '}
            <code>ControlID_ArtifactDescription_YYYY-MM-DD.ext</code> — e.g.{' '}
            <code>AC.1.1.1_AccessControlPolicy_2026-04-01.pdf</code>
          </Alert>
          <FormControl size="small" fullWidth required>
            <InputLabel>Related control</InputLabel>
            <Select
              value={controlId}
              label="Related control"
              onChange={(e) => setControlId(e.target.value)}
            >
              {controls.map((c) => (
                <MenuItem key={c.id} value={c.id}>
                  {c.label}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <Button
            component="label"
            variant="outlined"
            startIcon={<Upload size={16} />}
            sx={{ alignSelf: 'flex-start' }}
          >
            {fileName || 'Choose file'}
            <input
              type="file"
              hidden
              onChange={(e) => {
                const f = e.target.files?.[0];
                if (f) onFile(f);
              }}
            />
          </Button>
          {fileName && !namingValid && (
            <Alert severity="warning" icon={<ShieldAlert size={16} />}>
              File name does not match the recommended naming convention. It will be flagged for
              the assessor.
            </Alert>
          )}

          <TextField
            size="small"
            label="Description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            multiline
            minRows={2}
            fullWidth
          />

          <Autocomplete
            multiple
            freeSolo
            size="small"
            options={COMMON_TAGS}
            value={tags}
            onChange={(_, v) => setTags(v as string[])}
            renderInput={(params) => <TextField {...params} label="Tags" placeholder="Add tag" />}
          />

          <Stack direction="row" spacing={2}>
            <TextField
              size="small"
              label="Uploaded by"
              value={uploadedBy}
              onChange={(e) => setUploadedBy(e.target.value)}
              fullWidth
            />
            <TextField
              size="small"
              type="date"
              label="Expiration date"
              value={expirationDate}
              onChange={(e) => setExpirationDate(e.target.value)}
              fullWidth
              InputLabelProps={{ shrink: true }}
            />
          </Stack>
        </Stack>
      </DialogContent>
      <DialogActions>
        <Button
          onClick={() => {
            reset();
            onClose();
          }}
        >
          Cancel
        </Button>
        <Button
          variant="contained"
          disabled={!controlId || !fileName}
          onClick={() => {
            onUpload({
              controlId,
              fileName,
              description,
              uploadDate: today,
              expirationDate,
              status: 'Valid',
              uploadedBy,
              version: 1,
              tags,
              validNaming: checkNaming(fileName),
            });
            reset();
          }}
        >
          Upload
        </Button>
      </DialogActions>
    </Dialog>
  );
}
