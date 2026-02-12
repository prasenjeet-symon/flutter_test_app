// lib/dfup_layout_widget.dart

import 'package:flutter/material.dart';
import 'dfup_models.dart';
import 'dfup_utils.dart';
import 'dfup_theme.dart';
import 'dfup_data_frame_group_widget.dart';
import 'dfup_data_frame_widget.dart';

class DfupLayoutWidget extends StatefulWidget {
  final Layout layout;
  final VoidCallback? onSubmit;
  const DfupLayoutWidget({super.key, required this.layout, this.onSubmit});
  @override
  State<DfupLayoutWidget> createState() => DfupLayoutWidgetState();
}

class DfupLayoutWidgetState extends State<DfupLayoutWidget> with TickerProviderStateMixin {
  late Map<String, DataPoint> _reg;
  TabController? _tabCtrl;
  int _step = 0;
  bool _rebuilding = false;

  // Scroll-mode keys for jump-to-section
  late List<GlobalKey> _childKeys;
  final ScrollController _scrollCtrl = ScrollController();

  Layout get layout => widget.layout;

  @override
  void initState() {
    super.initState();
    _reg = DynamicResolver.buildRegistry(layout);
    _childKeys = List.generate(layout.children.length, (_) => GlobalKey());
    if (layout.layoutType == LayoutType.tab) {
      _tabCtrl = TabController(length: layout.children.length, vsync: this);
    }
  }

