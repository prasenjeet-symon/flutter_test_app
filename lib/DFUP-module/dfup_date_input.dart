// lib/dfup_date_input.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dfup_models.dart';
import 'dfup_utils.dart';
import 'dfup_theme.dart';
import 'dfup_label_row.dart';

class DfupDateInput extends StatefulWidget {
  final DataPoint dataPoint;
  final VoidCallback onMutated;
  const DfupDateInput({super.key, required this.dataPoint, required this.onMutated});
  @override
  State<DfupDateInput> createState() => _DfupDateInputState();
}

class _DfupDateInputState extends State<DfupDateInput> {
  DateTime? _date;
  TimeOfDay? _time;
  String? _error;
  DataPoint get dp => widget.dataPoint;

  @override
  void initState() {
    super.initState();
    if (dp.dateValue != null && dp.dateValue!.isNotEmpty) {
      try { final p = DateTime.parse(dp.dateValue!); _date = p; _time = TimeOfDay.fromDateTime(p); } catch (_) {}
    } else if (dp.defaultValue != null) {
      try {
        final p = DateTime.parse(dp.defaultValue.toString()); _date = p; _time = TimeOfDay.fromDateTime(p);
        WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _mutate(); });
      } catch (_) {}
    }
  }

  void _mutate() {
    String value = '';
    if (_date != null) {
      if (dp.type == DataPointType.time && _time != null) { value = '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}:00'; }
      else if (dp.type == DataPointType.datetime && _time != null) { final dt = DateTime(_date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute); value = dt.toUtc().toIso8601String(); }
      else { value = _date!.toIso8601String().split('T').first; }
    }
    final err = DfupValidator.validateDate(dp, value);
    dp.response = DateTimeResponse(value: value, status: err == null ? ResponseStatus.valid : ResponseStatus.invalid);
    setState(() => _error = err);
    widget.onMutated();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _date ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (d != null) { _date = d; if (dp.type == DataPointType.datetime || dp.type == DataPointType.time) { await _pickTime(); } else { _mutate(); } }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time ?? TimeOfDay.now());
    if (t != null) { _time = t; _date ??= DateTime.now(); _mutate(); }
  }

  String _display() {
    if (_date == null && _time == null) return dp.placeholder ?? _hint();
    switch (dp.type) {
      case DataPointType.date: return DateFormat.yMMMd().format(_date!);
      case DataPointType.time: return _time != null ? _time!.format(context) : '';
      case DataPointType.datetime: return '${DateFormat.yMMMd().format(_date!)}  ${_time != null ? _time!.format(context) : ''}';
      default: return '';
    }
  }

  String _hint() { switch (dp.type) { case DataPointType.date: return 'Select a date'; case DataPointType.time: return 'Select a time'; default: return 'Select date & time'; } }
  IconData _icon() { switch (dp.type) { case DataPointType.time: return Icons.access_time_outlined; case DataPointType.datetime: return Icons.event_outlined; default: return Icons.calendar_today_outlined; } }

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    final has = _date != null || _time != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DfupLabelRow(label: dp.label, isRequired: dp.validation?.isRequired ?? false, info: dp.info),
      const SizedBox(height: S.sm),
      GestureDetector(
        onTap: () => dp.type == DataPointType.time ? _pickTime() : _pickDate(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md + 2),
          decoration: BoxDecoration(color: c.inputFill, borderRadius: BorderRadius.circular(R.md),
            border: Border.all(color: _error != null ? c.error : has ? c.primary.withValues(alpha: 0.5) : c.border, width: 1.5)),
          child: Row(children: [
            Icon(_icon(), size: 20, color: has ? c.primary : c.hint),
            const SizedBox(width: S.md),
            Expanded(child: Text(_display(), style: TextStyle(fontSize: 15,
              fontWeight: has ? FontWeight.w500 : FontWeight.w400, color: has ? c.text1 : c.hint))),
            if (has) GestureDetector(
              onTap: () { setState(() { _date = null; _time = null; }); dp.response = null; widget.onMutated(); },
              child: Icon(Icons.close, size: 18, color: c.hint)),
          ]),
        ),
      ),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: S.xs, left: S.lg),
        child: Text(_error!, style: TextStyle(fontSize: 12, color: c.error))),
    ]);
  }
}
