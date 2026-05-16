import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/auth.dart';
import '../state/grc_store.dart';
import '../widgets/common.dart';

const _gold = Color(0xFFE9C56F);
const _ink = Color(0xFF03050E);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GrcStore>();
    if (!store.hydrated) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProfileHero(),
          Padding(
            padding: pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IdentifiersSection(profile: store.profile),
                const SizedBox(height: 12),
                _ContractScopeSection(profile: store.profile),
                const SizedBox(height: 12),
                _SystemBoundarySection(profile: store.profile),
                const SizedBox(height: 12),
                _AssessmentHistorySection(profile: store.profile),
                const SizedBox(height: 12),
                _AffirmationSection(profile: store.profile),
                const SizedBox(height: 12),
                _PoamSection(profile: store.profile),
                const SizedBox(height: 12),
                _ContactsSection(profile: store.profile),
                const SizedBox(height: 12),
                _MetadataFooter(profile: store.profile),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    final compact = isCompact(context);
    final profile = context.watch<GrcStore>().profile;
    final name = profile.organizationName.isEmpty
        ? 'Organization Seeking Assessment'
        : profile.organizationName;
    final height = compact ? 240.0 : 320.0;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/admin_hero.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_ink, Color(0xFF0B0E22), Color(0xFF1A1206)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xDD03050E), Color(0x9903050E), Color(0x4403050E)],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient:
                    LinearGradient(colors: [Color(0xFFC79B3D), _gold, Color(0xFFC79B3D)]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 20 : 40, vertical: compact ? 20 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.15),
                    border: Border.all(color: _gold),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.business_center_outlined, size: 14, color: _gold),
                    SizedBox(width: 6),
                    Text('OSA PROFILE',
                        style: TextStyle(
                            color: _gold,
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 24 : 32,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: Text(
                        'Enterprise profile required by the C3PAO and SPRS. '
                        'Sections auto-save as you edit.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: compact ? 12 : 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section scaffold ──────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.child,
    this.initiallyExpanded = true,
  });
  final String number;
  final String title;
  final String subtitle;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(number,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF2563EB))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ]),
        children: [child],
      ),
    );
  }
}

// Lightweight controller bag so we can debounce-save easily.
typedef _Saver = void Function(void Function(EnterpriseProfile p) fn);

_Saver _saverFor(BuildContext context) {
  final store = context.read<GrcStore>();
  final auth = context.read<AuthState>();
  return (fn) => store.mutateProfile(fn,
      updatedBy: auth.displayName ?? auth.email ?? '');
}

Widget _field(String label, String value, ValueChanged<String> onChanged,
    {int maxLines = 1, String? hint, TextInputType? keyboardType}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextFormField(
      initialValue: value,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    ),
  );
}

class _ChipListField extends StatefulWidget {
  const _ChipListField({
    required this.label,
    required this.values,
    required this.onChanged,
  });
  final String label;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_ChipListField> createState() => _ChipListFieldState();
}

class _ChipListFieldState extends State<_ChipListField> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _add() {
    final v = _ctl.text.trim();
    if (v.isEmpty) return;
    final next = [...widget.values, v];
    widget.onChanged(next);
    _ctl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _ctl,
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: 'Type and press +',
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
                icon: const Icon(Icons.add), onPressed: _add),
          ]),
          if (widget.values.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final v in widget.values)
                    InputChip(
                      label: Text(v),
                      onDeleted: () {
                        final next =
                            widget.values.where((x) => x != v).toList();
                        widget.onChanged(next);
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ContactBlock extends StatelessWidget {
  const _ContactBlock({
    required this.label,
    required this.contact,
    required this.onChange,
  });
  final String label;
  final ContactPerson contact;
  final void Function(ContactPerson) onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFFAFBFC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.person_outline, size: 16, color: Color(0xFF334155)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A))),
          ]),
          TwoColumn(
            left: _field('Name', contact.name, (v) {
              contact.name = v;
              onChange(contact);
            }),
            right: _field('Title', contact.title, (v) {
              contact.title = v;
              onChange(contact);
            }),
          ),
          TwoColumn(
            left: _field('Email', contact.email, (v) {
              contact.email = v;
              onChange(contact);
            }, keyboardType: TextInputType.emailAddress),
            right: _field('Phone', contact.phone, (v) {
              contact.phone = v;
              onChange(contact);
            }, keyboardType: TextInputType.phone),
          ),
        ],
      ),
    );
  }
}

