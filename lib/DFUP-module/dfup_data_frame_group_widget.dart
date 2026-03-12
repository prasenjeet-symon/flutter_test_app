// lib/dfup_data_frame_group_widget.dart

import 'package:flutter/material.dart';
import 'dfup_models.dart';
import 'dfup_utils.dart';
import 'dfup_theme.dart';
import 'dfup_data_frame_widget.dart';

class DfupDataFrameGroupWidget extends StatelessWidget {
  final DataFrameGroup group;
  final Map<String, DataPoint> registry;
  final VoidCallback onMutated;
  const DfupDataFrameGroupWidget({super.key, required this.group, required this.registry, required this.onMutated});

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    final rTitle = DynamicResolver.resolve(group.title, registry);
    final rDesc = group.description != null ? DynamicResolver.resolve(group.description, registry) : null;
    return Container(
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(R.lg), boxShadow: c.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.all(S.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c.primary.withValues(alpha: c.isDark ? 0.12 : 0.06), c.primary.withValues(alpha: 0.02)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(R.lg), topRight: Radius.circular(R.lg))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: S.md),
              Expanded(child: Text(rTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.text1))),
            ]),
            if (rDesc != null && rDesc.isNotEmpty) ...[const SizedBox(height: S.sm),
              Padding(padding: const EdgeInsets.only(left: S.lg + 4),
                child: Text(rDesc, style: TextStyle(fontSize: 13, color: c.text2, height: 1.4)))],
          ]),
        ),
        Padding(padding: const EdgeInsets.all(S.xl), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(group.frames.length, (i) {
            final f = group.frames[i];
            final fTitle = DynamicResolver.resolve(f.title, registry);
            final fDesc = f.description != null ? DynamicResolver.resolve(f.description, registry) : null;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (fTitle.isNotEmpty) ...[
                Text(fTitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.text1)),
                if (fDesc != null && fDesc.isNotEmpty) Padding(padding: const EdgeInsets.only(top: S.xs),
                  child: Text(fDesc, style: TextStyle(fontSize: 13, color: c.text2))),
                const SizedBox(height: S.lg),
              ],
              DfupDataFrameWidget(dataFrame: f, registry: registry, onMutated: onMutated),
              if (i < group.frames.length - 1) Padding(padding: const EdgeInsets.symmetric(vertical: S.md),
                child: Divider(color: c.divider, height: 1)),
            ]);
          }),
        )),
      ]),
    );
  }
}
