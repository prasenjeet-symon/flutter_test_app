// lib/dfup_models.dart

import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum LayoutType { verticalStep, horizontalStep, scroll, tab }
LayoutType layoutTypeFromString(String s) { switch (s) { case 'vertical_step': return LayoutType.verticalStep; case 'horizontal_step': return LayoutType.horizontalStep; case 'scroll': return LayoutType.scroll; case 'tab': return LayoutType.tab; default: return LayoutType.scroll; } }
String layoutTypeToString(LayoutType t) { switch (t) { case LayoutType.verticalStep: return 'vertical_step'; case LayoutType.horizontalStep: return 'horizontal_step'; case LayoutType.scroll: return 'scroll'; case LayoutType.tab: return 'tab'; } }

enum DataPointType { text, email, password, phone, multiline, number, slider, rating, switchType, checkbox, booleanType, date, time, datetime, fileUpload, singleSelect, multiSelect }
DataPointType dataPointTypeFromString(String s) { switch (s) { case 'text': return DataPointType.text; case 'email': return DataPointType.email; case 'password': return DataPointType.password; case 'phone': return DataPointType.phone; case 'multiline': return DataPointType.multiline; case 'number': return DataPointType.number; case 'slider': return DataPointType.slider; case 'rating': return DataPointType.rating; case 'switch': return DataPointType.switchType; case 'checkbox': return DataPointType.checkbox; case 'boolean': return DataPointType.booleanType; case 'date': return DataPointType.date; case 'time': return DataPointType.time; case 'datetime': return DataPointType.datetime; case 'file_upload': return DataPointType.fileUpload; case 'single_select': return DataPointType.singleSelect; case 'multi_select': return DataPointType.multiSelect; default: return DataPointType.text; } }
String dataPointTypeToString(DataPointType t) { switch (t) { case DataPointType.text: return 'text'; case DataPointType.email: return 'email'; case DataPointType.password: return 'password'; case DataPointType.phone: return 'phone'; case DataPointType.multiline: return 'multiline'; case DataPointType.number: return 'number'; case DataPointType.slider: return 'slider'; case DataPointType.rating: return 'rating'; case DataPointType.switchType: return 'switch'; case DataPointType.checkbox: return 'checkbox'; case DataPointType.booleanType: return 'boolean'; case DataPointType.date: return 'date'; case DataPointType.time: return 'time'; case DataPointType.datetime: return 'datetime'; case DataPointType.fileUpload: return 'file_upload'; case DataPointType.singleSelect: return 'single_select'; case DataPointType.multiSelect: return 'multi_select'; } }

enum ResponseStatus { valid, invalid, pending }
ResponseStatus responseStatusFromString(String s) { switch (s) { case 'valid': return ResponseStatus.valid; case 'invalid': return ResponseStatus.invalid; default: return ResponseStatus.pending; } }
String responseStatusToString(ResponseStatus s) { switch (s) { case ResponseStatus.valid: return 'valid'; case ResponseStatus.invalid: return 'invalid'; case ResponseStatus.pending: return 'pending'; } }

class ValidationSchema {
  final bool isRequired; final int? minLength; final int? maxLength; final double? minValue; final double? maxValue; final String? regexPattern; final String? errorMessage;
  const ValidationSchema({this.isRequired = false, this.minLength, this.maxLength, this.minValue, this.maxValue, this.regexPattern, this.errorMessage});
  factory ValidationSchema.fromJson(Map<String, dynamic> j) => ValidationSchema(isRequired: j['is_required'] ?? false, minLength: j['min_length'], maxLength: j['max_length'], minValue: (j['min_value'] as num?)?.toDouble(), maxValue: (j['max_value'] as num?)?.toDouble(), regexPattern: j['regex_pattern'], errorMessage: j['error_message']);
  Map<String, dynamic> toJson() { final m = <String, dynamic>{}; if (isRequired) m['is_required'] = true; if (minLength != null) m['min_length'] = minLength; if (maxLength != null) m['max_length'] = maxLength; if (minValue != null) m['min_value'] = minValue; if (maxValue != null) m['max_value'] = maxValue; if (regexPattern != null) m['regex_pattern'] = regexPattern; if (errorMessage != null) m['error_message'] = errorMessage; return m; }
}

