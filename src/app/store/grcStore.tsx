import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  ReactNode,
} from 'react';
import {
  Control,
  ControlStatus,
  Evidence,
  POAMItem,
  Affirmation,
  AssessmentChecklistItem,
  RiskLevel,
  controls as seedControls,
  evidenceList as seedEvidence,
  poamList as seedPoam,
  initialAffirmations,
  assessmentChecklist,
} from '../data/cmmcControls';

const LS_KEY = 'cmmc-grc-state-v1';

interface State {
  controls: Control[];
  evidence: Evidence[];
  poams: POAMItem[];
  affirmations: Affirmation[];
  checklist: AssessmentChecklistItem[];
}

interface GrcContext extends State {
  updateControl: (id: string, patch: Partial<Control>) => void;
  bulkUpdateStatus: (ids: string[], status: ControlStatus) => void;
  addEvidence: (e: Omit<Evidence, 'id'> & { id?: string }) => Evidence;
  removeEvidence: (id: string) => void;
  addPoam: (p: Omit<POAMItem, 'id'> & { id?: string }) => POAMItem;
  updatePoam: (id: string, patch: Partial<POAMItem>) => void;
  removePoam: (id: string) => void;
  updateAffirmation: (id: string, patch: Partial<Affirmation>) => void;
  toggleChecklist: (id: string) => void;
  setChecklistBlocker: (id: string, blocker: string) => void;
  resetAll: () => void;
}

const Ctx = createContext<GrcContext | null>(null);

function loadState(): State {
  if (typeof window === 'undefined') {
    return {
      controls: seedControls,
      evidence: seedEvidence,
      poams: seedPoam,
      affirmations: initialAffirmations,
      checklist: assessmentChecklist,
    };
  }
  try {
    const raw = localStorage.getItem(LS_KEY);
    if (raw) {
      const parsed = JSON.parse(raw) as Partial<State>;
      // Always ensure the control catalogue is in sync with the latest seed
      // (controls are immutable identifiers — only their per-row state is editable).
      const stored = new Map((parsed.controls ?? []).map((c) => [c.id, c]));
      const merged = seedControls.map((c) => {
        const s = stored.get(c.id);
        return s ? { ...c, ...s } : c;
      });
      return {
        controls: merged,
        evidence: parsed.evidence ?? [],
        poams: parsed.poams ?? [],
        affirmations: parsed.affirmations ?? initialAffirmations,
        checklist: parsed.checklist ?? assessmentChecklist,
      };
    }
  } catch (err) {
    console.warn('GRC store: failed to parse persisted state', err);
  }
  return {
    controls: seedControls,
    evidence: seedEvidence,
    poams: seedPoam,
    affirmations: initialAffirmations,
    checklist: assessmentChecklist,
  };
}

function uid(prefix: string) {
  return `${prefix}-${Math.random().toString(36).slice(2, 8).toUpperCase()}`;
}

function today() {
  return new Date().toISOString().slice(0, 10);
}

function daysBetween(a: string, b: string) {
  if (!a || !b) return 0;
  const ms = new Date(a).getTime() - new Date(b).getTime();
  return Math.round(ms / 86400000);
}

export function computePoamDerivedStatus(p: POAMItem): POAMItem['status'] {
  if (p.status === 'Completed') return 'Completed';
  if (!p.dueDate) return p.status;
  const overdue = daysBetween(p.dueDate, today()) < 0;
  return overdue ? 'Overdue' : p.status;
}

export function computeEvidenceStatus(e: Evidence): Evidence['status'] {
  if (!e.expirationDate) return 'Valid';
  const diff = daysBetween(e.expirationDate, today());
  if (diff < 0) return 'Expired';
  if (diff <= 30) return 'Expiring Soon';
  return 'Valid';
}

// Naming convention: ControlID_ArtifactDescription_YYYY-MM-DD.ext
const NAMING_RE = /^[A-Z]{2}\.\d+\.\d+\.\d+_[A-Za-z0-9-]+_\d{4}-\d{2}-\d{2}\.[A-Za-z0-9]+$/;
export function checkNaming(fileName: string): boolean {
  return NAMING_RE.test(fileName);
}