// ─── Sections ──────────────────────────────────────────────────────────────

class _IdentifiersSection extends StatelessWidget {
  const _IdentifiersSection({required this.profile});
  final EnterpriseProfile profile;

  @override
  Widget build(BuildContext context) {
    final save = _saverFor(context);
    return _Section(
      number: '1',
      title: 'Organizational Identifiers',
      subtitle: 'Required by C3PAO + SPRS',
      child: Column(children: [
        _field('Organization name (legal entity)', profile.organizationName,
            (v) => save((p) => p.organizationName = v)),
        _field('DBA name (if different)', profile.dbaName,
            (v) => save((p) => p.dbaName = v)),
        TwoColumn(
          left: _field('CAGE code (5 chars)', profile.cageCode,
              (v) => save((p) => p.cageCode = v)),
          right: _field('DUNS (9 digits)', profile.dunsNumber,
              (v) => save((p) => p.dunsNumber = v),
              keyboardType: TextInputType.number),
        ),
        TwoColumn(
          left: _field('UEI (12 chars, SAM.gov)', profile.uei,
              (v) => save((p) => p.uei = v)),
          right: _field('Tax ID (TIN)', profile.tin,
              (v) => save((p) => p.tin = v)),
        ),
      ]),
    );
  }
}

class _ContractScopeSection extends StatelessWidget {
  const _ContractScopeSection({required this.profile});
  final EnterpriseProfile profile;
  @override
  Widget build(BuildContext context) {
    final save = _saverFor(context);
    return _Section(
      number: '2',
      title: 'DoD Contract Info',
      subtitle: 'Scope determination',
      child: Column(children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Prime contractor'),
          value: profile.isPrimeContractor,
          onChanged: (v) => save((p) => p.isPrimeContractor = v),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Subcontractor'),
          value: profile.isSubcontractor,
          onChanged: (v) => save((p) => p.isSubcontractor = v),
        ),
        if (profile.isSubcontractor)
          _field("Prime contractor's CAGE code", profile.primeCageCode,
              (v) => save((p) => p.primeCageCode = v)),
        _ChipListField(
          label: 'DoD contract numbers (with 7012 clause)',
          values: profile.dodContractNumbers,
          onChanged: (v) => save((p) => p.dodContractNumbers = v),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Handles CUI'),
          subtitle: const Text('Yes → CMMC Level 2 required',
              style: TextStyle(fontSize: 11)),
          value: profile.handlesCUI,
          onChanged: (v) => save((p) => p.handlesCUI = v),
        ),
        _ChipListField(
          label: 'CUI categories (e.g. CTI, Proprietary)',
          values: profile.cuiCategories,
          onChanged: (v) => save((p) => p.cuiCategories = v),
        ),
        _field('Estimated CUI users', '${profile.estimatedCUIUsers}',
            (v) => save((p) => p.estimatedCUIUsers = int.tryParse(v) ?? 0),
            keyboardType: TextInputType.number),
      ]),
    );
  }
}

