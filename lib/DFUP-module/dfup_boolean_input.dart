// lib/dfup_boolean_input.dart

import 'package:flutter/material.dart';
import 'dfup_models.dart';
import 'dfup_utils.dart';
import 'dfup_theme.dart';
import 'dfup_label_row.dart';

class DfupBooleanInput extends StatefulWidget {
  final DataPoint dataPoint;
  final VoidCallback onMutated;
  const DfupBooleanInput({super.key, required this.dataPoint, required this.onMutated});
  @override
  State<DfupBooleanInput> createState() => _DfupBooleanInputState();
}

class _DfupBooleanInputState extends State<DfupBooleanInput> {
  late bool _value;
  String? _error;
  DataPoint get dp => widget.dataPoint;

  @override
  void initState() {
    super.initState();
    _value = dp.boolValue ?? (dp.defaultValue as bool?) ?? false;
    if (dp.response == null && dp.defaultValue != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _mutate(_value); });
    }
  }

  void _mutate(bool v) {
    final err = DfupValidator.validateBoolean(dp, v);
    dp.response = BooleanResponse(value: v, status: err == null ? ResponseStatus.valid : ResponseStatus.invalid);
    setState(() { _value = v; _error = err; });
    widget.onMutated();
  }

  @override
  Widget build(BuildContext context) => dp.type == DataPointType.switchType ? _switch() : _checkbox();

  Widget _switch() {
    final c = Cx.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md),
      decoration: BoxDecoration(color: c.inputFill, borderRadius: BorderRadius.circular(R.md),
        border: Border.all(color: c.border, width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            DfupLabelRow(label: dp.label, isRequired: dp.validation?.isRequired ?? false),
            if (dp.info != null) ...[const SizedBox(height: S.xs),
              Text(dp.info!, style: TextStyle(fontSize: 13, color: c.text2))],
          ])),
          const SizedBox(width: S.md),
          Transform.scale(scale: 0.9, child: Switch.adaptive(
            value: _value, onChanged: _mutate, activeColor: c.primary,
            activeTrackColor: c.primaryLight, inactiveThumbColor: c.hint, inactiveTrackColor: c.border)),
        ]),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: S.xs),
          child: Text(_error!, style: TextStyle(fontSize: 12, color: c.error))),
      ]),
    );
  }

  Widget _checkbox() {
    final c = Cx.of(context);
    return GestureDetector(
      onTap: () => _mutate(!_value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md),
        decoration: BoxDecoration(color: c.inputFill, borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: _value ? c.primary : c.border, width: _value ? 2 : 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200), width: 22, height: 22,
              decoration: BoxDecoration(color: _value ? c.primary : Colors.transparent, borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _value ? c.primary : c.hint, width: 2)),
              child: _value ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: S.md),
            Expanded(child: Text(dp.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              color: _value ? c.text1 : c.text2))),
            if (dp.info != null) Tooltip(message: dp.info!, child: Icon(Icons.info_outline, size: 16, color: c.hint)),
          ]),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: S.xs),
            child: Text(_error!, style: TextStyle(fontSize: 12, color: c.error))),
        ]),
      ),
    );
  }
}
