import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/stations_list_dialog.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Overview',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time system metrics and quick statistics',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
              Chip(
                avatar: const Icon(Icons.sensors, size: 16, color: Colors.green),
                label: const Text('Live Updates'),
                backgroundColor: Colors.green.shade50,
                side: BorderSide(color: Colors.green.shade200),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 140,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              children: [
                _StreamStatCard(
                  title: 'Total Active Officers',
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('accountStatus', isEqualTo: 'active')
                      .snapshots(),
                  icon: Icons.shield_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                _StreamStatCard(
                  title: 'Pending Approvals',
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('accountStatus', whereIn: ['pending_approval', 'pending'])
                      .snapshots(),
                  icon: Icons.pending_actions_outlined,
                  color: Colors.redAccent,
                  isAttentionNeeded: true,
                ),
                _StreamStatCard(
                  title: 'Total Stations',
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('accountStatus', isEqualTo: 'active')
                      .snapshots(),
                  countMapper: (snapshot) {
                    final Set<String> uniqueStations = {};
                    for (final doc in snapshot.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final stationName = (data['stationName'] ?? data['station'] ?? data['assignedStation'])?.toString().trim();
                      if (stationName != null && stationName.isNotEmpty) {
                        uniqueStations.add(stationName);
                      }
                    }
                    return uniqueStations.length;
                  },
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const StationsListDialog(),
                    );
                  },
                  icon: Icons.location_city_outlined,
                  color: Colors.teal,
                ),
                _StreamStatCard(
                  title: 'Total Active Cases',
                  stream: FirebaseFirestore.instance
                      .collection('cases')
                      .where('status', isEqualTo: 'open')
                      .snapshots(),
                  icon: Icons.folder_open_outlined,
                  color: Colors.indigo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamStatCard extends StatelessWidget {
  final String title;
  final Stream<QuerySnapshot> stream;
  final IconData icon;
  final Color color;
  final bool isAttentionNeeded;
  final int Function(QuerySnapshot snapshot)? countMapper;
  final VoidCallback? onTap;

  const _StreamStatCard({
    required this.title,
    required this.stream,
    required this.icon,
    required this.color,
    this.isAttentionNeeded = false,
    this.countMapper,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.hasData
            ? (countMapper != null
                ? countMapper!(snapshot.data!)
                : snapshot.data!.docs.length)
            : 0;
        final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;

        return _StatCard(
          title: title,
          count: count,
          icon: icon,
          color: color,
          isAttentionNeeded: isAttentionNeeded,
          isLoading: isLoading,
          onTap: onTap,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final bool isAttentionNeeded;
  final bool isLoading;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.isAttentionNeeded = false,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isAttentionNeeded
        ? Colors.red.shade50
        : theme.colorScheme.surfaceContainerLow;
    final borderColor = isAttentionNeeded
        ? Colors.red.shade300
        : theme.colorScheme.outlineVariant;

    return Card(
      elevation: isAttentionNeeded ? 3 : 1,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: isAttentionNeeded ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isAttentionNeeded ? Colors.red.shade900 : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isAttentionNeeded ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(
                            '$count',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isAttentionNeeded ? Colors.red.shade800 : color,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
