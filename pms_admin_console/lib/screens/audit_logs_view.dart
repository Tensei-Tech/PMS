import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuditLogsView extends StatefulWidget {
  const AuditLogsView({super.key});

  @override
  State<AuditLogsView> createState() => _AuditLogsViewState();
}

class _AuditLogsViewState extends State<AuditLogsView> {
  String _searchQuery = '';
  String _selectedActionFilter = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    Color border;

    final upper = action.toUpperCase();
    if (upper.contains('2FA') || upper.contains('APPROVED') || upper.contains('RESTORED') || upper.contains('SUCCESS')) {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF059669);
      border = const Color(0xFFA7F3D0);
    } else if (upper.contains('REJECTED') || upper.contains('ARCHIVED') || upper.contains('FAILED') || upper.contains('ERROR')) {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFDC2626);
      border = const Color(0xFFFECACA);
    } else if (upper.contains('EDITED') || upper.contains('UPDATE') || upper.contains('AUTH')) {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF1D4ED8);
      border = const Color(0xFFBFDBFE);
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF475569);
      border = const Color(0xFFCBD5E1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        upper,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Admin Activity Log',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 14, color: Color(0xFF1D4ED8)),
                        SizedBox(width: 5),
                        Text(
                          'Audit Trail',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Real-time immutable stream of administrative actions, officer approvals, and security events',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),

          const SizedBox(height: 18),

          // Search & Filter Controls
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 650;

                  final searchField = TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by action, details, user ID...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  );

                  final filterChips = SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['ALL', '2FA', 'AUTH', 'APPROVED', 'REJECTED'].map((filter) {
                        final isSelected = _selectedActionFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(filter),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFFEFF6FF),
                            backgroundColor: const Color(0xFFF8FAFC),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedActionFilter = filter);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: searchField),
                        const SizedBox(width: 14),
                        filterChips,
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        searchField,
                        const SizedBox(height: 10),
                        filterChips,
                      ],
                    );
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Main Responsive Content Area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('audit_logs')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading audit logs: ${snapshot.error}',
                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                    ),
                  );
                }

                final allDocs = snapshot.data?.docs ?? [];

                // Filter logs
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final action = (data['action'] ?? '').toString().toUpperCase();
                  final details = (data['details'] ?? '').toString().toLowerCase();
                  final targetUserId = (data['targetUserId'] ?? '').toString().toLowerCase();
                  final adminUid = (data['adminUid'] ?? '').toString().toLowerCase();

                  if (_selectedActionFilter != 'ALL') {
                    if (!action.contains(_selectedActionFilter)) return false;
                  }

                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    if (!action.toLowerCase().contains(query) &&
                        !details.contains(query) &&
                        !targetUserId.contains(query) &&
                        !adminUid.contains(query)) {
                      return false;
                    }
                  }
                  return true;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(48.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.history_toggle_off_rounded, size: 36, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No audit logs match your search',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try clearing filters or checking back later as new admin actions occur.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 960;

                    if (isDesktop) {
                      return _buildDesktopTable(filteredDocs);
                    } else {
                      return _buildMobileCardList(filteredDocs);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🖥️ Desktop Full-Width Data Table
  Widget _buildDesktopTable(List<QueryDocumentSnapshot> docs) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 900),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                dataRowMinHeight: 52,
                dataRowMaxHeight: 64,
                columns: const [
                  DataColumn(
                    label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF334155))),
                  ),
                  DataColumn(
                    label: Text('Action', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF334155))),
                  ),
                  DataColumn(
                    label: Text('Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF334155))),
                  ),
                  DataColumn(
                    label: Text('Target User ID', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF334155))),
                  ),
                  DataColumn(
                    label: Text('Admin ID', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF334155))),
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
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                      ),
                      DataCell(_buildActionBadge(action)),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Text(
                            details,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            targetUserId,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Color(0xFF1D4ED8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          adminUid,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Color(0xFF64748B),
                            fontSize: 11.5,
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
      ),
    );
  }

  // 📱 Tablet & Mobile Responsive Card List
  Widget _buildMobileCardList(List<QueryDocumentSnapshot> docs) {
    return ListView.separated(
      itemCount: docs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final timestamp = _formatTimestamp(data['timestamp']);
        final action = (data['action'] ?? 'UNKNOWN').toString();
        final details = (data['details'] ?? '').toString();
        final targetUserId = (data['targetUserId'] ?? 'N/A').toString();
        final adminUid = (data['adminUid'] ?? 'super_admin').toString();

        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Action Badge + Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionBadge(action),
                    Text(
                      timestamp,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  details,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Footer row: Target User & Admin
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Target: ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            targetUserId,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF1D4ED8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'By: $adminUid',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
