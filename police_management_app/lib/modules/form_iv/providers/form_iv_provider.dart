// lib/modules/form_iv/providers/form_iv_provider.dart
import '../../core/providers/base_module_provider.dart';

/// Handles ALL Form I-V submissions (Murder, Attempt-to-Murder, Robbery, etc.)
/// Data is STRICTLY isolated — no record from this module can appear in any other.
class FormIVProvider extends BaseModuleProvider {
  FormIVProvider() : super('form_1_5');
}
