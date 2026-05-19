import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/admin_home_screen.dart';
import 'screens/affirmations_screen.dart';
import 'screens/ai_insights_screen.dart';
import 'screens/assessment_workflow_screen.dart';
import 'screens/control_registry_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/evidence_repository_screen.dart';
import 'screens/export_center_screen.dart';
import 'screens/poam_tracker_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/readiness_checklist_screen.dart';
import 'screens/settings_screen.dart';
import 'state/auth.dart';
import 'theme/metallic_theme.dart';

class CyberAutopsyApp extends StatelessWidget {
  const CyberAutopsyApp({super.key});

  @override
  Widget build(BuildContext context) => const _Shell();
}

class _NavEntry {
  const _NavEntry(this.label, this.icon, this.builder,
      {this.badge, this.adminOnly = false});
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
  final String? badge;
  final bool adminOnly;
}

final _navEntries = <_NavEntry>[
  _NavEntry('Admin Home', Icons.workspace_premium_outlined,
      (_) => const AdminHomeScreen(),
      adminOnly: true),
  _NavEntry('Organization Profile', Icons.business_center_outlined,
      (_) => const ProfileScreen()),
  _NavEntry('Dashboard', Icons.dashboard_outlined, (_) => const DashboardScreen()),
  _NavEntry('Control Registry', Icons.fact_check_outlined, (_) => const ControlRegistryScreen()),
  _NavEntry('POA&M Tracker', Icons.warning_amber_outlined, (_) => const PoamTrackerScreen()),
  _NavEntry('Evidence Repository', Icons.folder_open_outlined, (_) => const EvidenceRepositoryScreen()),
  _NavEntry('Readiness Checklist', Icons.task_alt_outlined, (_) => const ReadinessChecklistScreen()),
  _NavEntry('Assessment Workflow', Icons.checklist_outlined, (_) => const AssessmentWorkflowScreen()),
  _NavEntry('Affirmations', Icons.verified_user_outlined, (_) => const AffirmationsScreen()),
  _NavEntry('AI Insights', Icons.auto_awesome_outlined, (_) => const AiInsightsScreen(), badge: 'NEW'),
  _NavEntry('Export Center', Icons.download_outlined, (_) => const ExportCenterScreen()),
  _NavEntry('Settings', Icons.settings_outlined, (_) => const SettingsScreen()),
];

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;
  bool _initialized = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<_NavEntry> _visibleEntries(AuthState auth) {
    return _navEntries
        .where((e) => !e.adminOnly || auth.isAdmin)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final visible = _visibleEntries(auth);

    // First build after login: admins land on Admin Home, contributors on Dashboard.
    if (!_initialized) {
      _initialized = true;
      _index = 0; // first visible entry is Admin Home for admins, Dashboard otherwise
    }
    if (_index >= visible.length) _index = 0;

    final isWide = MediaQuery.of(context).size.width >= 900;
    final entry = visible[_index];
    final body = Builder(builder: (ctx) => entry.builder(ctx));

    if (isWide) {
      return Scaffold(
        appBar: _buildAppBar(context, entry),
        body: Row(
          children: [
            _Sidebar(
              entries: visible,
              index: _index,
              onSelect: (i) => setState(() => _index = i),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    // Mobile: bottom nav with 4 primary destinations + More opens the full
    // sidebar in a drawer.
    final navTargets = _bottomNavTargets(visible);
    int bottomIndex = navTargets.indexWhere((t) => t.entryIndex == _index);
    if (bottomIndex < 0) bottomIndex = navTargets.length - 1; // More
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context, entry),
      drawer: Drawer(
        backgroundColor: MT.inkSoft,
        child: _Sidebar(
          entries: visible,
          index: _index,
          inDrawer: true,
          onSelect: (i) {
            setState(() => _index = i);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        height: 64,
        selectedIndex: bottomIndex,
        onDestinationSelected: (i) {
          final target = navTargets[i];
          if (target.opensDrawer) {
            _scaffoldKey.currentState?.openDrawer();
            return;
          }
          setState(() => _index = target.entryIndex);
        },
        destinations: [
          for (final t in navTargets)
            NavigationDestination(
              icon: Icon(t.icon),
              label: t.label,
            ),
        ],
      ),
    );
  }

  List<_BottomTarget> _bottomNavTargets(List<_NavEntry> visible) {
    // Pick the 4 most useful destinations for phone-class navigation, then
    // surface the remaining entries via "More" → drawer.
    final preferred = [
      'Dashboard',
      'Control Registry',
      'POA&M Tracker',
      'Readiness Checklist',
    ];
    final targets = <_BottomTarget>[];
    for (final label in preferred) {
      final i = visible.indexWhere((e) => e.label == label);
      if (i < 0) continue;
      final entry = visible[i];
      targets.add(_BottomTarget(
        entryIndex: i,
        icon: entry.icon,
        label: _shortLabel(entry.label),
      ));
    }
    targets.add(const _BottomTarget(
      entryIndex: -1,
      icon: Icons.menu_rounded,
      label: 'More',
      opensDrawer: true,
    ));
    return targets;
  }

  String _shortLabel(String label) {
    return switch (label) {
      'Control Registry' => 'Controls',
      'POA&M Tracker' => 'POA&Ms',
      'Readiness Checklist' => 'Readiness',
      _ => label,
    };
  }

  AppBar _buildAppBar(BuildContext context, _NavEntry entry) {
    final auth = context.watch<AuthState>();
    return AppBar(
      backgroundColor: MT.ink,
      foregroundColor: MT.textHigh,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: MT.goldGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.shield_outlined, color: MT.ink, size: 16),
            ),
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'cyberAutopsy',
              style: TextStyle(fontWeight: FontWeight.w700, color: MT.textHigh),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Center(
            child: Text(
              entry.label,
              style: const TextStyle(color: MT.textMid, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          tooltip: 'Account',
          icon: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                gradient: auth.isAdmin
                    ? MT.goldGradient
                    : const LinearGradient(
                        colors: [Color(0xFF60A5FA), Color(0xFF818CF8)]),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                auth.isAdmin ? Icons.workspace_premium : Icons.person,
                size: 14,
                color: MT.ink,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 18, color: Colors.white),
          ]),
          itemBuilder: (ctx) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.displayName ?? 'User',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.black)),
                  Text(auth.email ?? '',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'signout',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout, size: 18),
                title: Text('Sign out'),
                dense: true,
              ),
            ),
          ],
          onSelected: (v) {
            if (v == 'signout') {
              context.read<AuthState>().signOut();
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _BottomTarget {
  const _BottomTarget({
    required this.entryIndex,
    required this.icon,
    required this.label,
    this.opensDrawer = false,
  });
  final int entryIndex;
  final IconData icon;
  final String label;
  final bool opensDrawer;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.entries,
    required this.index,
    required this.onSelect,
    this.inDrawer = false,
  });

  final List<_NavEntry> entries;
  final int index;
  final ValueChanged<int> onSelect;
  final bool inDrawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: inDrawer ? null : 280,
      decoration: BoxDecoration(
        color: MT.inkSoft,
        border: inDrawer
            ? null
            : const Border(right: BorderSide(color: MT.stroke)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (var i = 0; i < entries.length; i++)
                    _SidebarItem(
                      entry: entries[i],
                      selected: i == index,
                      onTap: () => onSelect(i),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MT.surface,
                  border: Border.all(color: MT.goldBase.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.shield_outlined,
                          color: MT.goldLight, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'CMMC Level 2',
                        style: TextStyle(
                          color: MT.goldLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    const Text(
                      '120 practices across 14 control families',
                      style: TextStyle(fontSize: 12, color: MT.textMid),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Based on NIST SP 800-171',
                      style: TextStyle(fontSize: 11, color: MT.textLow),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final _NavEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected
            ? MT.goldBase.withOpacity(0.12)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: selected ? MT.goldBase.withOpacity(0.45) : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(entry.icon,
                    size: 20,
                    color: selected ? MT.goldLight : MT.textMid),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.label,
                    style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? MT.goldLight : MT.textHigh,
                    ),
                  ),
                ),
                if (entry.badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: MT.goldGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.badge!,
                      style: const TextStyle(
                        color: MT.ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
