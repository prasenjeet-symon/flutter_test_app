// lib/dfup_selection_input.dart

import 'package:flutter/material.dart';
import 'dfup_models.dart';
import 'dfup_utils.dart';
import 'dfup_theme.dart';
import 'dfup_label_row.dart';
import 'dfup_layout_widget.dart';

// ═══════════════════════════════════════════════════════════════
// Global search helper — case-insensitive across title/subtitle/description
// ═══════════════════════════════════════════════════════════════

List<SelectionDataPointOption> _filterOptions(List<SelectionDataPointOption> opts, String query) {
  if (query.isEmpty) return opts;
  final q = query.toLowerCase();
  return opts.where((o) {
    final t = o.value.resolvedTitle.toLowerCase();
    final s = o.value.resolvedSubtitle.toLowerCase();
    final d = o.value.resolvedDescription.toLowerCase();
    final code = o.code.toLowerCase();
    return t.contains(q) || s.contains(q) || d.contains(q) || code.contains(q);
  }).toList();
}

// ═══════════════════════════════════════════════════════════════
// Reusable search bar
// ═══════════════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  const _SearchBar({required this.hint, required this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 14, color: c.text1),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.search_rounded, size: 20, color: c.hint),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
        fillColor: c.elevated,
      ),
      onChanged: onChanged,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Main Selection Widget
// ═══════════════════════════════════════════════════════════════

class DfupSelectionInput extends StatefulWidget {
  final DataPoint dataPoint;
  final Map<String, DataPoint>? registry;
  final VoidCallback onMutated;
  const DfupSelectionInput({super.key, required this.dataPoint, this.registry, required this.onMutated});
  @override
  State<DfupSelectionInput> createState() => _DfupSelectionInputState();
}

class _DfupSelectionInputState extends State<DfupSelectionInput> {
  late Set<String> _sel;
  String? _error;
  String _search = '';
  DataPoint get dp => widget.dataPoint;
  bool get isMulti => dp.type == DataPointType.multiSelect;

  @override
  void initState() {
    super.initState();
    _sel = dp.response is SelectionResponse ? (dp.response as SelectionResponse).selectedIds.toSet() : {};
  }

  List<SelectionDataPointOption> get _visibleOpts {
    final registry = widget.registry ?? {};
    return (dp.options ?? []).where((o) => DependencyEvaluator.isOptionVisible(o, registry)).toList();
  }

  bool _useSheetFor(List<SelectionDataPointOption> opts) {
    return isMulti ? opts.length > 10 : opts.length > 5;
  }

  void _toggle(SelectionDataPointOption opt) {
    setState(() {
      if (isMulti) { _sel.contains(opt.id) ? _sel.remove(opt.id) : _sel.add(opt.id); }
      else { _sel = _sel.contains(opt.id) ? {} : {opt.id}; }
    });
    _mutate();
  }

  void _mutate() {
    final selOpts = dp.options?.where((o) => _sel.contains(o.id)).toList() ?? [];
    final err = DfupValidator.validateSelection(dp, _sel.toList());
    dp.response = SelectionResponse(
      selectedIds: _sel.toList(),
      value: isMulti ? selOpts : (selOpts.isNotEmpty ? selOpts.first : null),
      status: err == null && _nestedDfupsValid() ? ResponseStatus.valid : ResponseStatus.invalid,
    );
    setState(() => _error = err);
    widget.onMutated();
  }

  bool _useCompactChipsFor(List<SelectionDataPointOption> opts) {
    if (_useSheetFor(opts)) return false;
    return opts.length <= 4 && opts.every((o) =>
      o.value.resolvedSubtitle.isEmpty && o.value.resolvedDescription.isEmpty);
  }

  // The selected option for single-select
  SelectionDataPointOption? get _selectedOpt {
    if (isMulti || _sel.isEmpty) return null;
    if (dp.options == null) return null;
    for (final o in dp.options!) {
      if (_sel.contains(o.id)) return o;
    }
    return null;
  }

