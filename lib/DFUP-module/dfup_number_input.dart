// lib/dfup_number_input.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dfup_models.dart';
import 'dfup_utils.dart';
import 'dfup_theme.dart';
import 'dfup_label_row.dart';

class DfupNumberInput extends StatefulWidget {
  final DataPoint dataPoint;
  final VoidCallback onMutated;
  const DfupNumberInput({super.key, required this.dataPoint, required this.onMutated});
  @override
  State<DfupNumberInput> createState() => _DfupNumberInputState();
}

class _DfupNumberInputState extends State<DfupNumberInput> {
  late TextEditingController _ctrl;
  String? _error;
  double _sliderVal = 0;
  int _ratingVal = 0;
  DataPoint get dp => widget.dataPoint;

  @override
  void initState() {
    super.initState();
    final initial = dp.numberValue ?? (dp.defaultValue as num?)?.toDouble();
    _ctrl = TextEditingController(text: initial?.toString() ?? '');
    _sliderVal = initial ?? dp.validation?.minValue ?? 0;
    _ratingVal = initial?.toInt() ?? 0;
    if (initial != null && dp.response == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _mutate(initial); });
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _mutate(double? v) {
    final err = DfupValidator.validateNumber(dp, v);
    dp.response = NumberResponse(value: v ?? 0, status: err == null ? ResponseStatus.valid : ResponseStatus.invalid);
    setState(() => _error = err);
    widget.onMutated();
  }

  @override
  Widget build(BuildContext context) {
    final req = dp.validation?.isRequired ?? false;
    if (dp.type == DataPointType.slider) return _slider(req);
    if (dp.type == DataPointType.rating) return _rating(req);
    return _field(req);
  }

  Widget _field(bool req) {
    final c = Cx.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DfupLabelRow(label: dp.label, isRequired: req, info: dp.info),
      const SizedBox(height: S.sm),
      TextFormField(
        controller: _ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
        style: TextStyle(fontSize: 15, color: c.text1, fontWeight: FontWeight.w500),
        decoration: InputDecoration(hintText: dp.placeholder ?? 'Enter a number',
          prefixIcon: Icon(Icons.tag, size: 20, color: c.hint), errorText: _error),
        onChanged: (v) => _mutate(double.tryParse(v)),
      ),
    ]);
  }

  Widget _slider(bool req) {
    final c = Cx.of(context);
    final mn = dp.validation?.minValue ?? 0, mx = dp.validation?.maxValue ?? 100;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DfupLabelRow(label: dp.label, isRequired: req, info: dp.info),
      const SizedBox(height: S.md),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md),
        decoration: BoxDecoration(color: c.inputFill, borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: c.border, width: 1.5)),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(mn.toStringAsFixed(0), style: TextStyle(fontSize: 12, color: c.hint, fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.xs),
              decoration: BoxDecoration(color: c.primarySurface, borderRadius: BorderRadius.circular(R.pill)),
              child: Text(_sliderVal.toStringAsFixed(_sliderVal == _sliderVal.roundToDouble() ? 0 : 1),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.primary)),
            ),
            Text(mx.toStringAsFixed(0), style: TextStyle(fontSize: 12, color: c.hint, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: S.xs),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: c.primary, inactiveTrackColor: c.primary.withValues(alpha: 0.15),
              thumbColor: c.primary, overlayColor: c.primary.withValues(alpha: 0.12),
              trackHeight: 6, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20)),
            child: Slider(value: _sliderVal.clamp(mn, mx), min: mn, max: mx, onChanged: (v) {
              setState(() => _sliderVal = v); _mutate(v);
            }),
          ),
        ]),
      ),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: S.xs, left: S.lg),
        child: Text(_error!, style: TextStyle(fontSize: 12, color: c.error))),
    ]);
  }

  Widget _rating(bool req) {
    final c = Cx.of(context);
    final max = dp.validation?.maxValue?.toInt() ?? 5;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DfupLabelRow(label: dp.label, isRequired: req, info: dp.info),
      const SizedBox(height: S.md),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md),
        decoration: BoxDecoration(color: c.inputFill, borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: c.border, width: 1.5)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(max, (i) {
          final idx = i + 1; final on = idx <= _ratingVal;
          return GestureDetector(
            onTap: () { setState(() => _ratingVal = _ratingVal == idx ? 0 : idx); _mutate(_ratingVal.toDouble()); },
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: S.xs), child: AnimatedScale(
              scale: on ? 1.1 : 1.0, duration: const Duration(milliseconds: 150),
              child: Icon(on ? Icons.star_rounded : Icons.star_outline_rounded, size: 36,
                color: on ? const Color(0xFFFFC107) : c.hint))),
          );
        })),
      ),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: S.xs, left: S.lg),
        child: Text(_error!, style: TextStyle(fontSize: 12, color: c.error))),
    ]);
  }
}
