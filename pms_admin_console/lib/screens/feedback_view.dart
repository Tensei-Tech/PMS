import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  String _selectedStatusFilter = 'All';
  String _searchQuery = '';
  final List<Map<String, dynamic>> _demoFeedbacks = [];

  void _addDemoFeedback() {
    final now = DateTime.now();
    final demoItems = [
      {
        'id': 'demo_fb_${now.millisecondsSinceEpoch}_1',
        'isDemo': true,
        'officerName': 'API Rahul Shinde',
        'designation': 'API',
        'stationName': 'Dhantoli Police Station',
        'sevaNumber': 'MH-NGP-3021',
        'category': 'App Feature',
        'rating': 5,
        'message': 'Voice speech-to-text Marathi transcription worked exceptionally well during field panchnama today. Great feature!',
        'status': 'New',
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(minutes: 15))),
      },
      {
        'id': 'demo_fb_${now.millisecondsSinceEpoch}_2',
        'isDemo': true,
        'officerName': 'PSI Sneha Deshmukh',
        'designation': 'PSI',
        'stationName': 'Sitabuldi Police Station',
        'sevaNumber': 'MH-NGP-1094',
        'category': 'Equipment Grievance',
        'rating': 3,
        'message': 'Barcode scanner in Malkhana needs a high-speed mode for batch inventory verification during court submission.',
        'status': 'In Review',
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
      },
      {
        'id': 'demo_fb_${now.millisecondsSinceEpoch}_3',
        'isDemo': true,
        'officerName': 'PI Vikram Gaikwad',
        'designation': 'PI',
        'stationName': 'Sadar Police Station',
        'sevaNumber': 'MH-NGP-2045',
        'category': 'Station Operations',
        'rating': 4,
        'message': 'Requesting automatic PDF export option with Marathi fonts embedded directly in case disposal records.',
        'status': 'Resolved',
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      },
    ];

    setState(() {
      _demoFeedbacks.insertAll(0, demoItems);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Added 3 Demo Officer Feedback & Grievance Tickets!'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _updateStatus(String docId, bool isDemo, String newStatus) {
    if (isDemo) {
      setState(() {
        for (var item in _demoFeedbacks) {
          if (item['id'] == docId) {
            item['status'] = newStatus;
          }
        }
      });
    } else {
      FirebaseFirestore.instance.collection('feedback').doc(docId).update({
        'status': newStatus,
        'resolvedAt': FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ticket marked as "$newStatus"'),
        backgroundColor: const Color(0xFF2563EB),
        duration: const Duration(seconds: 2),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Officer Feedback & Grievance Desk',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Review feedback, feature requests, and field operational suggestions from officers',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _addDemoFeedback,
                    icon: const Icon(Icons.add_comment_rounded, size: 16, color: Color(0xFF2563EB)),
                    label: const Text(
                      'Add Demo Feedback 💬',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB)),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      side: const BorderSide(color: Color(0xFFBFDBFE), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: const Color(0xFFEFF6FF),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search & Status Filters
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search by officer, station, or keywords...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Wrap(
                  spacing: 6,
                  children: ['All', 'New', 'In Review', 'Resolved'].map((status) {
                    final isSel = _selectedStatusFilter == status;
                    return ChoiceChip(
                      label: Text(status, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.w500, color: isSel ? Colors.white : const Color(0xFF475569))),
                      selected: isSel,
                      selectedColor: const Color(0xFF2563EB),
                      backgroundColor: const Color(0xFFF1F5F9),
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onSelected: (val) {
                        if (val) setState(() => _selectedStatusFilter = status);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Feedback Stream & List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
              builder: (context, snapshot) {
                final firestoreItems = snapshot.data?.docs.map((doc) {
                  final m = Map<String, dynamic>.from(doc.data() as Map);
                  m['id'] = doc.id;
                  m['isDemo'] = false;
                  return m;
                }).toList() ?? [];

                final allItems = [..._demoFeedbacks, ...firestoreItems];

                final filtered = allItems.where((item) {
                  final status = item['status'] ?? 'New';
                  final officer = (item['officerName'] ?? '').toString().toLowerCase();
                  final station = (item['stationName'] ?? '').toString().toLowerCase();
                  final msg = (item['message'] ?? '').toString().toLowerCase();
                  final cat = (item['category'] ?? '').toString().toLowerCase();

                  final matchesStatus = _selectedStatusFilter == 'All' || status == _selectedStatusFilter;
                  final matchesQuery = _searchQuery.isEmpty ||
                      officer.contains(_searchQuery) ||
                      station.contains(_searchQuery) ||
                      msg.contains(_searchQuery) ||
                      cat.contains(_searchQuery);

                  return matchesStatus && matchesQuery;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.rate_review_outlined, size: 40, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No feedback tickets found',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Click "Add Demo Feedback 💬" above to generate demo officer reviews',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final docId = item['id']?.toString() ?? 'fb_$index';
                    final isDemo = item['isDemo'] == true;
                    final officer = item['officerName'] ?? 'Officer';
                    final desig = item['designation'] ?? 'IO';
                    final station = item['stationName'] ?? 'Jurisdiction';
                    final seva = item['sevaNumber'] ?? '';
                    final cat = item['category'] ?? 'General';
                    final rating = item['rating'] is int ? item['rating'] as int : 5;
                    final message = item['message'] ?? 'No message provided.';
                    final status = item['status'] ?? 'New';
                    final ts = item['timestamp'];

                    String dateStr = 'Recently';
                    if (ts is Timestamp) {
                      final dt = ts.toDate();
                      dateStr = '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    }

                    Color statusColor = const Color(0xFFEF4444);
                    Color statusBg = const Color(0xFFFEF2F2);
                    if (status == 'In Review') {
                      statusColor = const Color(0xFFD97706);
                      statusBg = const Color(0xFFFFFBEB);
                    } else if (status == 'Resolved') {
                      statusColor = const Color(0xFF10B981);
                      statusBg = const Color(0xFFECFDF5);
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFFEFF6FF),
                                    child: Text(
                                      officer.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8), fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '$desig $officer',
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
                                          ),
                                          if (seva.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              '($seva)',
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$station • $dateStr',
                                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Category Capsule
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      cat,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Status Capsule
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Rating Stars
                          Row(
                            children: List.generate(5, (sIdx) {
                              return Icon(
                                sIdx < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 16,
                                color: const Color(0xFFF59E0B),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          // Message
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: Text(
                              message,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (status != 'In Review')
                                TextButton.icon(
                                  onPressed: () => _updateStatus(docId, isDemo, 'In Review'),
                                  icon: const Icon(Icons.pending_actions_rounded, size: 14, color: Color(0xFFD97706)),
                                  label: const Text('Mark In Review', style: TextStyle(fontSize: 11.5, color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
                                ),
                              const SizedBox(width: 8),
                              if (status != 'Resolved')
                                ElevatedButton.icon(
                                  onPressed: () => _updateStatus(docId, isDemo, 'Resolved'),
                                  icon: const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                                  label: const Text('Mark Resolved', style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