  @override
  void dispose() { _tabCtrl?.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _onMutated() {
    _reg = DynamicResolver.buildRegistry(layout);
    if (_rebuilding) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() {}); });
    } else { setState(() {}); }
  }

  /// Public: jump to a layout child by index
  void jumpTo(int index) {
    if (index < 0 || index >= layout.children.length) return;
    switch (layout.layoutType) {
      case LayoutType.scroll:
        _scrollToChild(index);
      case LayoutType.verticalStep:
      case LayoutType.horizontalStep:
        setState(() => _step = index);
      case LayoutType.tab:
        _tabCtrl?.animateTo(index);
    }
  }

  void _scrollToChild(int index) {
    final key = _childKeys[index];
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic, alignment: 0.0);
    }
  }

  void _showJumpSheet() {
    final c = Cx.of(context);
    showModalBottomSheet(
      context: context, isScrollControlled: false, backgroundColor: Colors.transparent,
      builder: (ctx) => _JumpSheet(
        children: layout.children,
        currentIndex: _currentIndex,
        onJump: (i) { Navigator.pop(ctx); jumpTo(i); },
      ),
    );
  }

  int get _currentIndex {
    switch (layout.layoutType) {
      case LayoutType.scroll: return -1; // no single current
      case LayoutType.verticalStep:
      case LayoutType.horizontalStep: return _step;
      case LayoutType.tab: return _tabCtrl?.index ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    _rebuilding = true;
    final result = Stack(children: [
      switch (layout.layoutType) {
        LayoutType.scroll => _scroll(),
        LayoutType.verticalStep => _vStepper(),
        LayoutType.horizontalStep => _hStepper(),
        LayoutType.tab => _tabs(),
      },
      // Jump FAB — only show when >1 child
      if (layout.children.length > 1)
        Positioned(right: S.lg, bottom: S.lg + 60, child: _JumpFab(onTap: _showJumpSheet)),
    ]);
    Future.microtask(() { _rebuilding = false; });
    return result;
  }

  Widget _scroll() => SingleChildScrollView(
    controller: _scrollCtrl,
    padding: const EdgeInsets.all(S.lg),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ...List.generate(layout.children.length, (i) => Padding(
        key: _childKeys[i],
        padding: const EdgeInsets.only(bottom: S.xl),
        child: _child(layout.children[i]))),
      const SizedBox(height: S.md), _submitBtn(),
    ]),
  );

  Widget _vStepper() => Column(children: [
    _StepDots(total: layout.children.length, current: _step,
      labels: layout.children.map((c) => c.title).toList(),
      onTapStep: (i) => jumpTo(i)),
    Expanded(child: SingleChildScrollView(
      padding: const EdgeInsets.all(S.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _child(layout.children[_step]), const SizedBox(height: S.xl), _stepNav()]))),
  ]);

  Widget _hStepper() => Column(children: [
    _StepBar(total: layout.children.length, current: _step,
      labels: layout.children.map((c) => c.title).toList(),
      onTapStep: (i) => jumpTo(i)),
    Expanded(child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (ch, anim) => FadeTransition(opacity: anim, child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim), child: ch)),
      child: SingleChildScrollView(key: ValueKey(_step), padding: const EdgeInsets.all(S.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _child(layout.children[_step]), const SizedBox(height: S.xl), _stepNav()])))),
  ]);

  Widget _tabs() => Column(children: [
    Container(color: Cx.of(context).card, child: TabBar(controller: _tabCtrl, isScrollable: layout.children.length > 4,
      tabs: layout.children.map((c) => Tab(text: c.title)).toList())),
    Expanded(child: TabBarView(controller: _tabCtrl, children: layout.children.map((c) =>
      SingleChildScrollView(padding: const EdgeInsets.all(S.lg), child: _child(c))).toList())),
    Padding(padding: const EdgeInsets.all(S.lg), child: _submitBtn()),
  ]);

  Widget _child(LayoutChild c) {
    final cx = Cx.of(context);
    if (c.isGroup) return DfupDataFrameGroupWidget(group: c.group!, registry: _reg, onMutated: _onMutated);
    final f = c.frame!;
    return Container(
      decoration: BoxDecoration(color: cx.card, borderRadius: BorderRadius.circular(R.lg), boxShadow: cx.cardShadow),
      child: Padding(padding: const EdgeInsets.all(S.xl), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (f.title.isNotEmpty) ...[
            Text(f.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cx.text1)),
            if (f.description != null) Padding(padding: const EdgeInsets.only(top: S.xs),
              child: Text(f.description!, style: TextStyle(fontSize: 13, color: cx.text2))),
            const SizedBox(height: S.xl),
          ],
          DfupDataFrameWidget(dataFrame: f, registry: _reg, onMutated: _onMutated),
        ],
      )),
    );
  }

  Widget _stepNav() {
    final cx = Cx.of(context);
    final first = _step == 0, last = _step == layout.children.length - 1;
    return Row(children: [
      if (!first) Expanded(child: OutlinedButton.icon(
        onPressed: () => setState(() => _step--),
        icon: const Icon(Icons.arrow_back_ios, size: 16), label: const Text('Previous'),
        style: OutlinedButton.styleFrom(foregroundColor: cx.text2, side: BorderSide(color: cx.border),
          padding: const EdgeInsets.symmetric(vertical: S.md), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.md))))),
      if (!first) const SizedBox(width: S.md),
      Expanded(child: last ? _submitBtn() : ElevatedButton(
        onPressed: () => setState(() => _step++),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: S.md)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Next'), SizedBox(width: S.sm), Icon(Icons.arrow_forward_ios, size: 16)]))),
    ]);
  }

  Widget _submitBtn() {
    final cx = Cx.of(context);
    return SizedBox(width: double.infinity, child: ElevatedButton(
      onPressed: () {
        widget.onSubmit?.call();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: S.sm), Expanded(child: Text('Form submitted successfully!'))]),
          backgroundColor: cx.success, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.md)),
          margin: const EdgeInsets.all(S.lg)));
      },
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: S.lg), backgroundColor: cx.primary),
      child: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
    ));
  }
}

// ═══════════════════════════════════════════════════════════════
// Jump FAB
// ═══════════════════════════════════════════════════════════════

class _JumpFab extends StatelessWidget {
  final VoidCallback onTap;
  const _JumpFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: c.primary, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))]),
        child: const Icon(Icons.segment_rounded, size: 22, color: Colors.white),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Jump Sheet — list of all LayoutChild sections
// ═══════════════════════════════════════════════════════════════

