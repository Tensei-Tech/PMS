import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/station_dashboard_view.dart';

class StationsListDialog extends StatefulWidget {
  const StationsListDialog({super.key});

  @override
  State<StationsListDialog> createState() => _StationsListDialogState();
}

class _StationsListDialogState extends State<StationsListDialog> {
  Key _streamKey = UniqueKey();

  void _retry() {
    setState(() {
      _streamKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.location_city_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          const Text('Registered Police Stations'),
        ],
      ),
      content: SizedBox(
        width: 480,
        height: 400,
        child: StreamBuilder<QuerySnapshot>(
          key: _streamKey,
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('accountStatus', isEqualTo: 'active')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              final error = snapshot.error;
              debugPrint('[StationsListDialog] StreamBuilder error: $error');

              final isPermissionDenied = error.toString().toLowerCase().contains('permission') ||
                  (error is FirebaseException && error.code == 'permission-denied');

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPermissionDenied ? Icons.lock_person_outlined : Icons.error_outline,
                        size: 56,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isPermissionDenied
                            ? 'Access Denied (Insufficient Permissions)'
                            : 'Unable to Load Stations',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPermissionDenied
                            ? 'Your Super Admin account lacks Firestore read permissions for the users collection. Please set custom claim { role: "super_admin" } or update firestore.rules.'
                            : 'An unexpected error occurred: ${error.toString()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            final Map<String, int> stationCounts = {};

            for (final doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final stationName = (data['stationName'] ?? data['station'] ?? data['assignedStation'])?.toString().trim();
              if (stationName != null && stationName.isNotEmpty) {
                stationCounts[stationName] = (stationCounts[stationName] ?? 0) + 1;
              }
            }

            if (stationCounts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No active stations found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            final sortedStations = stationCounts.keys.toList()..sort();

            return ListView.separated(
              itemCount: sortedStations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final station = sortedStations[index];
                final count = stationCounts[station]!;

                return ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StationDashboardView(stationName: station),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.local_police_outlined,
                      size: 20,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    station,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(
                          '$count Officer${count == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.outline,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
