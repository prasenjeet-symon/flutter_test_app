// lib/dfup_label_row.dart

import 'package:flutter/material.dart';
import 'dfup_models.dart';
import 'dfup_utils.dart';
import 'dfup_theme.dart';

class DfupLabelRow extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? info;
  final Map<String, DataPoint>? registry;
  const DfupLabelRow({super.key, required this.label, required this.isRequired, this.info, this.registry});

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    final resolvedLabel = registry != null ? DynamicResolver.resolve(label, registry!) : label;
    final resolvedInfo = registry != null && info != null ? DynamicResolver.resolve(info, registry!) : info;
    return Row(children: [
      Expanded(child: RichText(text: TextSpan(
        text: resolvedLabel,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.text1),
        children: isRequired ? [TextSpan(text: ' *', style: TextStyle(color: c.error, fontWeight: FontWeight.w700))] : null,
      ))),
      if (resolvedInfo != null) Tooltip(message: resolvedInfo, child: Icon(Icons.info_outline, size: 16, color: c.hint)),
    ]);
  }
}
