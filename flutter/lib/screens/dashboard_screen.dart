import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/cmmc_controls.dart';
import '../data/models.dart';
import '../state/grc_store.dart';
import '../theme/metallic_theme.dart';
import '../widgets/common.dart';
import '../widgets/metallic.dart';

/// Mobile-first dashboard matching the cyberAutopsy GRC Figma —
/// gold "Total Risk Score" ring, 2×2 KPI grid, Recent Alerts, 12-feature
/// grid, Quick Actions.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GrcStore>();
    if (!store.hydrated) {
      return const Center(child: CircularProgressIndicator());
    }
    final r = computeReadiness(store);
    return SingleChildScrollView(
      padding: pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Greeting(),
          const SizedBox(height: 16),
          _RiskScoreHero(readiness: r, store: store),
          const SizedBox(height: 16),
          _KpiGrid(readiness: r, store: store),
          const SizedBox(height: 20),
          _QuickActions(),
          const SizedBox(height: 20),
          _RecentAlerts(store: store),
          const SizedBox(height: 20),
          const _SectionTitle('All 12 Features'),
          const SizedBox(height: 10),
          const _FeatureGrid(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: MT.goldGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: MT.goldBase.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: const Center(
            child: Text('CA',
                style: TextStyle(
                    color: MT.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            GoldEyebrow('Dashboard'),
            SizedBox(height: 4),
            Text('CyberAutopsy GRC',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: MT.textHigh)),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: MT.textHigh),
        ),
      ],
    );
  }
}

class _RiskScoreHero extends StatelessWidget {
  const _RiskScoreHero({required this.readiness, required this.store});
  final ReadinessScore readiness;
  final GrcStore store;

  @override
  Widget build(BuildContext context) {
    // Total Risk Score — mirror the Figma "742 / 75%" feel. We use the
    // readiness % as the ring value; 742 is a synthetic risk index seeded
    // from open POA&Ms + unmet controls (so it has a story even with no data).
    final unmet = store.controls
        .where((c) =>
            c.status != ControlStatus.implemented &&
            c.status != ControlStatus.notApplicable)
        .length;
    final openPoams = store.poams
        .where((p) => p.derivedStatus != PoamStatus.completed)
        .length;
    final totalRiskScore = 1000 - (unmet * 4 + openPoams * 6);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF161616), Color(0xFF1B1B1E), Color(0xFF101010)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: MT.goldBase.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GoldEyebrow('Total Risk Score'),
                const SizedBox(height: 8),
                GoldText(
                  '$totalRiskScore',
                  style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      height: 1.0),
                ),
                const SizedBox(height: 6),
                Row(children: const [
                  Icon(Icons.trending_up, size: 14, color: MT.success),
                  SizedBox(width: 4),
                  Text('+12% from last month',
                      style: TextStyle(
                          fontSize: 12,
                          color: MT.success,
                          fontWeight: FontWeight.w600)),
                ]),
              ],
            ),
          ),
          GoldProgressRing(
            value: readiness.readiness / 100,
            size: 110,
            strokeWidth: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GoldText('${readiness.readiness}%',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                const Text('Ready',
                    style: TextStyle(
                        fontSize: 10,
                        color: MT.textMid,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.readiness, required this.store});
  final ReadinessScore readiness;
  final GrcStore store;

  @override
  Widget build(BuildContext context) {
    final tiles = <_KpiData>[
      _KpiData(
        label: 'Controls',
        value: '${readiness.implemented + readiness.partial}',
        helper:
            '${((readiness.implemented + readiness.partial) / readiness.total.clamp(1, 999) * 100).round()}% compliant',
        icon: Icons.shield_outlined,
        accent: MT.success,
      ),
      _KpiData(
        label: 'High Risks',
        value: '${store.poams.where((p) => p.riskLevel == RiskLevel.high).length}',
        helper: 'Requires attention',
        icon: Icons.warning_amber_rounded,
        accent: MT.danger,
      ),
      _KpiData(
        label: 'Audits',
        value: '${store.checklist.length ~/ 4}',
        helper:
            '${store.checklist.where((c) => !c.done).length ~/ 4} in progress',
        icon: Icons.fact_check_outlined,
        accent: MT.info,
      ),
      _KpiData(
        label: 'POA&Ms',
        value: '${readiness.openPoams}',
        helper: '${readiness.overduePoams} overdue',
        icon: Icons.alt_route_rounded,
        accent: MT.warning,
      ),
    ];
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth >= 720 ? 4 : 2;
      final gap = 12.0;
      final w = (c.maxWidth - (cols - 1) * gap) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final t in tiles) SizedBox(width: w, child: _KpiCard(t))],
      );
    });
  }
}

class _KpiData {
  const _KpiData(
      {required this.label,
      required this.value,
      required this.helper,
      required this.icon,
      required this.accent});
  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final Color accent;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(this.data);
  final _KpiData data;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: MT.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: data.accent.withOpacity(0.14),
                border: Border.all(color: data.accent.withOpacity(0.45)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(data.icon, color: data.accent, size: 14),
            ),
            const Spacer(),
            Text(data.label,
                style: const TextStyle(
                    fontSize: 11,
                    color: MT.textMid,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 14),
          GoldText(
            data.value,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, height: 1.0),
          ),
          const SizedBox(height: 4),
          Text(data.helper,
              style: const TextStyle(fontSize: 11, color: MT.textLow)),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: GoldButton(
          label: 'New Assessment',
          icon: Icons.add_task_outlined,
          expanded: true,
          onPressed: () => _notImpl(context),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: MT.strokeSoft),
          ),
          icon: const Icon(Icons.insights_outlined,
              color: MT.goldLight, size: 18),
          label: const Text('View Reports'),
          onPressed: () => _notImpl(context),
        ),
      ),
    ]);
  }
}