  void _openNestedDfup(SelectionDataPointOption opt) {
    if (opt.value.dfup == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _NestedDfupPage(option: opt, onSaved: () { setState(() {}); _mutate(); }),
    ));
  }

  bool _nestedDfupsValid() {
    final selOpts = dp.options?.where((o) => _sel.contains(o.id)).toList() ?? [];
    for (final opt in selOpts) {
      if (!opt.value.isUserEditable || opt.value.dfup == null) continue;
      for (final p in opt.value.dfup!.collectAllDataPoints()) {
        if (p.isHidden) continue;
        final req = p.validation?.isRequired == true || p.fileValidation?.isRequired == true;
        if (req && p.response == null) return false;
        if (p.response != null) {
          final s = _responseStatus(p.response);
          if (s == ResponseStatus.invalid) return false;
        }
      }
    }
    return true;
  }

  static ResponseStatus? _responseStatus(dynamic resp) {
    if (resp is TextResponse) return resp.status;
    if (resp is NumberResponse) return resp.status;
    if (resp is BooleanResponse) return resp.status;
    if (resp is DateTimeResponse) return resp.status;
    if (resp is FileUploadResponse) return resp.status;
    if (resp is SelectionResponse) return resp.status;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    final req = dp.validation?.isRequired ?? false;
    final allOpts = _visibleOpts;
    final filteredOpts = _filterOptions(allOpts, _search);
    final useSheet = _useSheetFor(allOpts);
    final useCompactChips = _useCompactChipsFor(allOpts);

    // Auto-clear selections whose options are no longer visible
    final visibleIds = allOpts.map((o) => o.id).toSet();
    if (_sel.any((id) => !visibleIds.contains(id))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sel.removeWhere((id) => !visibleIds.contains(id));
        _mutate();
      });
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DfupLabelRow(label: dp.label, isRequired: req, info: dp.info, registry: widget.registry),
      if (isMulti) Padding(padding: const EdgeInsets.only(top: S.xs),
        child: Text('Select one or more options', style: TextStyle(fontSize: 12, color: c.hint))),
      const SizedBox(height: S.sm),

      // ── Bottom-sheet mode ──
      if (useSheet) ...[
        // Single select with selection → show selected card + change button
        if (!isMulti && _selectedOpt != null)
          _SelectedCard(opt: _selectedOpt!, onClear: () { setState(() => _sel.clear()); _mutate(); },
            onChange: () => _openSheet(),
            onEdit: _selectedOpt!.value.isUserEditable ? () => _openNestedDfup(_selectedOpt!) : null)
        else
          _sheetTrigger(c),
      ]

      // ── Inline mode ──
      else ...[
        // Single select with selection → show selected card inline
        if (!isMulti && _selectedOpt != null) ...[
          _SelectedCard(opt: _selectedOpt!, onClear: () { setState(() => _sel.clear()); _mutate(); },
            onChange: () { setState(() => _sel.clear()); _mutate(); },
            onEdit: _selectedOpt!.value.isUserEditable ? () => _openNestedDfup(_selectedOpt!) : null),
        ] else ...[
          // Search bar — always visible when ≥3 options
          if (allOpts.length >= 3) ...[
            _SearchBar(hint: 'Search ${dp.label.toLowerCase()}...', onChanged: (v) => setState(() => _search = v)),
            const SizedBox(height: S.md),
          ],
          useCompactChips ? _chips(filteredOpts, c) : _cards(filteredOpts, c),
          if (filteredOpts.isEmpty && _search.isNotEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: S.lg),
              child: Center(child: Column(children: [
                Icon(Icons.search_off_rounded, size: 36, color: c.hint),
                const SizedBox(height: S.sm),
                Text('No options match "$_search"', style: TextStyle(fontSize: 13, color: c.hint)),
              ]))),
        ],
      ],

      if (_error != null) Padding(padding: const EdgeInsets.only(top: S.sm, left: S.sm),
        child: Text(_error!, style: TextStyle(fontSize: 12, color: c.error))),
    ]);
  }

  // ── Bottom-sheet trigger ──

  Widget _sheetTrigger(Cx c) {
    final selOpts = dp.options?.where((o) => _sel.contains(o.id)).toList() ?? [];
    final hasSelection = selOpts.isNotEmpty;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => _openSheet(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md + 2),
          decoration: BoxDecoration(
            color: c.inputFill, borderRadius: BorderRadius.circular(R.md),
            border: Border.all(color: hasSelection ? c.primary.withValues(alpha: 0.5) : c.border, width: 1.5)),
          child: Row(children: [
            Icon(isMulti ? Icons.checklist_outlined : Icons.list_outlined, size: 20,
              color: hasSelection ? c.primary : c.hint),
            const SizedBox(width: S.md),
            Expanded(child: Text(
              hasSelection
                ? (isMulti ? '${selOpts.length} selected' : selOpts.first.value.resolvedTitle)
                : (isMulti ? 'Tap to select options' : 'Tap to choose'),
              style: TextStyle(fontSize: 15,
                fontWeight: hasSelection ? FontWeight.w500 : FontWeight.w400,
                color: hasSelection ? c.text1 : c.hint))),
            Icon(Icons.expand_more_rounded, size: 22, color: c.hint),
          ]),
        ),
      ),
      // Multi-select selected chips preview
      if (isMulti && selOpts.isNotEmpty) ...[
        const SizedBox(height: S.sm),
        Wrap(spacing: S.xs, runSpacing: S.xs, children: selOpts.map((o) {
          final title = o.value.resolvedTitle.isNotEmpty ? o.value.resolvedTitle : o.code;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: S.sm + 2, vertical: S.xs),
            decoration: BoxDecoration(color: c.primarySurface, borderRadius: BorderRadius.circular(R.pill),
              border: Border.all(color: c.primary.withValues(alpha: 0.3))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.primary)),
              if (o.value.isUserEditable) ...[
                const SizedBox(width: S.xs),
                GestureDetector(onTap: () => _openNestedDfup(o),
                  child: Icon(Icons.edit_outlined, size: 14, color: c.primary)),
              ],
              const SizedBox(width: S.xs),
              GestureDetector(onTap: () { _sel.remove(o.id); _mutate(); },
                child: Icon(Icons.close, size: 14, color: c.primary)),
            ]),
          );
        }).toList()),
      ],
    ]);
  }

  void _openSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => _SelectionBottomSheet(
        dataPoint: dp, isMulti: isMulti, initialSelection: Set.from(_sel),
        registry: widget.registry ?? {},
        onDone: (newSel) { _sel = newSel; _mutate(); },
        onEditOption: (opt) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _openNestedDfup(opt));
        },
      ),
    );
  }

  // ── Inline chips (compact, ≤4 simple options) ──

  Widget _chips(List<SelectionDataPointOption> opts, Cx c) => Wrap(
    spacing: S.sm, runSpacing: S.sm,
    children: opts.map((o) {
      final on = _sel.contains(o.id); final dis = o.isDisabled;
      final t = o.value.resolvedTitle.isNotEmpty ? o.value.resolvedTitle : o.code;
      return GestureDetector(
        onTap: dis ? null : () => _toggle(o),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md),
          decoration: BoxDecoration(
            color: dis ? c.elevated : on ? c.chipSelectedBg : c.chipBg,
            borderRadius: BorderRadius.circular(R.pill),
            border: Border.all(color: dis ? c.border : on ? c.primary : c.chipBorder, width: on ? 2 : 1.5),
            boxShadow: on ? [BoxShadow(color: c.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))] : null),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (isMulti) ...[Icon(on ? Icons.check_circle : Icons.circle_outlined, size: 18,
              color: on ? c.chipSelectedText : c.hint), const SizedBox(width: S.sm)],
            Text(t, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              color: dis ? c.hint : on ? c.chipSelectedText : c.text1)),
          ]),
        ),
      );
    }).toList(),
  );

  // ── Inline cards ──

  Widget _cards(List<SelectionDataPointOption> opts, Cx c) => Column(
    children: opts.map((o) {
      final on = _sel.contains(o.id); final dis = o.isDisabled;
      final ct = o.value;
      final rTitle = ct.resolvedTitle.isNotEmpty ? ct.resolvedTitle : o.code;
      final rSub = ct.resolvedSubtitle;
      final rDesc = ct.resolvedDescription;
      return Padding(padding: const EdgeInsets.only(bottom: S.sm), child: GestureDetector(
        onTap: dis ? null : () => _toggle(o),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(S.lg),
          decoration: BoxDecoration(
            color: dis ? c.elevated : on ? c.primarySurface : c.card,
            borderRadius: BorderRadius.circular(R.md),
            border: Border.all(color: dis ? c.border : on ? c.primary : c.border, width: on ? 2 : 1.5),
            boxShadow: on ? [BoxShadow(color: c.primary.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))] : null),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _indicator(on, c),
            const SizedBox(width: S.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rTitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: dis ? c.hint : c.text1)),
              if (rSub.isNotEmpty) ...[const SizedBox(height: 2),
                Text(rSub, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: dis ? c.hint : c.text2))],
              if (rDesc.isNotEmpty) ...[const SizedBox(height: S.xs),
                Text(rDesc, style: TextStyle(fontSize: 12, color: c.hint, height: 1.4))],
            ])),
            if (on && o.value.isUserEditable) GestureDetector(
              onTap: () => _openNestedDfup(o),
              child: Padding(padding: const EdgeInsets.only(right: S.sm),
                child: Icon(Icons.edit_outlined, size: 20, color: c.primary))),
            if (on) Icon(Icons.check_circle, size: 22, color: c.primary),
          ]),
        ),
      ));
    }).toList(),
  );

  Widget _indicator(bool on, Cx c) {
    if (isMulti) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200), width: 22, height: 22,
        decoration: BoxDecoration(color: on ? c.primary : Colors.transparent, borderRadius: BorderRadius.circular(6),
          border: Border.all(color: on ? c.primary : c.hint, width: 2)),
        child: on ? const Icon(Icons.check, size: 16, color: Colors.white) : null);
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200), width: 22, height: 22,
      decoration: BoxDecoration(color: on ? c.primary : Colors.transparent, shape: BoxShape.circle,
        border: Border.all(color: on ? c.primary : c.hint, width: 2)),
      child: on ? const Center(child: CircleAvatar(radius: 5, backgroundColor: Colors.white)) : null);
  }
}

