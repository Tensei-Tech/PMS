// lib/utils/common_form_module.dart
// Routing + storage key for the shared crime registration form (CommonForm).

/// Firestore / [ModuleRecord.extraFields] key for the full common form payload.
const String kCommonFormExtraFieldsKey = 'commonForm';

const Set<String> _kModulesWithoutCommonForm = {
  'pending',
  'monthly',
  'disposal',
  'detected',
  'undetected',
  'ad',
  'nc',
  'missing',
};

/// Dashboard / hub modules that use [CommonForm] instead of [ModuleFormScreen].
bool moduleUsesCommonCrimeForm(String moduleKey) =>
    !_kModulesWithoutCommonForm.contains(moduleKey);
