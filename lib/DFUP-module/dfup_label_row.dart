// lib/dfup_label_row.dart

import 'package:flutter/material.dart';
import 'dfup_theme.dart';

class DfupLabelRow extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? info;
  const DfupLabelRow({super.key, required this.label, required this.isRequired, this.info});

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    return Row(children: [
      Expanded(child: RichText(text: TextSpan(
        text: label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.text1),
        children: isRequired ? [TextSpan(text: ' *', style: TextStyle(color: c.error, fontWeight: FontWeight.w700))] : null,
      ))),
      if (info != null) Tooltip(message: info!, child: Icon(Icons.info_outline, size: 16, color: c.hint)),
    ]);
  }
}