// ═══════════════════════════════════════════════════════════════
// Selected Option Card (single-select: replaces trigger inline)
// ═══════════════════════════════════════════════════════════════

class _SelectedCard extends StatelessWidget {
  final SelectionDataPointOption opt;
  final VoidCallback onClear;
  final VoidCallback onChange;
  final VoidCallback? onEdit;
  const _SelectedCard({required this.opt, required this.onClear, required this.onChange, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    final ct = opt.value;
    final rTitle = ct.resolvedTitle.isNotEmpty ? ct.resolvedTitle : opt.code;
    final rSub = ct.resolvedSubtitle;
    final rDesc = ct.resolvedDescription;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(S.lg),
      decoration: BoxDecoration(
        color: c.primarySurface,
        borderRadius: BorderRadius.circular(R.md),
        border: Border.all(color: c.primary, width: 2),
        boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Check badge
          Container(width: 28, height: 28,
            decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 18, color: Colors.white)),
          const SizedBox(width: S.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.text1)),
            if (rSub.isNotEmpty) ...[const SizedBox(height: 2),
              Text(rSub, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.text2))],
            if (rDesc.isNotEmpty) ...[const SizedBox(height: S.xs),
              Text(rDesc, style: TextStyle(fontSize: 12, color: c.hint, height: 1.4))],
          ])),
        ]),
        const SizedBox(height: S.md),
        // Action row
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.xs + 2),
              decoration: BoxDecoration(color: c.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(R.pill)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.close, size: 14, color: c.error),
                const SizedBox(width: S.xs),
                Text('Clear', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.error)),
              ]),
            ),
          ),
          const SizedBox(width: S.sm),
          if (onEdit != null) ...[
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.xs + 2),
                decoration: BoxDecoration(color: c.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(R.pill)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.edit_outlined, size: 14, color: c.accent),
                  const SizedBox(width: S.xs),
                  Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.accent)),
                ]),
              ),
            ),
            const SizedBox(width: S.sm),
          ],
          GestureDetector(
            onTap: onChange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.xs + 2),
              decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(R.pill)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.white),
                const SizedBox(width: S.xs),
                const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Bottom Sheet — with built-in search