class _SystemBoundarySection extends StatelessWidget {
  const _SystemBoundarySection({required this.profile});
  final EnterpriseProfile profile;
  @override
  Widget build(BuildContext context) {
    final save = _saverFor(context);
    return _Section(
      number: '3',
      title: 'System Boundary',
      subtitle: 'NIST SP 800-171A',
      child: Column(children: [
        _field('System name', profile.systemName,
            (v) => save((p) => p.systemName = v),
            hint: 'e.g. CyberAutopsy CUI Enclave'),
        _field('System boundary description',
            profile.systemBoundaryDescription,
            (v) => save((p) => p.systemBoundaryDescription = v),
            maxLines: 4,
            hint: 'What is IN scope — 2-3 paragraphs'),
        _field('Authorization boundary (diagram reference)',
            profile.authorizationBoundary,
            (v) => save((p) => p.authorizationBoundary = v)),
        TwoColumn(
          left: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: DropdownButtonFormField<HostingType>(
              value: profile.hostingType,
              decoration: const InputDecoration(
                labelText: 'Hosting type',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                for (final h in HostingType.values)
                  DropdownMenuItem(value: h, child: Text(h.label)),
              ],
              onChanged: (v) =>
                  save((p) => p.hostingType = v ?? HostingType.onPrem),
            ),
          ),
          right: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: DropdownButtonFormField<CloudProvider>(
              value: profile.cloudProvider,
              decoration: const InputDecoration(
                labelText: 'Cloud provider',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                for (final cp in CloudProvider.values)
                  DropdownMenuItem(value: cp, child: Text(cp.label)),
              ],
              onChanged: (v) =>
                  save((p) => p.cloudProvider = v ?? CloudProvider.none),
            ),
          ),
        ),
        if (profile.hostingType != HostingType.onPrem)
          _field('FedRAMP package ID', profile.fedrampId,
              (v) => save((p) => p.fedrampId = v)),
        _ContactBlock(
          label: 'System Owner',
          contact: profile.systemOwner,
          onChange: (c) => save((p) => p.systemOwner = c),
        ),
        _ContactBlock(
          label: 'Information System Security Officer (ISSO)',
          contact: profile.isso,
          onChange: (c) => save((p) => p.isso = c),
        ),
      ]),
    );
  }
}

class _AssessmentHistorySection extends StatelessWidget {
  const _AssessmentHistorySection({required this.profile});
  final EnterpriseProfile profile;
  @override
  Widget build(BuildContext context) {
    final save = _saverFor(context);
    return _Section(
      number: '4',
      title: 'CMMC Assessment History',
      subtitle: 'SPRS + C3PAO record',
      child: Column(children: [
        TwoColumn(
          left: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: DropdownButtonFormField<int>(
              value: profile.cmmcLevel.clamp(1, 3),
              decoration: const InputDecoration(
                labelText: 'CMMC level',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Level 1')),
                DropdownMenuItem(value: 2, child: Text('Level 2')),
                DropdownMenuItem(value: 3, child: Text('Level 3')),
              ],
              onChanged: (v) => save((p) => p.cmmcLevel = v ?? 2),
            ),
          ),
          right: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: DropdownButtonFormField<CertStatus>(
              value: profile.currentCertificationStatus,
              decoration: const InputDecoration(
                labelText: 'Certification status',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                for (final s in CertStatus.values)
                  DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              onChanged: (v) => save((p) =>
                  p.currentCertificationStatus = v ?? CertStatus.notAssessed),
            ),
          ),
        ),
        TwoColumn(
          left: _field('Last assessment date (YYYY-MM-DD)',
              profile.lastAssessmentDate,
              (v) => save((p) => p.lastAssessmentDate = v)),
          right: _field('Last assessment C3PAO',
              profile.lastAssessmentC3PAO,
              (v) => save((p) => p.lastAssessmentC3PAO = v)),
        ),
        _field('Last assessment report ID', profile.lastAssessmentReportId,
            (v) => save((p) => p.lastAssessmentReportId = v)),
        TwoColumn(
          left: _field('Current SPRS score (0-110)',
              '${profile.currentSPRSScore}',
              (v) => save(
                  (p) => p.currentSPRSScore = int.tryParse(v) ?? 0),
              keyboardType: TextInputType.number),
          right: _field('SPRS submission date',
              profile.sprsSubmissionDate,
              (v) => save((p) => p.sprsSubmissionDate = v)),
        ),
        _field('SPRS expiration date (3 years from submission)',
            profile.sprsExpirationDate,
            (v) => save((p) => p.sprsExpirationDate = v)),
      ]),
    );
  }
}

