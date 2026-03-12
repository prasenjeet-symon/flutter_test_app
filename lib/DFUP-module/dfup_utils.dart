// lib/dfup_utils.dart

import 'dfup_models.dart';

class DfupValidator {
  static String? validateText(DataPoint dp, String value) { final v = dp.validation; if (v == null) return null; if (v.isRequired && value.trim().isEmpty) return v.errorMessage ?? '${dp.label} is required'; if (value.isNotEmpty) { if (v.minLength != null && value.length < v.minLength!) return v.errorMessage ?? 'Minimum ${v.minLength} characters'; if (v.maxLength != null && value.length > v.maxLength!) return v.errorMessage ?? 'Maximum ${v.maxLength} characters'; if (v.regexPattern != null && !RegExp(v.regexPattern!).hasMatch(value)) return v.errorMessage ?? 'Invalid format'; } if (dp.type == DataPointType.email && value.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) return v.errorMessage ?? 'Enter a valid email'; if (dp.type == DataPointType.phone && value.isNotEmpty && !RegExp(r'^[\+]?[\d\s\-\(\)]{7,20}$').hasMatch(value)) return v.errorMessage ?? 'Enter a valid phone number'; return null; }
  static String? validateNumber(DataPoint dp, double? value) { final v = dp.validation; if (v == null) return null; if (v.isRequired && value == null) return v.errorMessage ?? '${dp.label} is required'; if (value != null) { if (v.minValue != null && value < v.minValue!) return v.errorMessage ?? 'Min ${v.minValue}'; if (v.maxValue != null && value > v.maxValue!) return v.errorMessage ?? 'Max ${v.maxValue}'; } return null; }
  static String? validateSelection(DataPoint dp, List<String> ids) { final v = dp.validation; if (v == null) return null; if (v.isRequired && ids.isEmpty) return v.errorMessage ?? 'Please make a selection'; return null; }
  static String? validateBoolean(DataPoint dp, bool? value) { final v = dp.validation; if (v == null) return null; if (v.isRequired && (value == null || !value)) return v.errorMessage ?? '${dp.label} is required'; return null; }
  static String? validateDate(DataPoint dp, String? value) { final v = dp.validation; if (v == null) return null; if (v.isRequired && (value == null || value.isEmpty)) return v.errorMessage ?? '${dp.label} is required'; return null; }
  static String? validateFile(DataPoint dp, List<FileMetadata> files) { final v = dp.fileValidation; if (v == null) return null; if (v.isRequired && files.isEmpty) return v.errorMessage ?? 'Please upload a file'; if (v.minFiles != null && files.length < v.minFiles!) return v.errorMessage ?? 'At least ${v.minFiles} file(s) required'; if (v.maxFiles != null && files.length > v.maxFiles!) return v.errorMessage ?? 'Maximum ${v.maxFiles} file(s) allowed'; for (final f in files) { if (v.maxSizeMb != null && f.fileSizeBytes > v.maxSizeMb! * 1024 * 1024) return v.errorMessage ?? 'File exceeds ${v.maxSizeMb}MB'; if (v.allowedExtensions != null && v.allowedExtensions!.isNotEmpty) { final ext = f.fileName.split('.').last.toLowerCase(); if (!v.allowedExtensions!.contains(ext)) return v.errorMessage ?? 'Allowed: ${v.allowedExtensions!.join(", ")}'; } } return null; }
}

class DependencyEvaluator {
  static bool isVisible(DataPoint dp, Map<String, DataPoint> registry) { if (dp.dependency == null) return true; return _evalConfig(dp.dependency!, registry); }
  static bool isOptionVisible(SelectionDataPointOption opt, Map<String, DataPoint> registry) { if (opt.dependency == null) return true; return _evalConfig(opt.dependency!, registry); }
  static bool _evalConfig(DependencyConfig config, Map<String, DataPoint> registry) {
    if (config.conditions.isEmpty) return true;
    if (config.mode == 'OR') return config.conditions.any((c) => _evalDep(c, registry));
    return config.conditions.every((c) => _evalDep(c, registry));
  }
  static bool _evalDep(DependencySchema dep, Map<String, DataPoint> registry) { final target = registry[dep.targetId]; if (target == null) return true; dynamic actual = target.responseValue; if (target.response is SelectionResponse) { final sr = target.response as SelectionResponse; actual = sr.selectedIds; } return _eval(actual, dep.operator, dep.comparisonValue); }
  static bool _eval(dynamic actual, String op, dynamic expected) {
    // Empty-string sentinel: op='!=' means "has any value", op='=' means "is empty/unset".
    // Used by selection fields with comparison_value: "" to test whether anything is selected.
    if ((op == '=' || op == '!=') && expected != null && expected.toString().isEmpty) {
      final hasValue = actual != null && (actual is! List || actual.isNotEmpty);
      return op == '=' ? !hasValue : hasValue;
    }
    if (actual == null) return op == '!=' ? (expected != null) : false;
    if (op == 'IN') {
      if (expected is List) {
        if (actual is List) return actual.any((a) => expected.map((e) => e.toString()).contains(a.toString()));
        return expected.map((e) => e.toString()).contains(actual.toString());
      }
      return actual.toString() == expected.toString();
    }
    if (op == 'ALL') {
      if (expected is List && actual is List) {
        final aSet = actual.map((e) => e.toString()).toSet();
        return expected.every((e) => aSet.contains(e.toString()));
      }
      if (expected is List) return expected.length == 1 && actual.toString() == expected.first.toString();
      return actual.toString() == expected.toString();
    }
    if ((op == '=' || op == '!=') && actual is List) { final match = actual.map((e) => e.toString()).contains(expected.toString()); return op == '=' ? match : !match; }
    final nA = _num(actual), nE = _num(expected); if (nA != null && nE != null) { switch (op) { case '=': return nA == nE; case '!=': return nA != nE; case '>': return nA > nE; case '<': return nA < nE; case '>=': return nA >= nE; case '<=': return nA <= nE; } } if (actual is bool || expected is bool) { final bA = _bool(actual), bE = _bool(expected); return op == '=' ? bA == bE : bA != bE; } return op == '=' ? actual.toString() == expected.toString() : (op == '!=' ? actual.toString() != expected.toString() : false); }
  static num? _num(dynamic v) => v is num ? v : (v is String ? num.tryParse(v) : null);
  static bool _bool(dynamic v) => v is bool ? v : (v is String ? v.toLowerCase() == 'true' : false);
}

class DynamicResolver {
  static final _tokenRe = RegExp(r'\{\{([^}]+)\}\}');
  static Map<String, DataPoint> buildRegistry(Layout layout) { final m = <String, DataPoint>{}; for (final dp in layout.collectAllDataPoints()) { m[dp.id] = dp; m[dp.code] = dp; } return m; }
  static String resolve(String? raw, Map<String, DataPoint> registry) { if (raw == null || raw.isEmpty || !raw.contains('{{')) return raw ?? ''; return raw.replaceAllMapped(_tokenRe, (m) { final key = m.group(1)!.trim(); final dp = registry[key]; return dp?.responseValue?.toString() ?? ''; }); }
}
