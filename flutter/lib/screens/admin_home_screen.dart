import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth.dart';
import '../state/grc_store.dart';
import '../widgets/common.dart';

// Mock client engagements an RPO would oversee. Replace with real backend data.
class _Engagement {
  const _Engagement({
    required this.name,
    required this.industry,
    required this.stage,
    required this.readiness,
    required this.openPoams,
    required this.lastActivity,
  });
  final String name;
  final String industry;
  final String stage; // Pre-Assessment / Conformity / Reporting / Closeout
  final int readiness;
  final int openPoams;
  final String lastActivity;
}

const _demoEngagements = <_Engagement>[
  _Engagement(
      name: 'Atlas Aerospace',
      industry: 'Defense / Aviation',
      stage: 'Conformity Assessment',
      readiness: 92,
      openPoams: 2,
      lastActivity: '2h ago'),
  _Engagement(
      name: 'Beacon Logistics',
      industry: 'DoD Logistics',
      stage: 'Pre-Assessment',
      readiness: 71,
      openPoams: 6,
      lastActivity: '5h ago'),
  _Engagement(
      name: 'Cipher Robotics',
      industry: 'Autonomous Systems',
      stage: 'Reporting',
      readiness: 88,
      openPoams: 3,
      lastActivity: '1d ago'),
  _Engagement(
      name: 'Delta Optics',
      industry: 'Optics / Imaging',
      stage: 'Closeout',
      readiness: 96,
      openPoams: 0,
      lastActivity: '3d ago'),
  _Engagement(
      name: 'Echo Cybersecurity',
      industry: 'IT Services',
      stage: 'Pre-Assessment',
      readiness: 54,
      openPoams: 11,
      lastActivity: '7d ago'),
];

const _gold = Color(0xFFE9C56F);
const _goldDeep = Color(0xFFC79B3D);
const _ink = Color(0xFF03050E);
const _inkSoft = Color(0xFF0B0E22);
const _surface = Color(0xFF101430);

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = isCompact(context);
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroPanel(compact: compact),
          Padding(
            padding: pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                _KpiGrid(engagements: _demoEngagements),
                const SizedBox(height: 20),
                LayoutBuilder(builder: (ctx, c) {
                  final wide = c.maxWidth >= 980;
                  final list = _EngagementCard(items: _demoEngagements);
                  final feed = _ActivityFeed();
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: list),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: feed),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [list, const SizedBox(height: 16), feed],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.compact});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AuthState>();
    final height = compact ? 320.0 : 380.0;
    return Container(
      height: height,
      decoration: const BoxDecoration(color: _ink),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero image with graceful fallback when the asset is missing
          Image.asset(
            'assets/images/admin_hero.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_ink, _inkSoft, Color(0xFF1A1206)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Dark scrim so foreground text is readable
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xCC03050E), Color(0x6603050E), Color(0x3303050E)],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Subtle gold accent line at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_goldDeep, _gold, _goldDeep]),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 20 : 40, vertical: compact ? 24 : 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.15),
                      border: Border.all(color: _gold),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.workspace_premium_outlined,
                          size: 14, color: _gold),
                      SizedBox(width: 6),
                      Text('RPO ADMIN CONSOLE',
                          style: TextStyle(
                              color: _gold,
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const Spacer(),
                  if (!compact)
                    _SignedInPill(name: admin.displayName ?? 'Administrator'),
                ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compact
                          ? 'Balance compliance.\nProve readiness.'
                          : 'Welcome back, ${(admin.displayName ?? 'Administrator').split(' ').first}.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 26 : 32,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: Text(
                        'Every CMMC engagement on a single scale. Track readiness, '
                        'orchestrate evidence, and ship audit-ready packets across '
                        'your full client roster.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: compact ? 13 : 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _gold,
                            foregroundColor: _ink,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _comingSoon(context),
                          icon: const Icon(Icons.add_business_outlined, size: 18),
                          label: const Text('Invite Client',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.4)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _comingSoon(context),
                          icon: const Icon(Icons.event_note_outlined, size: 18),
                          label: const Text('Schedule Assessment'),
                        ),
                      ],
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

class _SignedInPill extends StatelessWidget {
  const _SignedInPill({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const CircleAvatar(
          radius: 10,
          backgroundColor: _gold,
          child: Icon(Icons.person, size: 12, color: _ink),
        ),
        const SizedBox(width: 6),
        Text(name,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Sign out',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          icon: const Icon(Icons.logout, color: Colors.white70, size: 16),
          onPressed: () => context.read<AuthState>().signOut(),
        ),
      ]),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.engagements});
  final List<_Engagement> engagements;

  @override
  Widget build(BuildContext context) {
    final active = engagements.length;
    final inFlight = engagements
        .where((e) =>
            e.stage == 'Conformity Assessment' || e.stage == 'Reporting')
        .length;
    final ready = engagements.where((e) => e.readiness >= 90).length;
    final atRisk = engagements.where((e) => e.readiness < 70).length;

    final tiles = <_KpiData>[
      _KpiData(
          icon: Icons.handshake_outlined,
          label: 'Active Engagements',
          value: '$active',
          helper: 'Client OSCs under management',
          color: _gold),
      _KpiData(
          icon: Icons.bolt_outlined,
          label: 'Assessments In-Flight',
          value: '$inFlight',
          helper: 'Currently in conformity / reporting',
          color: const Color(0xFF60A5FA)),
      _KpiData(
          icon: Icons.workspace_premium_outlined,
          label: 'Ready for C3PAO',
          value: '$ready',
          helper: 'Readiness ≥ 90%',
          color: const Color(0xFF34D399)),
      _KpiData(
          icon: Icons.error_outline,
          label: 'At-Risk Clients',
          value: '$atRisk',
          helper: 'Readiness < 70%',
          color: const Color(0xFFF87171)),
    ];

    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth >= 1100
          ? 4
          : c.maxWidth >= 720
              ? 2
              : 1;
      final gap = 12.0;
      final width = (c.maxWidth - (cols - 1) * gap) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final t in tiles) SizedBox(width: width, child: _AdminKpiTile(t)),
        ],
      );
    });
  }
}

