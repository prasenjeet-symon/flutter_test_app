// lib/dfup_data_point_renderer.dart

import 'package:flutter/material.dart';
import 'dfup_models.dart';
import 'dfup_utils.dart';
import 'dfup_text_input.dart';
import 'dfup_number_input.dart';
import 'dfup_boolean_input.dart';
import 'dfup_date_input.dart';
import 'dfup_file_input.dart';
import 'dfup_selection_input.dart';

class DfupDataPointRenderer extends StatelessWidget {
  final DataPoint dataPoint;
  final Map<String, DataPoint> registry;
  final VoidCallback onMutated;
  const DfupDataPointRenderer({super.key, required this.dataPoint, required this.registry, required this.onMutated});

  @override
  Widget build(BuildContext context) {
    // Permanently hidden data points: never render, never clear response
    if (dataPoint.isHidden) return const SizedBox.shrink();

    // Dependency-based visibility with response clearing on hide
    if (!DependencyEvaluator.isVisible(dataPoint, registry)) {
      if (dataPoint.response != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          dataPoint.response = null;
          onMutated();
        });
      }
      return const SizedBox.shrink();
    }

    // Apply default_value if response is null
    if (dataPoint.response == null && dataPoint.defaultValue != null) {
      _applyDefaultValue(dataPoint);
    }

    Widget child;
    switch (dataPoint.type) {
      case DataPointType.text: case DataPointType.email: case DataPointType.password: case DataPointType.phone: case DataPointType.multiline:
        child = DfupTextInput(key: ValueKey(dataPoint.id), dataPoint: dataPoint, registry: registry, onMutated: onMutated);
      case DataPointType.number: case DataPointType.slider: case DataPointType.rating:
        child = DfupNumberInput(key: ValueKey(dataPoint.id), dataPoint: dataPoint, registry: registry, onMutated: onMutated);
      case DataPointType.switchType: case DataPointType.checkbox: case DataPointType.booleanType:
        child = DfupBooleanInput(key: ValueKey(dataPoint.id), dataPoint: dataPoint, registry: registry, onMutated: onMutated);
      case DataPointType.date: case DataPointType.time: case DataPointType.datetime:
        child = DfupDateInput(key: ValueKey(dataPoint.id), dataPoint: dataPoint, registry: registry, onMutated: onMutated);
      case DataPointType.fileUpload:
        child = DfupFileInput(key: ValueKey(dataPoint.id), dataPoint: dataPoint, registry: registry, onMutated: onMutated);
      case DataPointType.singleSelect: case DataPointType.multiSelect:
        child = DfupSelectionInput(key: ValueKey(dataPoint.id), dataPoint: dataPoint, registry: registry, onMutated: onMutated);
    }
    return AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: child);
  }

  static void _applyDefaultValue(DataPoint dp) {
    final dv = dp.defaultValue;
    switch (dp.type) {
      case DataPointType.text: case DataPointType.email: case DataPointType.password: case DataPointType.phone: case DataPointType.multiline:
        dp.response = TextResponse(value: dv.toString(), status: ResponseStatus.valid);
      case DataPointType.number: case DataPointType.slider: case DataPointType.rating:
        final n = dv is num ? dv.toDouble() : double.tryParse(dv.toString());
        if (n != null) dp.response = NumberResponse(value: n, status: ResponseStatus.valid);
      case DataPointType.switchType: case DataPointType.checkbox: case DataPointType.booleanType:
        final b = dv is bool ? dv : (dv.toString().toLowerCase() == 'true');
        dp.response = BooleanResponse(value: b, status: ResponseStatus.valid);
      case DataPointType.date: case DataPointType.time: case DataPointType.datetime:
        dp.response = DateTimeResponse(value: dv.toString(), status: ResponseStatus.valid);
      default:
        break;
    }
  }
}