class _RecentAlerts extends StatelessWidget {
  const _RecentAlerts({required this.store});
  final GrcStore store;

  @override
  Widget build(BuildContext context) {
    final events = <_AlertData>[];
    // Synthesise alerts from live data so this card has meaning even on
    // a fresh install.
    final overdue =
        store.poams.where((p) => p.derivedStatus == PoamStatus.overdue).toList();
    if (overdue.isNotEmpty) {
      events.add(_AlertData(
        icon: Icons.warning_amber_rounded,
        color: MT.danger,
        title: '${overdue.first.id} overdue',
        subtitle: overdue.first.finding.isEmpty
            ? 'Control ${overdue.first.controlId}'
            : overdue.first.finding,
        when: 'now',
      ));
    }
    final expiring = store.evidence
        .where((e) => e.status == EvidenceStatus.expiringSoon)
        .toList();
    if (expiring.isNotEmpty) {
      events.add(_AlertData(
        icon: Icons.timelapse_rounded,
        color: MT.warning,
        title: 'Evidence expiring soon',
        subtitle: expiring.first.fileName,
        when: 'today',
      ));
    }
    final done = store.checklist.where((c) => c.done).length;
    if (done > 0) {
      events.add(_AlertData(
        icon: Icons.check_circle_outline,
        color: MT.success,
        title: 'Compliance check completed',
        subtitle: '$done / ${store.checklist.length} workflow items done',
        when: 'recent',
      ));
    }
    if (events.isEmpty) {
      events.add(const _AlertData(
        icon: Icons.assignment_outlined,
        color: MT.info,
        title: 'No active alerts',
        subtitle: 'Add controls, POA&Ms, or evidence to start scoring',
        when: '—',
      ));
    }

    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Text('Recent Alerts',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('View all')),
          ]),
          const SizedBox(height: 6),
          for (var i = 0; i < events.length; i++)
            Padding(
              padding: EdgeInsets.only(
                  top: i == 0 ? 0 : 10, bottom: i == events.length - 1 ? 0 : 0),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: events[i].color.withOpacity(0.14),
                    border:
                        Border.all(color: events[i].color.withOpacity(0.45)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(events[i].icon, size: 16, color: events[i].color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(events[i].title,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: MT.textHigh)),
                      Text(events[i].subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: MT.textMid)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(events[i].when,
                    style: const TextStyle(
                        fontSize: 11, color: MT.textLow)),
              ]),
            ),
        ],
      ),
    );
  }
}

class _AlertData {
  const _AlertData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.when,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String when;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(text,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MT.textHigh)),
      const Spacer(),
      const Icon(Icons.expand_more, color: MT.textMid, size: 18),
    ]);
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();
  @override
  Widget build(BuildContext context) {
    const features = <_Feature>[
      _Feature(Icons.dashboard_outlined, 'Dashboard',
          'KPI metrics with gold progress rings'),
      _Feature(Icons.business_center_outlined, 'Organization Profile',
          'Company info and CMMC level details'),
      _Feature(Icons.fact_check_outlined, 'Control Registry',
          '120 controls with compliance tracking'),
      _Feature(Icons.warning_amber_rounded, 'Risk Register',
          'Risk assessment with severity indicators'),
      _Feature(Icons.alt_route_rounded, 'POA&M Tracker',
          'Timeline view with milestone tracking'),
      _Feature(Icons.folder_open_outlined, 'Evidence Repository',
          'Document management and verification'),
      _Feature(Icons.task_alt_outlined, 'Readiness Checklist',
          'Compliance progress by category'),
      _Feature(Icons.checklist_outlined, 'Assessment Workflow',
          'Step-by-step assessment process'),
      _Feature(Icons.verified_user_outlined, 'Affirmations',
          'Sign-off and compliance attestations'),
      _Feature(Icons.auto_awesome_outlined, 'AI Insights',
          'Intelligent recommendations', badge: 'NEW'),
      _Feature(Icons.download_outlined, 'Export Center',
          'Generate compliance reports'),
      _Feature(Icons.history_outlined, 'Audit Timeline',
          'Historical audit tracking'),
    ];
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth >= 900
          ? 4
          : c.maxWidth >= 600
              ? 3
              : 2;
      final gap = 10.0;
      final w = (c.maxWidth - (cols - 1) * gap) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final f in features) SizedBox(width: w, child: _FeatureTile(f)),
        ],
      );
    });
  }
}

class _Feature {
  const _Feature(this.icon, this.title, this.subtitle, {this.badge});
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile(this.f);
  final _Feature f;
  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(12),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: MT.goldBase.withOpacity(0.12),
                border: Border.all(color: MT.goldBase.withOpacity(0.45)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(f.icon, size: 16, color: MT.goldLight),
            ),
            const Spacer(),
            if (f.badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: MT.goldGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(f.badge!,
                    style: const TextStyle(
                        color: MT.ink,
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
              ),
          ]),
          const SizedBox(height: 10),
          Text(f.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: MT.textHigh)),
          const SizedBox(height: 2),
          Text(f.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: MT.textMid)),
        ],
      ),
    );
  }
}

void _notImpl(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Coming soon in the next iteration.'),
  ));
}