class _AffirmationSection extends StatelessWidget {
  const _AffirmationSection({required this.profile});
  final EnterpriseProfile profile;
  @override
  Widget build(BuildContext context) {
    final save = _saverFor(context);
    return _Section(
      number: '5',
      title: 'Affirmation Status',
      subtitle: '32 CFR 170.15',
      child: Column(children: [
        TwoColumn(
          left: _field('Last affirmation date',
              profile.lastAffirmationDate,
              (v) => save((p) => p.lastAffirmationDate = v)),
          right: _field('Next affirmation due',
              profile.nextAffirmationDue,
              (v) => save((p) => p.nextAffirmationDue = v)),
        ),
        _ContactBlock(
          label: 'Senior official who signs affirmation',
          contact: profile.affirmationPOC,
          onChange: (c) => save((p) => p.affirmationPOC = c),
        ),
      ]),
    );
  }
}

class _PoamSection extends StatelessWidget {
  const _PoamSection({required this.profile});
  final EnterpriseProfile profile;
  @override
  Widget build(BuildContext context) {
    final save = _saverFor(context);
    return _Section(
      number: '6',
      title: 'POA&M Status',
      subtitle: 'CMMC 2.0 allows limited POA&M, ≤180 days',
      child: Column(children: [
        TwoColumn(
          left: _field('Active POA&M count',
              '${profile.activePoamCount}',
              (v) => save(
                  (p) => p.activePoamCount = int.tryParse(v) ?? 0),
              keyboardType: TextInputType.number),
          right: _field('Oldest POA&M date',
              profile.oldestPoamDate,
              (v) => save((p) => p.oldestPoamDate = v)),
        ),
        _field('POA&M closeout plan date',
            profile.poamCloseoutPlanDate,
            (v) => save((p) => p.poamCloseoutPlanDate = v)),
      ]),
    );
  }
}

class _ContactsSection extends StatelessWidget {
  const _ContactsSection({required this.profile});
  final EnterpriseProfile profile;
  @override
  Widget build(BuildContext context) {
    final save = _saverFor(context);
    return _Section(
      number: '7',
      title: 'Contacts',
      subtitle: 'CAP requirement',
      child: Column(children: [
        _ContactBlock(
          label: 'Technical POC (for C3PAO questions)',
          contact: profile.technicalPOC,
          onChange: (c) => save((p) => p.technicalPOC = c),
        ),
        _ContactBlock(
          label: 'Business POC (contracts / legal)',
          contact: profile.businessPOC,
          onChange: (c) => save((p) => p.businessPOC = c),
        ),
        _ContactBlock(
          label: 'Incident Response POC (72-hr DoD reporting)',
          contact: profile.incidentResponsePOC,
          onChange: (c) => save((p) => p.incidentResponsePOC = c),
        ),
      ]),
    );
  }
}

class _MetadataFooter extends StatelessWidget {
  const _MetadataFooter({required this.profile});
  final EnterpriseProfile profile;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Icon(Icons.history, size: 14, color: Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Last updated ${profile.lastUpdated.isEmpty ? "—" : profile.lastUpdated}'
            '${profile.lastUpdatedBy.isEmpty ? "" : " by ${profile.lastUpdatedBy}"}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ),
        const Icon(Icons.cloud_done_outlined,
            size: 14, color: Color(0xFF16A34A)),
        const SizedBox(width: 4),
        const Text('Auto-saved',
            style: TextStyle(
                fontSize: 11,
                color: Color(0xFF15803D),
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