class _JumpSheet extends StatelessWidget {
  final List<LayoutChild> children;
  final int currentIndex;
  final void Function(int) onJump;
  const _JumpSheet({required this.children, required this.currentIndex, required this.onJump});

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    return Container(
      decoration: BoxDecoration(color: c.sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(R.xl)),
        boxShadow: c.elevatedShadow),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(margin: const EdgeInsets.only(top: S.md), width: 40, height: 4,
          decoration: BoxDecoration(color: c.hint.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(S.xl, S.lg, S.xl, S.sm),
          child: Row(children: [
            Icon(Icons.segment_rounded, size: 20, color: c.primary),
            const SizedBox(width: S.md),
            Text('Jump to Section', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.text1)),
          ])),
        const SizedBox(height: S.sm),
        // Section list
        ...List.generate(children.length, (i) {
          final child = children[i];
          final isCurrent = i == currentIndex;
          final desc = child.isGroup ? child.group!.description : child.frame!.description;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.xs + 1),
            child: Material(
              color: isCurrent ? c.primarySurface : Colors.transparent,
              borderRadius: BorderRadius.circular(R.md),
              child: InkWell(
                borderRadius: BorderRadius.circular(R.md),
                onTap: () => onJump(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(R.md),
                    border: Border.all(color: isCurrent ? c.primary.withValues(alpha: 0.4) : c.border, width: isCurrent ? 1.5 : 1)),
                  child: Row(children: [
                    // Index badge
                    Container(width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: isCurrent ? c.primary : c.elevated,
                        borderRadius: BorderRadius.circular(R.sm)),
                      child: Center(child: Text('${i + 1}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          color: isCurrent ? Colors.white : c.hint)))),
                    const SizedBox(width: S.md),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(child.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                        color: isCurrent ? c.primary : c.text1)),
                      if (desc != null && desc.isNotEmpty) ...[const SizedBox(height: 2),
                        Text(desc, style: TextStyle(fontSize: 12, color: c.text2),
                          maxLines: 1, overflow: TextOverflow.ellipsis)],
                    ])),
                    if (isCurrent) Icon(Icons.my_location_rounded, size: 18, color: c.primary)
                    else Icon(Icons.arrow_forward_ios, size: 14, color: c.hint),
                  ]),
                ),
              ),
            ),
          );
        }),
        SizedBox(height: MediaQuery.of(context).padding.bottom + S.xl),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Step Progress Dots (tappable for direct jump)
// ═══════════════════════════════════════════════════════════════

class _StepDots extends StatelessWidget {
  final int total, current; final List<String> labels;
  final void Function(int) onTapStep;
  const _StepDots({required this.total, required this.current, required this.labels, required this.onTapStep});

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(S.xl, S.lg, S.xl, S.md), color: c.card,
      child: Column(children: [
        Row(children: List.generate(total * 2 - 1, (i) {
          if (i.isEven) {
            final si = i ~/ 2; final active = si <= current; final cur = si == current;
            return GestureDetector(
              onTap: () => onTapStep(si),
              child: Container(
                width: cur ? 32 : 24, height: cur ? 32 : 24,
                decoration: BoxDecoration(color: active ? c.primary : c.border, shape: BoxShape.circle,
                  boxShadow: cur ? [BoxShadow(color: c.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null),
                child: Center(child: active && !cur
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text('${si + 1}', style: TextStyle(fontSize: cur ? 14 : 12, fontWeight: FontWeight.w700,
                      color: active ? Colors.white : c.hint))),
              ),
            );
          }
          return Expanded(child: Container(height: 2, color: i ~/ 2 < current ? c.primary : c.border));
        })),
        const SizedBox(height: S.sm),
        Text(labels[current], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.primary)),
        Text('Step ${current + 1} of $total', style: TextStyle(fontSize: 12, color: c.hint)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Horizontal Step Bar (tappable for direct jump)
// ═══════════════════════════════════════════════════════════════

class _StepBar extends StatelessWidget {
  final int total, current; final List<String> labels;
  final void Function(int) onTapStep;
  const _StepBar({required this.total, required this.current, required this.labels, required this.onTapStep});

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    return Container(
      color: c.card, padding: const EdgeInsets.symmetric(vertical: S.md),
      child: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: S.xl), child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: (current + 1) / total, backgroundColor: c.border,
            valueColor: AlwaysStoppedAnimation<Color>(c.primary), minHeight: 4))),
        const SizedBox(height: S.sm),
        SizedBox(height: 36, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: S.lg),
          itemCount: total, separatorBuilder: (_, __) => const SizedBox(width: S.sm),
          itemBuilder: (_, i) {
            final active = i <= current; final cur = i == current;
            return GestureDetector(
              onTap: () => onTapStep(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.xs),
                decoration: BoxDecoration(
                  color: cur ? c.primary : active ? c.primarySurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(R.pill),
                  border: Border.all(color: active ? c.primary.withValues(alpha: 0.3) : c.border)),
                child: Center(child: Text(labels[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: cur ? Colors.white : active ? c.primary : c.hint))),
              ),
            );
          },
        )),
      ]),
    );
  }
}
