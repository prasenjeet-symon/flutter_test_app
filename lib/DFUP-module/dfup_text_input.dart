// lib/dfup_text_input.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dfup_models.dart';
import 'dfup_utils.dart';
import 'dfup_theme.dart';
import 'dfup_label_row.dart';

class DfupTextInput extends StatefulWidget {
  final DataPoint dataPoint;
  final VoidCallback onMutated;
  const DfupTextInput({super.key, required this.dataPoint, required this.onMutated});
  @override
  State<DfupTextInput> createState() => _DfupTextInputState();
}

class _DfupTextInputState extends State<DfupTextInput> {
  late TextEditingController _ctrl;
  String? _error;
  bool _obscure = false;
  DataPoint get dp => widget.dataPoint;

  @override
  void initState() {
    super.initState();
    final initial = dp.textValue ?? dp.defaultValue?.toString() ?? '';
    _ctrl = TextEditingController(text: initial);
    _obscure = dp.type == DataPointType.password;
    if (initial.isNotEmpty && dp.response == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _mutate(initial); });
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _mutate(String value) {
    final err = DfupValidator.validateText(dp, value);
    dp.response = TextResponse(value: value, status: err == null ? ResponseStatus.valid : ResponseStatus.invalid);
    setState(() => _error = err);
    widget.onMutated();
  }

  TextInputType _keyboard() { switch (dp.type) { case DataPointType.email: return TextInputType.emailAddress; case DataPointType.phone: return TextInputType.phone; case DataPointType.multiline: return TextInputType.multiline; default: return TextInputType.text; } }
  List<TextInputFormatter> _formatters() { if (dp.type == DataPointType.phone) return [FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-\(\)]+'))]; final ml = dp.validation?.maxLength; return ml != null ? [LengthLimitingTextInputFormatter(ml)] : []; }
  IconData _icon() { switch (dp.type) { case DataPointType.email: return Icons.email_outlined; case DataPointType.phone: return Icons.phone_outlined; case DataPointType.password: return Icons.lock_outline; case DataPointType.multiline: return Icons.notes_outlined; default: return Icons.text_fields_outlined; } }

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    final multi = dp.type == DataPointType.multiline;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DfupLabelRow(label: dp.label, isRequired: dp.validation?.isRequired ?? false, info: dp.info),
      const SizedBox(height: S.sm),
      TextFormField(
        controller: _ctrl, keyboardType: _keyboard(), inputFormatters: _formatters(),
        obscureText: _obscure, maxLines: multi ? 5 : 1, minLines: multi ? 3 : 1,
        style: TextStyle(fontSize: 15, color: c.text1, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: dp.placeholder ?? 'Enter ${dp.label.toLowerCase()}',
          prefixIcon: Icon(_icon(), size: 20, color: c.hint),
          suffixIcon: dp.type == DataPointType.password
              ? IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: c.hint), onPressed: () => setState(() => _obscure = !_obscure))
              : null,
          errorText: _error,
        ),
        onChanged: _mutate,
      ),
      if (multi && dp.validation?.maxLength != null)
        Padding(padding: const EdgeInsets.only(top: S.xs, right: S.sm), child: Align(alignment: Alignment.centerRight,
          child: Text('${_ctrl.text.length}/${dp.validation!.maxLength}',
            style: TextStyle(fontSize: 12, color: _ctrl.text.length > (dp.validation!.maxLength ?? 9999) ? c.error : c.hint)))),
    ]);
  }
}