export function GrcProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<State>(() => loadState());

  useEffect(() => {
    try {
      localStorage.setItem(LS_KEY, JSON.stringify(state));
    } catch (err) {
      console.warn('GRC store: persist failed', err);
    }
  }, [state]);

  const value: GrcContext = useMemo(() => {
    return {
      ...state,
      updateControl(id, patch) {
        setState((s) => ({
          ...s,
          controls: s.controls.map((c) =>
            c.id === id ? { ...c, ...patch, lastUpdated: today() } : c,
          ),
        }));
      },
      bulkUpdateStatus(ids, status) {
        const idSet = new Set(ids);
        setState((s) => ({
          ...s,
          controls: s.controls.map((c) =>
            idSet.has(c.id) ? { ...c, status, lastUpdated: today() } : c,
          ),
        }));
      },
      addEvidence(e) {
        const id = e.id ?? uid('EV');
        const ev: Evidence = {
          version: 1,
          tags: [],
          uploadedBy: '',
          description: '',
          uploadDate: today(),
          expirationDate: '',
          status: 'Valid',
          validNaming: checkNaming(e.fileName),
          ...e,
          id,
        };
        ev.status = computeEvidenceStatus(ev);
        setState((s) => {
          // attach evidence id to the control
          const controls = s.controls.map((c) =>
            c.id === ev.controlId && !c.evidenceIds.includes(id)
              ? { ...c, evidenceIds: [...c.evidenceIds, id], lastUpdated: today() }
              : c,
          );
          return { ...s, evidence: [...s.evidence, ev], controls };
        });
        return ev;
      },
      removeEvidence(id) {
        setState((s) => ({
          ...s,
          evidence: s.evidence.filter((e) => e.id !== id),
          controls: s.controls.map((c) =>
            c.evidenceIds.includes(id)
              ? { ...c, evidenceIds: c.evidenceIds.filter((x) => x !== id) }
              : c,
          ),
        }));
      },
      addPoam(p) {
        const id = p.id ?? uid('POAM');
        const item: POAMItem = {
          status: 'Open',
          createdDate: today(),
          assignedTo: '',
          remediationPlan: '',
          riskLevel: 'Medium' as RiskLevel,
          finding: '',
          dueDate: '',
          controlId: '',
          ...p,
          id,
        };
        setState((s) => {
          const controls = s.controls.map((c) =>
            c.id === item.controlId ? { ...c, poamId: id, lastUpdated: today() } : c,
          );
          return { ...s, poams: [...s.poams, item], controls };
        });
        return item;
      },
      updatePoam(id, patch) {
        setState((s) => ({
          ...s,
          poams: s.poams.map((p) => (p.id === id ? { ...p, ...patch } : p)),
        }));
      },
      removePoam(id) {
        setState((s) => ({
          ...s,
          poams: s.poams.filter((p) => p.id !== id),
          controls: s.controls.map((c) =>
            c.poamId === id ? { ...c, poamId: undefined } : c,
          ),
        }));
      },
      updateAffirmation(id, patch) {
        setState((s) => ({
          ...s,
          affirmations: s.affirmations.map((a) =>
            a.id === id ? { ...a, ...patch } : a,
          ),
        }));
      },
      toggleChecklist(id) {
        setState((s) => ({
          ...s,
          checklist: s.checklist.map((it) =>
            it.id === id ? { ...it, done: !it.done } : it,
          ),
        }));
      },
      setChecklistBlocker(id, blocker) {
        setState((s) => ({
          ...s,
          checklist: s.checklist.map((it) =>
            it.id === id ? { ...it, blocker } : it,
          ),
        }));
      },
      resetAll() {
        try {
          localStorage.removeItem(LS_KEY);
        } catch {
          /* noop */
        }
        setState({
          controls: seedControls,
          evidence: [],
          poams: [],
          affirmations: initialAffirmations,
          checklist: assessmentChecklist,
        });
      },
    };
  }, [state]);

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useGrc(): GrcContext {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error('useGrc must be used inside GrcProvider');
  return ctx;
}

// Derived selectors --------------------------------------------------------

export function useReadinessScore() {
  const { controls, poams, evidence, checklist } = useGrc();
  return useMemo(() => {
    const total = controls.length;
    const implemented = controls.filter(
      (c) => c.status === 'Implemented' || c.status === 'Not Applicable',
    ).length;
    const partial = controls.filter((c) => c.status === 'Partial').length;
    const inProgress = controls.filter((c) => c.status === 'In Progress').length;
    const notStarted = controls.filter((c) => c.status === 'Not Started').length;

    // Implementation Score (weighted)
    const impScore =
      ((implemented + partial * 0.5 + inProgress * 0.25) / Math.max(total, 1)) * 100;

    // POA&M penalty: open POA&Ms beyond 180 days reduce readiness
    const overduePoams = poams.filter(
      (p) => p.status !== 'Completed' && p.dueDate && new Date(p.dueDate) < new Date(),
    ).length;
    const poamPenalty = Math.min(15, overduePoams * 2);

    // Evidence completeness (controls implemented with evidence)
    const implementedControls = controls.filter((c) => c.status === 'Implemented');
    const withEvidence = implementedControls.filter((c) => c.evidenceIds.length > 0).length;
    const evidenceCoverage = implementedControls.length
      ? (withEvidence / implementedControls.length) * 100
      : 0;

    // Checklist completion
    const checklistDone = checklist.filter((i) => i.done).length;
    const checklistPct = (checklistDone / Math.max(checklist.length, 1)) * 100;

    const readiness = Math.max(
      0,
      Math.round(impScore * 0.6 + evidenceCoverage * 0.2 + checklistPct * 0.2 - poamPenalty),
    );

    // SPRS scoring (NIST 800-171 method): start at 110, subtract for un-met
    // controls based on weight assumptions (uniform -1 per un-met for simplicity).
    const unmet = controls.filter(
      (c) => c.status !== 'Implemented' && c.status !== 'Not Applicable',
    ).length;
    const sprs = 110 - unmet;

    const expiringEvidence = evidence.filter((e) => {
      if (!e.expirationDate) return false;
      const diff =
        (new Date(e.expirationDate).getTime() - Date.now()) / 86400000;
      return diff <= 30;
    }).length;

    return {
      total,
      implemented,
      inProgress,
      notStarted,
      partial,
      readiness,
      sprs,
      overduePoams,
      openPoams: poams.filter((p) => p.status === 'Open' || p.status === 'In Progress').length,
      expiringEvidence,
      evidenceCoverage: Math.round(evidenceCoverage),
      checklistPct: Math.round(checklistPct),
    };
  }, [controls, poams, evidence, checklist]);
}
