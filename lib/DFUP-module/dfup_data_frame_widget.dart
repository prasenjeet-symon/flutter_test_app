// lib/dfup_data_frame_widget.dart

import 'package:flutter/material.dart';
import 'dfup_models.dart';
import 'dfup_theme.dart';
import 'dfup_data_point_renderer.dart';

class DfupDataFrameWidget extends StatefulWidget {
  final DataFrame dataFrame;
  final Map<String, DataPoint> registry;
  final VoidCallback onMutated;
  const DfupDataFrameWidget({super.key, required this.dataFrame, required this.registry, required this.onMutated});
  @override
  State<DfupDataFrameWidget> createState() => _DfupDataFrameWidgetState();
}

class _DfupDataFrameWidgetState extends State<DfupDataFrameWidget> {
  DataFrame get frame => widget.dataFrame;

  void _addInstance() {
    frame.addInstance();
    final newInst = frame.instances!.last;
    for (final dp in newInst) widget.registry[dp.id] = dp;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) widget.onMutated(); });
  }

  void _removeInstance(int i) {
    final inst = frame.instances![i];
    for (final dp in inst) widget.registry.remove(dp.id);
    frame.removeInstance(i);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) widget.onMutated(); });
  }

  @override
  Widget build(BuildContext context) => frame.allowMultiples ? _multi() : _single();

  Widget _single() => _pointsList(frame.points, null, -1);

  Widget _multi() {
    final c = Cx.of(context);
    final instances = frame.instances ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...List.generate(instances.length, (i) => Padding(
        padding: const EdgeInsets.only(bottom: S.md),
        child: Container(
          padding: const EdgeInsets.all(S.lg),
          decoration: BoxDecoration(
            color: c.card, borderRadius: BorderRadius.circular(R.md),
            border: Border.all(color: c.primary.withValues(alpha: 0.2), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))]),
          child: _pointsList(instances[i], 'Entry ${i + 1}', i),
        ),
      )),
      Center(child: TextButton.icon(
        onPressed: _addInstance,
        icon: Container(width: 28, height: 28, decoration: BoxDecoration(
          color: c.primarySurface, borderRadius: BorderRadius.circular(R.sm)),
          child: Icon(Icons.add, size: 18, color: c.primary)),
        label: Text('Add ${frame.title}'),
      )),
    ]);
  }

  Widget _pointsList(List<DataPoint> points, String? label, int idx) {
    final c = Cx.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label != null) Padding(padding: const EdgeInsets.only(bottom: S.md), child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.xs),
          decoration: BoxDecoration(color: c.primarySurface, borderRadius: BorderRadius.circular(R.pill)),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.primary, letterSpacing: 0.5))),
        const Spacer(),
        if (idx >= 0) GestureDetector(
          onTap: () => _removeInstance(idx),
          child: Container(padding: const EdgeInsets.all(S.xs),
            decoration: BoxDecoration(color: c.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(R.sm)),
            child: Icon(Icons.delete_outline, size: 18, color: c.error))),
      ])),
      ...points.map((dp) => Padding(
        padding: const EdgeInsets.only(bottom: S.lg),
        child: DfupDataPointRenderer(dataPoint: dp, registry: widget.registry, onMutated: widget.onMutated))),
    ]);
  }
}