class FileValidationSchema {
  final bool isRequired; final List<String>? allowedExtensions; final double? maxSizeMb; final int? minFiles; final int? maxFiles; final String? errorMessage;
  const FileValidationSchema({this.isRequired = false, this.allowedExtensions, this.maxSizeMb, this.minFiles, this.maxFiles, this.errorMessage});
  factory FileValidationSchema.fromJson(Map<String, dynamic> j) => FileValidationSchema(isRequired: j['is_required'] ?? false, allowedExtensions: (j['allowed_extensions'] as List?)?.map((e) => e.toString()).toList(), maxSizeMb: (j['max_size_mb'] as num?)?.toDouble(), minFiles: j['min_files'], maxFiles: j['max_files'], errorMessage: j['error_message']);
  Map<String, dynamic> toJson() { final m = <String, dynamic>{}; if (isRequired) m['is_required'] = true; if (allowedExtensions != null) m['allowed_extensions'] = allowedExtensions; if (maxSizeMb != null) m['max_size_mb'] = maxSizeMb; if (minFiles != null) m['min_files'] = minFiles; if (maxFiles != null) m['max_files'] = maxFiles; if (errorMessage != null) m['error_message'] = errorMessage; return m; }
}

class DependencySchema {
  final String targetId; final String operator; final dynamic comparisonValue;
  const DependencySchema({required this.targetId, required this.operator, required this.comparisonValue});
  factory DependencySchema.fromJson(Map<String, dynamic> j) => DependencySchema(targetId: j['target_id'], operator: j['operator'], comparisonValue: j['comparison_value']);
  Map<String, dynamic> toJson() => {'target_id': targetId, 'operator': operator, 'comparison_value': comparisonValue};
}

class DependencyConfig {
  final String mode; // 'AND' or 'OR', defaults to 'AND'
  final List<DependencySchema> conditions;
  const DependencyConfig({this.mode = 'AND', required this.conditions});

