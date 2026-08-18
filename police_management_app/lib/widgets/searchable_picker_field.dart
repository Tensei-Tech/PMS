import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// A lightweight, dependency-free searchable picker for long lists.
///
/// - Shows as a read-only form field
/// - On tap opens a bottom-sheet with a search box + list
class SearchablePickerField extends StatelessWidget {
  const SearchablePickerField({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.validator,
    this.leadingIcon,
  });

  final String label;
  final String hintText;
  final List<String> items;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? Function(String?)? validator;
  final IconData? leadingIcon;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchSheet(
        title: label,
        items: items,
        initial: value,
      ),
    );
    if (selected != null && selected.isNotEmpty) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: enabled ? () => _openPicker(context) : null,
        child: AbsorbPointer(
          child: TextFormField(
            key: ValueKey('$label-${value ?? ''}'),
            readOnly: true,
            enabled: enabled,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              prefixIcon: leadingIcon == null ? null : Icon(leadingIcon),
              suffixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: enabled ? const Color(0xFFF8FAFF) : const Color(0xFFF1F3F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            initialValue: value ?? '', // FIXED
          ),
        ),
      ),
    );
  }
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({
    required this.title,
    required this.items,
    required this.initial,
  });

  final String title;
  final List<String> items;
  final String? initial;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _searchCtrl = TextEditingController();
  final _searchFocusNode = FocusNode(); // FIXED
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    WidgetsBinding.instance.addPostFrameCallback((_) { // FIXED
      if (mounted) _searchFocusNode.requestFocus(); // FIXED
    }); // FIXED
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.trim().toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? widget.items
            : widget.items
                .where((e) => e.toLowerCase().contains(q))
                .toList(growable: false);
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose(); // FIXED
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
        height: h * 0.82,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocusNode, // FIXED
                autofocus: false, // FIXED
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _filtered[index];
                  final isSelected = item == widget.initial;
                  return ListTile(
                    title: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen)
                        : null,
                    onTap: () => Navigator.pop(context, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