class _KpiData {
  const _KpiData(
      {required this.icon,
      required this.label,
      required this.value,
      required this.helper,
      required this.color});
  final IconData icon;
  final String label;
  final String value;
  final String helper;
  final Color color;
}

class _AdminKpiTile extends StatelessWidget {
  const _AdminKpiTile(this.data);
  final _KpiData data;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: const Color(0xFF1F2547)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.18),
                border: Border.all(color: data.color.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(data.icon, color: data.color, size: 16),
            ),
            const Spacer(),
            Text(data.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                )),
          ]),
          const SizedBox(height: 12),
          Text(data.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(data.helper,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.55), fontSize: 11)),
        ],
      ),
    );
  }
}

class _EngagementCard extends StatelessWidget {
  const _EngagementCard({required this.items});
  final List<_Engagement> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: const Color(0xFF1F2547)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
            child: Row(
              children: [
                const Text('Client Engagements',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _comingSoon(context),
                  style: TextButton.styleFrom(foregroundColor: _gold),
                  icon: const Icon(Icons.unfold_more, size: 16),
                  label: const Text('View all'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1F2547)),
          for (var i = 0; i < items.length; i++)
            _EngagementRow(item: items[i], isLast: i == items.length - 1),
        ],
      ),
    );
  }
}

class _EngagementRow extends StatelessWidget {
  const _EngagementRow({required this.item, required this.isLast});
  final _Engagement item;
  final bool isLast;

  Color get _readinessColor => item.readiness >= 90
      ? const Color(0xFF34D399)
      : item.readiness >= 70
          ? const Color(0xFFFBBF24)
          : const Color(0xFFF87171);

  @override
  Widget build(BuildContext context) {
    final compact = isCompact(context);
    final ring = SizedBox(
      width: 44,
      height: 44,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            value: item.readiness / 100,
            strokeWidth: 4,
            backgroundColor: const Color(0xFF1F2547),
            valueColor: AlwaysStoppedAnimation(_readinessColor),
          ),
        ),
        Text('${item.readiness}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ]),
    );

    final detail = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        Text('${item.industry} · ${item.stage}',
            style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 12)),
      ],
    );

    final meta = Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _metaChip(Icons.warning_amber_outlined,
            '${item.openPoams} POA&M${item.openPoams == 1 ? "" : "s"}',
            item.openPoams == 0
                ? const Color(0xFF34D399)
                : const Color(0xFFFBBF24)),
        _metaChip(Icons.history, item.lastActivity, Colors.white60),
      ],
    );

    final go = IconButton(
      onPressed: () => _comingSoon(context),
      icon: const Icon(Icons.arrow_forward_ios, size: 14, color: _gold),
    );

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFF1F2547))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  ring,
                  const SizedBox(width: 12),
                  Expanded(child: detail),
                  go,
                ]),
                const SizedBox(height: 8),
                meta,
              ],
            )
          : Row(children: [
              ring,
              const SizedBox(width: 14),
              Expanded(child: detail),
              meta,
              const SizedBox(width: 8),
              go,
            ]),
    );
  }

  Widget _metaChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ]),
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  final _events = const [
    ('Atlas Aerospace', 'Uploaded SI.1.1.3 audit log', '2h ago',
        Icons.upload_file_outlined),
    ('Beacon Logistics', 'Marked AC.1.1.5 as In Progress', '5h ago',
        Icons.edit_outlined),
    ('Cipher Robotics', 'POAM-7K2 closed', '1d ago', Icons.check_circle_outline),
    ('Delta Optics', 'Annual affirmation submitted', '3d ago',
        Icons.verified_outlined),
    ('Echo Cybersecurity', 'New evidence: contingency plan v3', '7d ago',
        Icons.folder_open_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: const Color(0xFF1F2547)),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.bolt_outlined, color: _gold, size: 18),
            SizedBox(width: 6),
            Text('Recent Activity',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          for (final e in _events)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _ink,
                    border: Border.all(color: const Color(0xFF1F2547)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(e.$4, color: _gold, size: 14),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.$1,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text(e.$2,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(e.$3,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}

void _comingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Not wired to a backend in this demo build.'),
  ));
}