  /// Backward-compatible: accepts old flat format (single DependencySchema)
  /// or new compound format with conditions array.
  factory DependencyConfig.fromJson(Map<String, dynamic> j) {
    if (j.containsKey('conditions')) {
      return DependencyConfig(
        mode: (j['mode'] as String?) ?? 'AND',
        conditions: (j['conditions'] as List)
            .map((e) => DependencySchema.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    // Old 2.x format: single DependencySchema at top level
    return DependencyConfig(mode: 'AND', conditions: [DependencySchema.fromJson(j)]);
  }

  Map<String, dynamic> toJson() => {
    'mode': mode,
    'conditions': conditions.map((c) => c.toJson()).toList(),
  };

  DependencyConfig remapIds(Map<String, String> idMap) {
    final remapped = conditions.map((c) {
      if (idMap.containsKey(c.targetId)) {
        return DependencySchema(targetId: idMap[c.targetId]!, operator: c.operator, comparisonValue: c.comparisonValue);
      }
      return c;
    }).toList();
    return DependencyConfig(mode: mode, conditions: remapped);
  }
}

class TextResponse { final String dataType = 'text'; String timestamp; ResponseStatus status; String value; TextResponse({required this.value, this.status = ResponseStatus.pending, String? timestamp}) : timestamp = timestamp ?? DateTime.now().toUtc().toIso8601String(); factory TextResponse.fromJson(Map<String, dynamic> j) => TextResponse(value: j['value'] ?? '', status: responseStatusFromString(j['status'] ?? 'pending'), timestamp: j['timestamp']); Map<String, dynamic> toJson() => {'data_type': dataType, 'timestamp': timestamp, 'status': responseStatusToString(status), 'value': value}; }
class NumberResponse { final String dataType = 'number'; String timestamp; ResponseStatus status; double value; NumberResponse({required this.value, this.status = ResponseStatus.pending, String? timestamp}) : timestamp = timestamp ?? DateTime.now().toUtc().toIso8601String(); factory NumberResponse.fromJson(Map<String, dynamic> j) => NumberResponse(value: (j['value'] as num?)?.toDouble() ?? 0, status: responseStatusFromString(j['status'] ?? 'pending'), timestamp: j['timestamp']); Map<String, dynamic> toJson() => {'data_type': dataType, 'timestamp': timestamp, 'status': responseStatusToString(status), 'value': value}; }
class BooleanResponse { final String dataType = 'boolean'; String timestamp; ResponseStatus status; bool value; BooleanResponse({required this.value, this.status = ResponseStatus.pending, String? timestamp}) : timestamp = timestamp ?? DateTime.now().toUtc().toIso8601String(); factory BooleanResponse.fromJson(Map<String, dynamic> j) => BooleanResponse(value: j['value'] ?? false, status: responseStatusFromString(j['status'] ?? 'pending'), timestamp: j['timestamp']); Map<String, dynamic> toJson() => {'data_type': dataType, 'timestamp': timestamp, 'status': responseStatusToString(status), 'value': value}; }
class DateTimeResponse { final String dataType = 'datetime'; String timestamp; ResponseStatus status; String value; DateTimeResponse({required this.value, this.status = ResponseStatus.pending, String? timestamp}) : timestamp = timestamp ?? DateTime.now().toUtc().toIso8601String(); factory DateTimeResponse.fromJson(Map<String, dynamic> j) => DateTimeResponse(value: j['value'] ?? '', status: responseStatusFromString(j['status'] ?? 'pending'), timestamp: j['timestamp']); Map<String, dynamic> toJson() => {'data_type': dataType, 'timestamp': timestamp, 'status': responseStatusToString(status), 'value': value}; }

class FileMetadata {
  final String fileName; final int fileSizeBytes; final String mimeType; final String url; final String? thumbnailUrl;
  const FileMetadata({required this.fileName, required this.fileSizeBytes, required this.mimeType, required this.url, this.thumbnailUrl});
  factory FileMetadata.fromJson(Map<String, dynamic> j) => FileMetadata(fileName: j['file_name'] ?? '', fileSizeBytes: j['file_size_bytes'] ?? 0, mimeType: j['mime_type'] ?? '', url: j['url'] ?? '', thumbnailUrl: j['thumbnail_url']);
  Map<String, dynamic> toJson() { final m = <String, dynamic>{'file_name': fileName, 'file_size_bytes': fileSizeBytes, 'mime_type': mimeType, 'url': url}; if (thumbnailUrl != null) m['thumbnail_url'] = thumbnailUrl; return m; }
}

class FileUploadResponse { final String dataType = 'file_upload'; String timestamp; ResponseStatus status; List<FileMetadata> value; FileUploadResponse({required this.value, this.status = ResponseStatus.pending, String? timestamp}) : timestamp = timestamp ?? DateTime.now().toUtc().toIso8601String(); factory FileUploadResponse.fromJson(Map<String, dynamic> j) => FileUploadResponse(value: (j['value'] as List?)?.map((e) => FileMetadata.fromJson(e)).toList() ?? [], status: responseStatusFromString(j['status'] ?? 'pending'), timestamp: j['timestamp']); Map<String, dynamic> toJson() => {'data_type': dataType, 'timestamp': timestamp, 'status': responseStatusToString(status), 'value': value.map((e) => e.toJson()).toList()}; }

class SelectionResponse {
  final String dataType = 'selection'; String timestamp; ResponseStatus status; List<String> selectedIds; dynamic value;
  SelectionResponse({required this.selectedIds, required this.value, this.status = ResponseStatus.pending, String? timestamp}) : timestamp = timestamp ?? DateTime.now().toUtc().toIso8601String();
  factory SelectionResponse.fromJson(Map<String, dynamic> j) {
    dynamic parsedValue;
    final rawVal = j['value'];
    if (rawVal is List) { parsedValue = rawVal.map((e) => e is Map<String, dynamic> ? SelectionDataPointOption.fromJson(e) : e).toList(); }
    else if (rawVal is Map<String, dynamic>) { parsedValue = SelectionDataPointOption.fromJson(rawVal); }
    else { parsedValue = rawVal; }
    return SelectionResponse(selectedIds: (j['selected_ids'] as List?)?.map((e) => e.toString()).toList() ?? [], value: parsedValue, status: responseStatusFromString(j['status'] ?? 'pending'), timestamp: j['timestamp']);
  }
  Map<String, dynamic> toJson() { dynamic sv; if (value is List) { sv = (value as List).map((e) => e is SelectionDataPointOption ? e.toJson() : e).toList(); } else if (value is SelectionDataPointOption) { sv = (value as SelectionDataPointOption).toJson(); } else { sv = value; } return {'data_type': dataType, 'timestamp': timestamp, 'status': responseStatusToString(status), 'selected_ids': selectedIds, 'value': sv}; }
}

class SelectionOptionContent {
  final String? title; final String? subtitle; final String? description; final String? logo; final bool isUserEditable; final Layout? dfup;
  const SelectionOptionContent({this.title, this.subtitle, this.description, this.logo, this.isUserEditable = false, this.dfup});
  static final _tokenRe = RegExp(r'\{\{([^}]+)\}\}');
  String resolveField(String? raw) { if (raw == null || raw.isEmpty || dfup == null) return raw ?? ''; final pts = dfup!.collectAllDataPoints(); final reg = <String, DataPoint>{}; for (final dp in pts) { reg[dp.id] = dp; reg[dp.code] = dp; } return raw.replaceAllMapped(_tokenRe, (m) { final key = m.group(1)!.trim(); final dp = reg[key]; return dp?.responseValue?.toString() ?? ''; }); }
  String get resolvedTitle => resolveField(title);
  String get resolvedSubtitle => resolveField(subtitle);
  String get resolvedDescription => resolveField(description);
  factory SelectionOptionContent.fromJson(Map<String, dynamic> j) => SelectionOptionContent(title: j['title'], subtitle: j['subtitle'], description: j['description'], logo: j['logo'], isUserEditable: j['is_user_editable'] ?? false, dfup: j['DFUP'] != null ? Layout.fromJson(j['DFUP']) : null);
  Map<String, dynamic> toJson() { final m = <String, dynamic>{}; if (title != null) m['title'] = title; if (subtitle != null) m['subtitle'] = subtitle; if (description != null) m['description'] = description; if (logo != null) m['logo'] = logo; if (isUserEditable) m['is_user_editable'] = true; if (dfup != null) m['DFUP'] = dfup!.toJson(); return m; }
}

class SelectionDataPointOption {
  final String id; final String code; final String componentType = 'selection_option'; final bool isDisabled; DependencyConfig? dependency; final SelectionOptionContent value;
  SelectionDataPointOption({required this.id, required this.code, this.isDisabled = false, this.dependency, required this.value});
  factory SelectionDataPointOption.fromJson(Map<String, dynamic> j) => SelectionDataPointOption(id: j['id'] ?? _uuid.v4(), code: j['code'] ?? '', isDisabled: j['is_disabled'] ?? false, dependency: j['dependency'] != null ? DependencyConfig.fromJson(j['dependency']) : null, value: SelectionOptionContent.fromJson(j['value'] ?? {}));
  Map<String, dynamic> toJson() { final m = <String, dynamic>{'id': id, 'code': code, 'component_type': componentType, 'is_disabled': isDisabled, 'value': value.toJson()}; if (dependency != null) m['dependency'] = dependency!.toJson(); return m; }
}

class DataPoint {
  String id; final String code; final String componentType = 'data_point'; final DataPointType type; final String label;
  String? placeholder; String? info; bool isSearchable; bool isFilterable; bool isSuggestable; bool isHidden;
  dynamic defaultValue; ValidationSchema? validation; FileValidationSchema? fileValidation;
  DependencyConfig? dependency; List<SelectionDataPointOption>? options; dynamic response;
  DataPoint({required this.id, required this.code, required this.type, required this.label, this.placeholder, this.info, this.isSearchable = false, this.isFilterable = false, this.isSuggestable = false, this.isHidden = false, this.defaultValue, this.validation, this.fileValidation, this.dependency, this.options, this.response});
  factory DataPoint.fromJson(Map<String, dynamic> j) {
    final dpType = dataPointTypeFromString(j['type'] ?? 'text');
    ValidationSchema? v; FileValidationSchema? fv;
    if (dpType == DataPointType.fileUpload && j['validation'] != null) { fv = FileValidationSchema.fromJson(j['validation']); } else if (j['validation'] != null) { v = ValidationSchema.fromJson(j['validation']); }
    dynamic resp; if (j['response'] != null) { final r = j['response'] as Map<String, dynamic>; switch (r['data_type']) { case 'text': resp = TextResponse.fromJson(r); case 'number': resp = NumberResponse.fromJson(r); case 'boolean': resp = BooleanResponse.fromJson(r); case 'datetime': resp = DateTimeResponse.fromJson(r); case 'file_upload': resp = FileUploadResponse.fromJson(r); case 'selection': resp = SelectionResponse.fromJson(r); } }
    List<SelectionDataPointOption>? opts; if (j['options'] != null) { opts = (j['options'] as List).map((e) => SelectionDataPointOption.fromJson(e as Map<String, dynamic>)).toList(); }
    return DataPoint(id: j['id'] ?? _uuid.v4(), code: j['code'] ?? '', type: dpType, label: j['label'] ?? '', placeholder: j['placeholder'], info: j['info'], isSearchable: j['is_searchable'] ?? false, isFilterable: j['is_filterable'] ?? false, isSuggestable: j['is_suggestable'] ?? false, isHidden: j['is_hidden'] ?? false, defaultValue: j['default_value'], validation: v, fileValidation: fv, dependency: j['dependency'] != null ? DependencyConfig.fromJson(j['dependency']) : null, options: opts, response: resp);
  }
  Map<String, dynamic> toJson() { final m = <String, dynamic>{'id': id, 'code': code, 'component_type': componentType, 'type': dataPointTypeToString(type), 'label': label}; if (placeholder != null) m['placeholder'] = placeholder; if (info != null) m['info'] = info; if (isSearchable) m['is_searchable'] = true; if (isFilterable) m['is_filterable'] = true; if (isSuggestable) m['is_suggestable'] = true; if (isHidden) m['is_hidden'] = true; if (defaultValue != null) m['default_value'] = defaultValue; if (validation != null) m['validation'] = validation!.toJson(); if (fileValidation != null) m['validation'] = fileValidation!.toJson(); if (dependency != null) m['dependency'] = dependency!.toJson(); if (options != null) m['options'] = options!.map((e) => e.toJson()).toList(); if (response != null) m['response'] = response is Map ? response : response.toJson(); return m; }
  DataPoint deepCopy() => DataPoint.fromJson(toJson());
  void _overrideId(String newId) { id = newId; }
  String? get textValue => response is TextResponse ? (response as TextResponse).value : null;
  double? get numberValue => response is NumberResponse ? (response as NumberResponse).value : null;
  bool? get boolValue => response is BooleanResponse ? (response as BooleanResponse).value : null;
  String? get dateValue => response is DateTimeResponse ? (response as DateTimeResponse).value : null;
  dynamic get responseValue { if (response == null) return null; if (response is TextResponse) return (response as TextResponse).value; if (response is NumberResponse) return (response as NumberResponse).value; if (response is BooleanResponse) return (response as BooleanResponse).value; if (response is DateTimeResponse) return (response as DateTimeResponse).value; if (response is SelectionResponse) { final sel = response as SelectionResponse; if (sel.value is SelectionDataPointOption) return (sel.value as SelectionDataPointOption).value.resolvedTitle; if (sel.value is List) return (sel.value as List).map((e) => e is SelectionDataPointOption ? e.value.resolvedTitle : e.toString()).join(', '); } return null; }
}

class DataFrame {
  final String id; final String code; final String componentType = 'data_frame'; final String title; final String? description; final bool allowMultiples; final List<DataPoint> points; List<List<DataPoint>>? instances;
  DataFrame({required this.id, required this.code, required this.title, this.description, this.allowMultiples = false, required this.points, this.instances});
  factory DataFrame.fromJson(Map<String, dynamic> j) { final pts = (j['points'] as List?)?.map((e) => DataPoint.fromJson(e as Map<String, dynamic>)).toList() ?? []; List<List<DataPoint>>? inst; if (j['instances'] != null) { inst = (j['instances'] as List).map((i) => (i as List).map((e) => DataPoint.fromJson(e as Map<String, dynamic>)).toList()).toList(); } return DataFrame(id: j['id'] ?? _uuid.v4(), code: j['code'] ?? '', title: j['title'] ?? '', description: j['description'], allowMultiples: j['allow_multiples'] ?? false, points: pts, instances: inst); }
  Map<String, dynamic> toJson() { final m = <String, dynamic>{'id': id, 'code': code, 'component_type': componentType, 'title': title, 'allow_multiples': allowMultiples, 'points': points.map((e) => e.toJson()).toList()}; if (description != null) m['description'] = description; if (instances != null) m['instances'] = instances!.map((i) => i.map((e) => e.toJson()).toList()).toList(); return m; }
  void addInstance() {
    instances ??= [];
    final idMap = <String, String>{};
    final copied = points.map((p) {
      final newId = _uuid.v4();
      idMap[p.id] = newId;
      final cp = p.deepCopy();
      cp._overrideId(newId);
      return cp;
    }).toList();
    for (final cp in copied) {
      if (cp.dependency != null) {
        cp.dependency = cp.dependency!.remapIds(idMap);
      }
      if (cp.options != null) {
        for (final opt in cp.options!) {
          if (opt.dependency != null) {
            opt.dependency = opt.dependency!.remapIds(idMap);
          }
        }
      }
    }
    instances!.add(copied);
  }
  void removeInstance(int i) { if (instances != null && i < instances!.length) instances!.removeAt(i); }
}

class DataFrameGroup {
  final String id; final String code; final String componentType = 'data_frame_group'; final String title; final String? description; final List<DataFrame> frames;
  DataFrameGroup({required this.id, required this.code, required this.title, this.description, required this.frames});
  factory DataFrameGroup.fromJson(Map<String, dynamic> j) => DataFrameGroup(id: j['id'] ?? _uuid.v4(), code: j['code'] ?? '', title: j['title'] ?? '', description: j['description'], frames: (j['frames'] as List?)?.map((e) => DataFrame.fromJson(e as Map<String, dynamic>)).toList() ?? []);
  Map<String, dynamic> toJson() { final m = <String, dynamic>{'id': id, 'code': code, 'component_type': componentType, 'title': title, 'frames': frames.map((e) => e.toJson()).toList()}; if (description != null) m['description'] = description; return m; }
}

class LayoutChild {
  final DataFrameGroup? group; final DataFrame? frame;
  LayoutChild.fromGroup(this.group) : frame = null;
  LayoutChild.fromFrame(this.frame) : group = null;
  bool get isGroup => group != null;
  bool get isFrame => frame != null;
  String get title => isGroup ? group!.title : frame!.title;
  Map<String, dynamic> toJson() => isGroup ? group!.toJson() : frame!.toJson();
  static LayoutChild fromJson(Map<String, dynamic> j) { if (j['component_type'] == 'data_frame_group') return LayoutChild.fromGroup(DataFrameGroup.fromJson(j)); return LayoutChild.fromFrame(DataFrame.fromJson(j)); }
}

class Layout {
  final String id; final String code; final String componentType = 'layout'; final LayoutType layoutType; final String? title; final List<LayoutChild> children;
  Layout({required this.id, required this.code, required this.layoutType, this.title, required this.children});
  factory Layout.fromJson(Map<String, dynamic> j) { final ch = j['children'] as List? ?? []; return Layout(id: j['id'] ?? _uuid.v4(), code: j['code'] ?? '', layoutType: layoutTypeFromString(j['layout_type'] ?? 'scroll'), title: j['title'], children: ch.map((e) => LayoutChild.fromJson(e as Map<String, dynamic>)).toList()); }
  Map<String, dynamic> toJson() { final m = <String, dynamic>{'id': id, 'code': code, 'component_type': componentType, 'layout_type': layoutTypeToString(layoutType), 'children': children.map((e) => e.toJson()).toList()}; if (title != null) m['title'] = title; return m; }
  List<DataPoint> collectAllDataPoints() { final r = <DataPoint>[]; for (final c in children) { if (c.isGroup) { for (final f in c.group!.frames) _col(f, r); } else if (c.isFrame) _col(c.frame!, r); } return r; }
  void _col(DataFrame f, List<DataPoint> r) { _colPoints(f.points, r); if (f.allowMultiples && f.instances != null) { for (final i in f.instances!) _colPoints(i, r); } }
  void _colPoints(List<DataPoint> pts, List<DataPoint> r) { for (final dp in pts) { r.add(dp); } }
}