// ═══════════════════════════════════════════════════════════════

class _SelectionBottomSheet extends StatefulWidget {
  final DataPoint dataPoint;
  final bool isMulti;
  final Set<String> initialSelection;
  final Map<String, DataPoint> registry;
  final void Function(Set<String>) onDone;
  final void Function(SelectionDataPointOption)? onEditOption;

  const _SelectionBottomSheet({
    required this.dataPoint, required this.isMulti,
    required this.initialSelection, required this.registry, required this.onDone,
    this.onEditOption,
  });

  @override
  State<_SelectionBottomSheet> createState() => _SelectionBottomSheetState();
}

class _SelectionBottomSheetState extends State<_SelectionBottomSheet> {
  late Set<String> _sel;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _sel = Set.from(widget.initialSelection); }
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<SelectionDataPointOption> get _opts {
    final visible = (widget.dataPoint.options ?? []).where((o) => DependencyEvaluator.isOptionVisible(o, widget.registry)).toList();
    return _filterOptions(visible, _search);
  }

  void _toggle(SelectionDataPointOption opt) {
    setState(() {
      if (widget.isMulti) {
        _sel.contains(opt.id) ? _sel.remove(opt.id) : _sel.add(opt.id);
      } else {
        _sel = _sel.contains(opt.id) ? {} : {opt.id};
        widget.onDone(_sel);
        Navigator.pop(context);
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    final opts = _opts;
    final total = (widget.dataPoint.options ?? []).where((o) => DependencyEvaluator.isOptionVisible(o, widget.registry)).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.6, minChildSize: 0.35, maxChildSize: 0.9,
      builder: (ctx, sc) => Container(
        decoration: BoxDecoration(color: c.sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(R.xl)),
          boxShadow: c.elevatedShadow),
        child: Column(children: [
          // Handle
          Container(margin: const EdgeInsets.only(top: S.md), width: 40, height: 4,
            decoration: BoxDecoration(color: c.hint.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),

          // Header
          Padding(padding: const EdgeInsets.fromLTRB(S.xl, S.lg, S.lg, S.sm),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.dataPoint.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.text1)),
                const SizedBox(height: 2),
                Text(widget.isMulti ? '${_sel.length} of $total selected' : 'Choose one option',
                  style: TextStyle(fontSize: 13, color: c.text2)),
              ])),
              if (widget.isMulti) TextButton(
                onPressed: () { widget.onDone(_sel); Navigator.pop(context); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.sm),
                  decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(R.pill)),
                  child: Text('Done', style: TextStyle(color: c.onPrimary, fontWeight: FontWeight.w700, fontSize: 14))),
              ),
            ]),
          ),

          // Search — always visible
          Padding(padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.sm),
            child: _SearchBar(controller: _searchCtrl,
              hint: 'Search ${widget.dataPoint.label.toLowerCase()}...',
              onChanged: (v) => setState(() => _search = v))),

          // No results
          if (opts.isEmpty && _search.isNotEmpty)
            Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.search_off_rounded, size: 48, color: c.hint),
              const SizedBox(height: S.md),
              Text('No options match "$_search"', style: TextStyle(fontSize: 14, color: c.hint)),
            ])))
          else
          // Options list
          Expanded(child: ListView.builder(
            controller: sc, padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.sm),
            itemCount: opts.length,
            itemBuilder: (_, i) {
              final o = opts[i]; final on = _sel.contains(o.id); final dis = o.isDisabled;
              final rTitle = o.value.resolvedTitle.isNotEmpty ? o.value.resolvedTitle : o.code;
              final rSub = o.value.resolvedSubtitle;
              final rDesc = o.value.resolvedDescription;

              return Padding(padding: const EdgeInsets.only(bottom: S.sm), child: GestureDetector(
                onTap: dis ? null : () => _toggle(o),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md),
                  decoration: BoxDecoration(
                    color: dis ? c.elevated : on ? c.primarySurface : c.card,
                    borderRadius: BorderRadius.circular(R.md),
                    border: Border.all(color: dis ? c.border : on ? c.primary : c.border, width: on ? 2 : 1)),
                  child: Row(children: [
                    if (widget.isMulti)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180), width: 20, height: 20,
                        margin: const EdgeInsets.only(right: S.md),
                        decoration: BoxDecoration(color: on ? c.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: on ? c.primary : c.hint, width: 2)),
                        child: on ? const Icon(Icons.check, size: 14, color: Colors.white) : null)
                    else
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180), width: 20, height: 20,
                        margin: const EdgeInsets.only(right: S.md),
                        decoration: BoxDecoration(color: on ? c.primary : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: on ? c.primary : c.hint, width: 2)),
                        child: on ? const Center(child: CircleAvatar(radius: 4, backgroundColor: Colors.white)) : null),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(rTitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: dis ? c.hint : c.text1)),
                      if (rSub.isNotEmpty) Text(rSub, style: TextStyle(fontSize: 12, color: dis ? c.hint : c.text2)),
                      if (rDesc.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2),
                        child: Text(rDesc, style: TextStyle(fontSize: 11, color: c.hint), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    ])),
                    if (on && o.value.isUserEditable) Padding(
                      padding: const EdgeInsets.only(right: S.sm),
                      child: GestureDetector(
                        onTap: () {
                          widget.onDone(_sel);
                          Navigator.pop(context);
                          widget.onEditOption?.call(o);
                        },
                        child: Icon(Icons.edit_outlined, size: 18, color: c.primary))),
                    if (on) Icon(Icons.check_circle, size: 20, color: c.primary),
                  ]),
                ),
              ));
            },
          )),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Nested DFUP Full-Screen Popover (Section 5.8)
// ═══════════════════════════════════════════════════════════════

class _NestedDfupPage extends StatelessWidget {
  final SelectionDataPointOption option;
  final VoidCallback onSaved;
  const _NestedDfupPage({required this.option, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    final ct = option.value;
    final rTitle = ct.resolvedTitle.isNotEmpty ? ct.resolvedTitle : option.code;

    return Scaffold(
      appBar: AppBar(
        title: Text(rTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () { onSaved(); Navigator.pop(context); },
        ),
      ),
      body: DfupLayoutWidget(
        layout: ct.dfup!,
        submitLabel: 'Save & Close',
        onSubmit: () { onSaved(); Navigator.pop(context); },
      ),
    );
  }
}
