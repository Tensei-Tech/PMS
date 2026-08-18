/// Filters compound form sub-sections by [activeSection].
///
/// When [activeSection] is empty, all sections are shown.
/// When it does not match any [knownSectionIds] (e.g. BNSS parent label
/// "Crime Detail Form" instead of "Form 2-A"), falls back to showing all
/// sections instead of a blank screen.
bool showsFormSection({
  required String? activeSection,
  required String sectionId,
  required Set<String> knownSectionIds,
}) {
  final active = activeSection?.trim() ?? '';
  if (active.isEmpty) return true;
  if (!knownSectionIds.contains(active)) return true;
  return active == sectionId;
}

/// True when no specific sub-section is selected, or the active value is
/// not a known section ID (whole-form / BNSS shortcut entry).
bool showsAllFormSections({
  required String? activeSection,
  required Set<String> knownSectionIds,
}) {
  final active = activeSection?.trim() ?? '';
  if (active.isEmpty) return true;
  return !knownSectionIds.contains(active);
}
