// lib/screens/manage_announcements_screen.dart
// Master Admin management interface for Carousel News, Law Updates & Bulletins.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/news_provider.dart';
import '../theme/app_theme.dart';

class ManageAnnouncementsScreen extends StatefulWidget {
  const ManageAnnouncementsScreen({super.key});

  @override
  State<ManageAnnouncementsScreen> createState() =>
      _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState extends State<ManageAnnouncementsScreen> {
  static const List<String> _suggestedTags = [
    'New Law',
    'Circular',
    'Amendment',
    'Notice',
    'Alert',
    'Awareness',
    'SOP',
    'Important',
  ];

  static const List<({String name, IconData icon, String label})>
      _availableIcons = [
    (name: 'gavel', icon: Icons.gavel_rounded, label: 'Legal / Gavel'),
    (name: 'shield', icon: Icons.shield_rounded, label: 'Shield / Safety'),
    (name: 'videocam', icon: Icons.videocam_rounded, label: 'Body Camera'),
    (name: 'security', icon: Icons.security_rounded, label: 'Security / Cyber'),
    (name: 'campaign', icon: Icons.campaign_rounded, label: 'Announcement'),
    (name: 'warning', icon: Icons.warning_amber_rounded, label: 'Alert / Warning'),
    (name: 'policy', icon: Icons.policy_rounded, label: 'Policy / Rule'),
    (name: 'article', icon: Icons.article_rounded, label: 'Document / Order'),
    (name: 'local_police', icon: Icons.local_police_rounded, label: 'Police Badge'),
    (name: 'handshake', icon: Icons.handshake_rounded, label: 'Community / Public'),
  ];

  static const List<({String label, int hexColor})> _themeColors = [
    (label: 'Deep Navy', hexColor: 0xFF1A237E),
    (label: 'Teal Blue', hexColor: 0xFF00838F),
    (label: 'Vibrant Amber', hexColor: 0xFFE65100),
    (label: 'Forest Green', hexColor: 0xFF1B5E20),
    (label: 'Crimson Red', hexColor: 0xFFB71C1C),
    (label: 'Royal Purple', hexColor: 0xFF4A148C),
  ];

  void _openAnnouncementEditor({NewsItem? item}) {
    final isEditing = item != null;
    final titleCtrl = TextEditingController(text: item?.title ?? '');
    final descCtrl = TextEditingController(text: item?.description ?? '');
    String selectedTag = item?.tag ?? 'New Law';
    String selectedIconName = item?.iconName ?? 'gavel';
    int selectedColor = item?.iconColorHex ?? 0xFF1A237E;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final selectedIconData =
              NewsItem.iconFromName(selectedIconName);

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Announcement' : 'New Announcement',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Live Preview Banner
                  Text(
                    'Live Carousel Preview',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightSubText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(selectedColor),
                          Color(selectedColor).withValues(alpha: 0.82),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: Color(selectedColor).withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            selectedIconData,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  selectedTag,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                titleCtrl.text.trim().isEmpty
                                    ? 'Announcement Title Here'
                                    : titleCtrl.text.trim(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                descCtrl.text.trim().isEmpty
                                    ? 'Detailed circular description and law instructions will appear here...'
                                    : descCtrl.text.trim(),
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tag selection
                  Text(
                    'Category / Tag',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedTags.map((tag) {
                      final isSelected = tag == selectedTag;
                      return ChoiceChip(
                        label: Text(tag),
                        selected: isSelected,
                        selectedColor: AppColors.navyDark,
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.navyDark,
                        ),
                        backgroundColor: AppColors.lightBg,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedTag = tag);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Title input
                  Text(
                    'Title',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    onChanged: (_) => setModalState(() {}),
                    style: GoogleFonts.poppins(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'e.g. BNSS 2023 — New Criminal Procedure Code',
                      hintStyle: GoogleFonts.poppins(fontSize: 12),
                      filled: true,
                      fillColor: AppColors.lightBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.lightBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description input
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    onChanged: (_) => setModalState(() {}),
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText:
                          'Enter comprehensive update, instructions, or amendment details for field officers...',
                      hintStyle: GoogleFonts.poppins(fontSize: 12),
                      filled: true,
                      fillColor: AppColors.lightBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.lightBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Icon selector
                  Text(
                    'Icon Badge',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableIcons.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, idx) {
                        final entry = _availableIcons[idx];
                        final isSel = entry.name == selectedIconName;
                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () =>
                              setModalState(() => selectedIconName = entry.name),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppColors.navyDark
                                  : AppColors.lightBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSel
                                    ? AppColors.navyDark
                                    : AppColors.lightBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              entry.icon,
                              color: isSel ? Colors.white : AppColors.navyMid,
                              size: 22,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Color theme selector
                  Text(
                    'Color Theme',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _themeColors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, idx) {
                        final theme = _themeColors[idx];
                        final isSel = theme.hexColor == selectedColor;
                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () =>
                              setModalState(() => selectedColor = theme.hexColor),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(theme.hexColor),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                if (isSel)
                                  BoxShadow(
                                    color: Color(theme.hexColor)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: isSel
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload_rounded,
                              color: Colors.white),
                      label: Text(
                        isSaving
                            ? 'Saving...'
                            : (isEditing ? 'Update Announcement' : 'Publish Announcement'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        elevation: 2,
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              final title = titleCtrl.text.trim();
                              final desc = descCtrl.text.trim();
                              if (title.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter announcement title'),
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSaving = true);
                              final provider = context.read<NewsProvider>();

                              final newsObj = NewsItem(
                                id: item?.id ?? '',
                                title: title,
                                description: desc,
                                iconName: selectedIconName,
                                icon: selectedIconData,
                                iconColorHex: selectedColor,
                                tag: selectedTag,
                                order: item?.order ?? (provider.items.length + 1),
                              );

                              try {
                                if (isEditing) {
                                  await provider.updateAnnouncement(newsObj);
                                } else {
                                  await provider.addAnnouncement(newsObj);
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.successGreen,
                                      content: Text(
                                        isEditing
                                            ? 'Announcement updated live across all devices!'
                                            : 'New announcement published live!',
                                      ),
                                    ),
                                  );
                                }
                              } catch (err) {
                                setModalState(() => isSaving = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.dangerRed,
                                      content: Text('Error saving: $err'),
                                    ),
                                  );
                                }
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(NewsItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Delete Announcement?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${item.title}"? It will be removed immediately from all officers\' dashboard carousels.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<NewsProvider>().deleteAnnouncement(item.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.navyDark,
                      content: Text('Announcement removed live.'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.dangerRed,
                      content: Text('Error deleting: $e'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmResetDefaults() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Reset Default Announcements?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        content: Text(
          'This will overwrite all active carousel announcements with the standard standard legal bulletins (BNSS 2023, POCSO, Body Camera, Cyber Crime SOP).',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            child: Text(
              'Reset & Seed',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<NewsProvider>().seedDefaultsToFirestore();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.successGreen,
                      content: Text('Default announcements restored live!'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.dangerRed,
                      content: Text('Error resetting: $e'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();
    final items = newsProvider.items;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.navyDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Announcements',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (val) {
              if (val == 'reset') _confirmResetDefaults();
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    const Icon(Icons.restore_rounded,
                        size: 18, color: AppColors.navyMid),
                    const SizedBox(width: 8),
                    Text(
                      'Restore Defaults',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withValues(alpha: 0.12),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.goldPrimary.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_sync_rounded,
                    color: AppColors.goldDark, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Changes made here update immediately on all police officers\' app carousels in real time.',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.navyDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List of items
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.newspaper_rounded,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No active announcements',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightSubText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _confirmResetDefaults,
                          child: Text(
                            'Load Default Announcements',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyMid,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final item = items[idx];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: AppColors.lightBorder,
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.navyDark.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color(item.iconColorHex)
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      color: Color(item.iconColorHex),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Color(item.iconColorHex)
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.tag,
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(item.iconColorHex),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.title,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.navyDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.description,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.5,
                                            color: AppColors.lightSubText,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              color: AppColors.lightBg.withValues(alpha: 0.5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.edit_rounded,
                                        size: 15, color: AppColors.navyMid),
                                    label: Text(
                                      'Edit',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.navyMid,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _openAnnouncementEditor(item: item),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 15,
                                        color: AppColors.dangerRed),
                                    label: Text(
                                      'Delete',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.dangerRed,
                                      ),
                                    ),
                                    onPressed: () => _confirmDelete(item),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.navyDark,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Announcement',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        onPressed: () => _openAnnouncementEditor(),
      ),
    );
  }
}
