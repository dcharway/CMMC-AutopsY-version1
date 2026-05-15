import 'package:flutter/material.dart';

import 'screens/affirmations_screen.dart';
import 'screens/ai_insights_screen.dart';
import 'screens/assessment_workflow_screen.dart';
import 'screens/control_registry_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/evidence_repository_screen.dart';
import 'screens/export_center_screen.dart';
import 'screens/poam_tracker_screen.dart';
import 'screens/settings_screen.dart';

class CmmcAutopsyApp extends StatelessWidget {
  const CmmcAutopsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CMMC Autopsy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        scaffoldBackgroundColor: Colors.white,
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: const _Shell(),
    );
  }
}

class _NavEntry {
  const _NavEntry(this.label, this.icon, this.builder, {this.badge});
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
  final String? badge;
}

final _navEntries = <_NavEntry>[
  _NavEntry('Dashboard', Icons.dashboard_outlined, (_) => const DashboardScreen()),
  _NavEntry('Control Registry', Icons.fact_check_outlined, (_) => const ControlRegistryScreen()),
  _NavEntry('POA&M Tracker', Icons.warning_amber_outlined, (_) => const PoamTrackerScreen()),
  _NavEntry('Evidence Repository', Icons.folder_open_outlined, (_) => const EvidenceRepositoryScreen()),
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final entry = _navEntries[_index];

    final body = Builder(builder: (ctx) => entry.builder(ctx));

    if (isWide) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: Row(
          children: [
            _Sidebar(
              index: _index,
              onSelect: (i) => setState(() => _index = i),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: Drawer(
        child: _Sidebar(
          index: _index,
          inDrawer: true,
          onSelect: (i) {
            setState(() => _index = i);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: body,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF030213),
      foregroundColor: Colors.white,
      title: Row(
        children: const [
          Icon(Icons.shield_outlined, color: Colors.white),
          SizedBox(width: 12),
          Text('CMMC Autopsy', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              _navEntries[_index].label,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.index,
    required this.onSelect,
    this.inDrawer = false,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final bool inDrawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: inDrawer
            ? null
            : const Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            for (var i = 0; i < _navEntries.length; i++)
              _SidebarItem(
                entry: _navEntries[i],
                selected: i == index,
                onTap: () => onSelect(i),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'CMMC Level 2',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '110 practices across 14 control families',
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Based on NIST SP 800-171',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
        color: selected ? const Color(0xFFEEF2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(entry.icon,
                    size: 20,
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF6B7280)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.label,
                    style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF1F2937),
                    ),
                  ),
                ),
                if (entry.badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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
