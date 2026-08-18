import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'announcements_view.dart';
import 'approvals_view.dart';
import 'audit_logs_view.dart';
import 'dashboard_view.dart';
import 'officers_directory_view.dart';
import 'settings_view.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardView();
      case 1:
        return const ApprovalsView();
      case 2:
        return const OfficersDirectoryView();
      case 3:
        return const AnnouncementsView();
      case 4:
        return const AuditLogsView();
      case 5:
        return const SettingsView();
      default:
        return Center(
          child: Text(
            'Welcome to Super Admin Console 🚀',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PMS Admin',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.fact_check_outlined),
                selectedIcon: Icon(Icons.fact_check),
                label: Text('Approvals'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.badge_outlined),
                selectedIcon: Icon(Icons.badge),
                label: Text('Officers Directory'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.campaign_outlined),
                selectedIcon: Icon(Icons.campaign),
                label: Text('App Carousel & News'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: Text('Audit Logs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                // Top Application Header with Notification Badge
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Police Management System — Admin Console',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('accountStatus', whereIn: ['pending_approval', 'pending'])
                                .snapshots(),
                            builder: (context, snapshot) {
                              final pendingCount = snapshot.data?.docs.length ?? 0;

                              return Badge(
                                isLabelVisible: pendingCount > 0,
                                label: Text('$pendingCount'),
                                backgroundColor: Colors.redAccent,
                                child: IconButton(
                                  icon: const Icon(Icons.notifications_outlined),
                                  tooltip: pendingCount > 0
                                      ? 'Pending Approvals ($pendingCount)'
                                      : 'No pending approvals',
                                  onPressed: () {
                                    setState(() {
                                      _selectedIndex = 1;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              'SA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Main Content Body
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: _buildMainContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
