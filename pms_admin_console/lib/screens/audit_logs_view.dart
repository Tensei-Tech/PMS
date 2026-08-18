import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuditLogsView extends StatelessWidget {
  const AuditLogsView({super.key});

  String _formatTimestamp(dynamic ts) {
    if (ts is Timestamp) {
      final dt = ts.toDate();
      final y = dt.year;
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      final ss = dt.second.toString().padLeft(2, '0');
      return '$y-$m-$d $hh:$mm:$ss';
    }
    return 'Just now';
  }

  Widget _buildActionBadge(String action) {
    Color bg;
    Color fg;

    switch (action.toUpperCase()) {
      case 'APPROVED':
      case 'RESTORED':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case 'REJECTED':
      case 'ARCHIVED':
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        break;
      case 'EDITED':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade800;
        break;
    }

    return Chip(
      label: Text(
        action.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: fg,
          fontSize: 12,
        ),
      ),
      backgroundColor: bg,
      side: BorderSide(color: fg.withAlpha(80)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Admin Activity Log',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Chip(
                avatar: const Icon(Icons.security, size: 16, color: Colors.blueAccent),
                label: const Text('Audit Trail'),
                backgroundColor: Colors.blue.shade50,
                side: BorderSide(color: Colors.blue.shade200),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time stream of critical administrative actions, officer approvals, profile updates, and archive events',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('audit_logs')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading audit logs: ${snapshot.error}',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No audit logs recorded yet.',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Admin actions will automatically appear here as they occur.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            theme.colorScheme.surfaceContainerHigh,
                          ),
                          columns: const [
                            DataColumn(
                              label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Target User ID', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Admin ID', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                          rows: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final timestamp = _formatTimestamp(data['timestamp']);
                            final action = (data['action'] ?? 'UNKNOWN').toString();
                            final details = (data['details'] ?? '').toString();
                            final targetUserId = (data['targetUserId'] ?? 'N/A').toString();
                            final adminUid = (data['adminUid'] ?? 'super_admin').toString();

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    timestamp,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                DataCell(_buildActionBadge(action)),
                                DataCell(
                                  Text(
                                    details,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    targetUserId,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: theme.colorScheme.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    adminUid,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: theme.colorScheme.outline,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
