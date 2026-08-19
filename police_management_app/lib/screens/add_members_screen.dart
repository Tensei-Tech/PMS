// lib/screens/add_members_screen.dart
// Assign floating (unassigned) officers to a station — PI/API or SP/CP.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/maharashtra_police_stations_repository.dart';
import '../data/police_stations_repository.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../widgets/searchable_picker_field.dart';

/// Unified assign-officer screen (drawer: "Assign Officer" / legacy Add Members route).
class AssignOfficerScreen extends StatefulWidget {
  const AssignOfficerScreen({super.key});

  @override
  State<AssignOfficerScreen> createState() => _AssignOfficerScreenState();
}

/// Back-compat alias for existing routes.
typedef AddMembersScreen = AssignOfficerScreen;

class _AssignOfficerScreenState extends State<AssignOfficerScreen> {
  final _searchCtrl = TextEditingController();
  final _firestore = FirestoreService();
  UserModel? _result;
  bool _searching = false;
  bool _assigning = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    MaharashtraPoliceStationsRepository.initialize();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isSenior(AuthProvider auth) =>
      SeniorOfficerRoles.canSwitchLocation(auth.designation);

  bool _isPi(AuthProvider auth) =>
      TransferRequestRoles.isPiOrApi(auth.designation);

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      _snack('Enter a mobile number or email to search.', AppColors.warningOrange);
      return;
    }

    setState(() {
      _searching = true;
      _searchError = null;
      _result = null;
    });

    final user = await _firestore.findFloatingUserByEmailOrPhone(query);
    if (!mounted) return;

    setState(() {
      _searching = false;
      if (user == null) {
        _searchError =
            'No unassigned officer found with that exact mobile or email.';
      } else {
        _result = user;
      }
    });
  }

  Future<void> _assignPiInstant(UserModel user, AuthProvider auth) async {
    if (auth.homeStationName.trim().isEmpty) {
      _snack('Your station is not set. Contact admin before assigning members.',
          AppColors.warningOrange);
      return;
    }

    setState(() => _assigning = true);
    try {
      await _firestore.assignFloatingUserToStation(
        uid: user.uid,
        stationName: auth.homeStationName,
        district: auth.district,
        stationAddress: auth.stationAddress,
      );
      if (!mounted) return;
      _snack(
        '${user.name} assigned to ${auth.homeStationName}.',
        AppColors.successGreen,
      );
      setState(() {
        _result = null;
        _searchCtrl.clear();
      });
    } catch (e) {
      if (!mounted) return;
      _snack(
        'Assignment failed. Check permissions or try again.',
        AppColors.dangerRed,
      );
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  Future<void> _showSeniorAssignSheet(UserModel user) async {
    String? unitType;
    String? district;
    String? station;
    const state = 'Maharashtra';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            List<String> districts = [];
            if (unitType != null) {
              if (state == 'Maharashtra') {
                final d = <String>{};
                for (final s
                    in MaharashtraPoliceStationsRepository.getAllStations()) {
                  if (s.type == unitType) d.add(s.districtName);
                }
                districts = d.toList()
                  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
              }
            }

            List<String> stations = [];
            if (unitType != null && district != null) {
              if (state == 'Maharashtra') {
                stations =
                    MaharashtraPoliceStationsRepository.getStationNamesForSelection(
                  district: district!,
                  unitType: unitType!,
                );
              } else {
                stations = PoliceStationsRepository.forSelection(
                  unitType: unitType!,
                  state: state,
                  district: district!,
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Assign station',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.lightSubText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: unitType,
                      decoration: InputDecoration(
                        labelText: 'Police unit type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: PoliceStationsRepository.commissionerate,
                          child: Text('Commissionerate Police'),
                        ),
                        DropdownMenuItem(
                          value: PoliceStationsRepository.superintendent,
                          child: Text('Superintendent of Police (Rural)'),
                        ),
                      ],
                      onChanged: (v) => setSheetState(() {
                        unitType = v;
                        district = null;
                        station = null;
                      }),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (unitType != null)
                      SearchablePickerField(
                        label: 'District',
                        hintText: 'Select district',
                        leadingIcon: Icons.map_rounded,
                        value: district,
                        items: districts,
                        onChanged: (v) => setSheetState(() {
                          district = v;
                          station = null;
                        }),
                      ),
                    if (district != null && stations.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SearchablePickerField(
                        label: 'Police station',
                        hintText: 'Select station',
                        leadingIcon: Icons.local_police_rounded,
                        value: station,
                        items: stations,
                        onChanged: (v) => setSheetState(() => station = v),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _assigning ||
                                unitType == null ||
                                district == null ||
                                station == null
                            ? null
                            : () async {
                                Navigator.pop(ctx);
                                setState(() => _assigning = true);
                                try {
                                  await _firestore.assignFloatingUserToStation(
                                    uid: user.uid,
                                    stationName: station!,
                                    district: district!,
                                    stationAddress:
                                        '$district, $state • $unitType',
                                  );
                                  if (!mounted) return;
                                  _snack(
                                    '${user.name} assigned to $station.',
                                    AppColors.successGreen,
                                  );
                                  setState(() {
                                    _result = null;
                                    _searchCtrl.clear();
                                  });
                                } catch (e) {
                                  if (!mounted) return;
                                  _snack(
                                    'Assignment failed. Check permissions.',
                                    AppColors.dangerRed,
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _assigning = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyMid,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Confirm assignment',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onAssign(UserModel user, AuthProvider auth) async {
    if (_isPi(auth) && !_isSenior(auth)) {
      await _assignPiInstant(user, auth);
    } else if (_isSenior(auth)) {
      await _showSeniorAssignSheet(user);
    } else {
      _snack('You do not have permission to assign officers.', AppColors.dangerRed);
    }
  }

  String _selectedRankFilter = 'All';

  static final List<UserModel> _dummyAvailableOfficers = [
    UserModel(
      uid: 'dummy_user_1',
      name: 'API Rohit Deshmukh',
      email: 'rohit.deshmukh@mahapolice.gov.in',
      phone: '9822014589',
      designation: 'API',
      badgeNumber: 'MH-7821',
      stationName: '',
      stationAddress: 'Awaiting Station Posting',
      stationLandline: '0712-2560100',
      govtId: 'MH-POL-7821',
      accountStatus: 'active',
      role: 'officer',
    ),
    UserModel(
      uid: 'dummy_user_2',
      name: 'PSI Vikram Patil',
      email: 'vikram.patil@mahapolice.gov.in',
      phone: '9822031145',
      designation: 'PSI',
      badgeNumber: 'MH-4412',
      stationName: '',
      stationAddress: 'Awaiting Station Posting',
      stationLandline: '0712-2560101',
      govtId: 'MH-POL-4412',
      accountStatus: 'active',
      role: 'officer',
    ),
    UserModel(
      uid: 'dummy_user_3',
      name: 'ASI Anjali Kulkarni',
      email: 'anjali.kulkarni@mahapolice.gov.in',
      phone: '9822098451',
      designation: 'ASI',
      badgeNumber: 'MH-3382',
      stationName: '',
      stationAddress: 'Awaiting Station Posting',
      stationLandline: '0712-2560102',
      govtId: 'MH-POL-3382',
      accountStatus: 'active',
      role: 'officer',
    ),
    UserModel(
      uid: 'dummy_user_4',
      name: 'HC Sanjay Shinde',
      email: 'sanjay.shinde@mahapolice.gov.in',
      phone: '9822077612',
      designation: 'HC',
      badgeNumber: 'MH-9021',
      stationName: '',
      stationAddress: 'Awaiting Station Posting',
      stationLandline: '0712-2560103',
      govtId: 'MH-POL-9021',
      accountStatus: 'active',
      role: 'officer',
    ),
    UserModel(
      uid: 'dummy_user_5',
      name: 'PC Mahesh Pawar',
      email: 'mahesh.pawar@mahapolice.gov.in',
      phone: '9822045633',
      designation: 'PC',
      badgeNumber: 'MH-1109',
      stationName: '',
      stationAddress: 'Awaiting Station Posting',
      stationLandline: '0712-2560104',
      govtId: 'MH-POL-1109',
      accountStatus: 'active',
      role: 'officer',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canAssign = TransferRequestRoles.canAssignOfficers(auth.designation);

    final filteredList = _dummyAvailableOfficers.where((u) {
      if (_selectedRankFilter == 'All') return true;
      if (_selectedRankFilter == 'Officers (API/PSI)') {
        return u.designation == 'API' || u.designation == 'PSI';
      }
      if (_selectedRankFilter == 'Constabulary') {
        return u.designation == 'ASI' ||
            u.designation == 'HC' ||
            u.designation == 'PC';
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Assign Officer',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !canAssign
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Only PI/API or senior officers (SP/CP) can assign unassigned officers.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: AppColors.lightText),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Search for an unassigned officer by exact mobile number or email.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.lightSubText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _searchCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Mobile (10 digits) or email',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.arrow_forward_rounded),
                              onPressed: _searching ? null : _search,
                            ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                  if (_searchError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _searchError!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.warningOrange,
                      ),
                    ),
                  ],
                  if (_result != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _UserResultCard(
                      user: _result!,
                      assigning: _assigning,
                      onAssign: () => _onAssign(_result!, auth),
                    ),
                  ] else ...[
                    const SizedBox(height: 24),
                    // ── Header for Unassigned Roster ───────────────────────
                    Row(
                      children: [
                        const Icon(Icons.badge_rounded,
                            size: 20, color: AppColors.navyDark),
                        const SizedBox(width: 8),
                        Text(
                          'Available Officers for Posting',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyDark,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.successGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${filteredList.length} Available',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Rank Filter Chips ──────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'All',
                          'Officers (API/PSI)',
                          'Constabulary',
                        ].map((filter) {
                          final isSelected = _selectedRankFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                filter,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.navyDark,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.navyMid,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.navyMid
                                    : AppColors.lightBorder,
                              ),
                              onSelected: (_) {
                                setState(() => _selectedRankFilter = filter);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Available Officers List ────────────────────────────
                    ...filteredList.map((officer) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _UserResultCard(
                          user: officer,
                          assigning: _assigning,
                          onAssign: () => _onAssign(officer, auth),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }
}

class _UserResultCard extends StatelessWidget {
  const _UserResultCard({
    required this.user,
    required this.assigning,
    required this.onAssign,
  });

  final UserModel user;
  final bool assigning;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final photo = user.photoUrl.trim();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.navyMid.withValues(alpha: 0.12),
            backgroundImage:
                photo.isNotEmpty ? NetworkImage(photo) : null,
            child: photo.isEmpty
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyMid,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.navyDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.designation,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.navyMid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Station: Unassigned',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.lightSubText,
                  ),
                ),
                Text(
                  user.phone.isNotEmpty ? user.phone : user.email,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.lightSubText,
                  ),
                ),
              ],
            ),
          ),
          assigning
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : FilledButton(
                  onPressed: onAssign,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navyMid,
                  ),
                  child: Text(
                    'Assign Station',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
        ],
      ),
    );
  }
}
