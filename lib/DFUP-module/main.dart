// lib/main.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dfup_models.dart';
import 'dfup_layout_widget.dart';
import 'dfup_theme.dart';

void main() => runApp(const DfupApp());

class DfupApp extends StatefulWidget {
  const DfupApp({super.key});
  @override
  State<DfupApp> createState() => _DfupAppState();
  static _DfupAppState of(BuildContext context) => context.findAncestorStateOfType<_DfupAppState>()!;
}

class _DfupAppState extends State<DfupApp> {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  void toggleTheme() => setState(() => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  void setTheme(ThemeMode m) => setState(() => _mode = m);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DFUP Renderer', debugShowCheckedModeBanner: false,
    theme: DfupTheme.light, darkTheme: DfupTheme.dark, themeMode: _mode,
    home: const _Home(),
  );
}

// ── Home ─────────────────────────────────────────────────────

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    final app = DfupApp.of(context);
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(S.xl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: S.lg),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _ThemeBtn(icon: Icons.light_mode_outlined, label: 'Light', active: app.mode == ThemeMode.light, onTap: () => app.setTheme(ThemeMode.light)),
            const SizedBox(width: S.sm),
            _ThemeBtn(icon: Icons.dark_mode_outlined, label: 'Dark', active: app.mode == ThemeMode.dark, onTap: () => app.setTheme(ThemeMode.dark)),
            const SizedBox(width: S.sm),
            _ThemeBtn(icon: Icons.settings_brightness_outlined, label: 'Auto', active: app.mode == ThemeMode.system, onTap: () => app.setTheme(ThemeMode.system)),
          ]),
          const SizedBox(height: S.xl),
          Container(
            padding: const EdgeInsets.all(S.xxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.primary, c.primary.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(R.xl),
              boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.xs),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(R.pill)),
                child: const Text('DFUP 3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5))),
              const SizedBox(height: S.lg),
              const Text('Data Frame\nUI Protocol', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
              const SizedBox(height: S.sm),
              Text('Mutation-Based Dynamic UI Schema Renderer', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
            ]),
          ),
          const SizedBox(height: S.xxl),
          Text('Choose a Layout Strategy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.text1)),
          const SizedBox(height: S.lg),
          _Opt(icon: Icons.view_stream_outlined, title: 'Scroll Layout', sub: 'All sections visible', type: 'scroll'),
          _Opt(icon: Icons.view_carousel_outlined, title: 'Vertical Stepper', sub: 'Step-by-step progress dots', type: 'vertical_step'),
          _Opt(icon: Icons.linear_scale_outlined, title: 'Horizontal Stepper', sub: 'Linear progress with chips', type: 'horizontal_step'),
          _Opt(icon: Icons.tab_outlined, title: 'Tab Layout', sub: 'Tabbed navigation', type: 'tab'),
          const SizedBox(height: S.xxl),
          Text('Custom JSON', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.text1)),
          const SizedBox(height: S.lg),
          _Opt(icon: Icons.code_outlined, title: 'Load from JSON', sub: 'Paste your own DFUP JSON', type: 'custom'),
        ]),
      )),
    );
  }
}

class _ThemeBtn extends StatelessWidget {
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  const _ThemeBtn({required this.icon, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
      decoration: BoxDecoration(color: active ? c.primarySurface : Colors.transparent, borderRadius: BorderRadius.circular(R.pill),
        border: Border.all(color: active ? c.primary : c.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: active ? c.primary : c.hint),
        const SizedBox(width: S.xs),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? c.primary : c.hint)),
      ]),
    ));
  }
}

class _Opt extends StatelessWidget {
  final IconData icon; final String title, sub, type;
  const _Opt({required this.icon, required this.title, required this.sub, required this.type});
  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    return Padding(padding: const EdgeInsets.only(bottom: S.md), child: Material(
      color: c.card, borderRadius: BorderRadius.circular(R.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(R.lg),
        onTap: () {
          if (type == 'custom') { Navigator.push(context, MaterialPageRoute(builder: (_) => const _JsonPage())); return; }
          final layout = Layout.fromJson(_demoJson(type));
          Navigator.push(context, MaterialPageRoute(builder: (_) => _FormPage(layout: layout, title: title)));
        },
        child: Container(
          padding: const EdgeInsets.all(S.lg),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(R.lg), border: Border.all(color: c.border, width: 1)),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: c.primarySurface, borderRadius: BorderRadius.circular(R.md)),
              child: Icon(icon, color: c.primary, size: 24)),
            const SizedBox(width: S.lg),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.text1)),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(fontSize: 13, color: c.text2)),
            ])),
            Icon(Icons.arrow_forward_ios, size: 16, color: c.hint),
          ]),
        ),
      ),
    ));
  }
}

// ── Form Page ────────────────────────────────────────────────

class _FormPage extends StatelessWidget {
  final Layout layout; final String title;
  const _FormPage({required this.layout, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: [
      IconButton(
        icon: Icon(Cx.of(context).isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 22),
        tooltip: 'Toggle theme', onPressed: () => DfupApp.of(context).toggleTheme()),
      IconButton(icon: const Icon(Icons.data_object, size: 22), tooltip: 'View JSON',
        onPressed: () {
          final out = const JsonEncoder.withIndent('  ').convert(layout.toJson());
          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
            builder: (_) => _JsonSheet(json: out));
        }),
    ]),
    body: DfupLayoutWidget(layout: layout, onSubmit: () {
      debugPrint(const JsonEncoder.withIndent('  ').convert(layout.toJson()));
    }),
  );
}

// ── JSON Input Page ──────────────────────────────────────────

class _JsonPage extends StatefulWidget {
  const _JsonPage();
  @override
  State<_JsonPage> createState() => _JsonPageState();
}

class _JsonPageState extends State<_JsonPage> {
  final _ctrl = TextEditingController();
  String? _err;
  String? _pickedFileName;
  bool _isPicking = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _pickFile() async {
    setState(() { _isPicking = true; _err = null; });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _isPicking = false);
        return;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        setState(() { _isPicking = false; _err = 'Could not read file data.'; });
        return;
      }
      final content = utf8.decode(bytes);
      setState(() {
        _ctrl.text = content;
        _pickedFileName = file.name;
        _isPicking = false;
        _err = null;
      });
    } catch (e) {
      setState(() { _isPicking = false; _err = 'Failed to pick file: $e'; });
    }
  }

  void _load() {
    try {
      final parsed = jsonDecode(_ctrl.text) as Map<String, dynamic>;
      final layout = Layout.fromJson(parsed);
      Navigator.push(context, MaterialPageRoute(builder: (_) => _FormPage(layout: layout, title: layout.title ?? 'Custom Form')));
    } catch (e) { setState(() => _err = 'Invalid JSON: $e'); }
  }

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Load Custom JSON')),
      body: Padding(
        padding: const EdgeInsets.all(S.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ── Upload button row ────────────────────────────────
          OutlinedButton.icon(
            onPressed: _isPicking ? null : _pickFile,
            icon: _isPicking
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))
                : Icon(Icons.upload_file_outlined, color: c.primary),
            label: Text(_isPicking ? 'Picking file…' : 'Upload JSON File',
                style: TextStyle(color: c.primary, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: S.md),
              side: BorderSide(color: c.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.md)),
            ),
          ),
          // ── Picked filename chip ─────────────────────────────
          if (_pickedFileName != null) ...[
            const SizedBox(height: S.sm),
            Row(children: [
              Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade600),
              const SizedBox(width: S.xs),
              Expanded(child: Text(_pickedFileName!, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500))),
              GestureDetector(
                onTap: () => setState(() { _ctrl.clear(); _pickedFileName = null; _err = null; }),
                child: Icon(Icons.close, size: 16, color: c.hint),
              ),
            ]),
          ],
          const SizedBox(height: S.md),
          // ── Divider with label ───────────────────────────────
          Row(children: [
            Expanded(child: Divider(color: c.border)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: S.sm),
                child: Text('or paste JSON', style: TextStyle(fontSize: 12, color: c.hint))),
            Expanded(child: Divider(color: c.border)),
          ]),
          const SizedBox(height: S.md),
          Text('Paste your DFUP JSON document below:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.text1)),
          const SizedBox(height: S.md),
          // ── JSON text area ───────────────────────────────────
          Expanded(child: TextField(
            controller: _ctrl, maxLines: null, expands: true,
            textAlignVertical: TextAlignVertical.top,
            onChanged: (_) => setState(() { _err = null; _pickedFileName = null; }),
            style: TextStyle(fontSize: 13, fontFamily: 'monospace', color: c.text1),
            decoration: InputDecoration(
              hintText: '{\n  "id": "...",\n  ...\n}',
              errorText: _err,
            ),
          )),
          const SizedBox(height: S.lg),
          // ── Render button ────────────────────────────────────
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: S.lg)),
            child: const Text('Render Form'),
          ),
        ]),
      ),
    );
  }
}

// ── JSON Viewer Sheet ────────────────────────────────────────

class _JsonSheet extends StatelessWidget {
  final String json;
  const _JsonSheet({required this.json});
  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7, minChildSize: 0.3, maxChildSize: 0.95,
      builder: (ctx, sc) => Container(
        decoration: BoxDecoration(color: c.isDark ? const Color(0xFF12121F) : const Color(0xFF1E1E2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(R.xl))),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: S.md), width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.all(S.lg), child: Row(children: [
            const Text('Mutated DFUP Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(ctx)),
          ])),
          Expanded(child: SingleChildScrollView(controller: sc,
            padding: const EdgeInsets.fromLTRB(S.lg, 0, S.lg, S.xxl),
            child: SelectableText(json, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF89DDFF), height: 1.5)))),
        ]),
      ),
    );
  }
}

// ── Demo JSON Builder ────────────────────────────────────────

Map<String, dynamic> _opt(String id, String code,
    {required String titleDpId, required String titleDefault,
     required String subDpId, required String subDefault,
     String? description, bool disabled = false,
     Map<String, dynamic>? dependency}) {
  return {
    "id": id, "code": code, "component_type": "selection_option", "is_disabled": disabled,
    if (dependency != null) "dependency": dependency,
    "value": {
      "title": "{{$titleDpId}}", "subtitle": "{{$subDpId}}",
      if (description != null) "description": description,
      "DFUP": {
        "id": "dfup_$id", "code": "DFUP_$code", "component_type": "layout", "layout_type": "scroll",
        "children": [{"id": "frame_$id", "code": "FRAME_$code", "component_type": "data_frame",
          "title": "", "allow_multiples": false,
          "points": [
            {"id": titleDpId, "code": "${code}_TITLE", "component_type": "data_point", "type": "text", "label": "Title", "default_value": titleDefault,
             "response": {"data_type": "text", "value": titleDefault, "status": "valid", "timestamp": "2026-02-12T00:00:00Z"}},
            {"id": subDpId, "code": "${code}_SUBTITLE", "component_type": "data_point", "type": "text", "label": "Subtitle", "default_value": subDefault,
             "response": {"data_type": "text", "value": subDefault, "status": "valid", "timestamp": "2026-02-12T00:00:00Z"}},
          ]}]
      }
    }
  };
}

Map<String, dynamic> _demoJson(String layoutType) => {
  "id": "layout_001", "code": "DEMO_FORM", "component_type": "layout",
  "layout_type": layoutType, "title": "Application Form",
  "children": [
    // ── 1. Personal Details ──
    {
      "id": "grp_personal", "code": "PERSONAL_DETAILS", "component_type": "data_frame_group",
      "title": "Personal Details (v{{dp_form_version}})", "description": "Tell us about yourself",
      "frames": [{
        "id": "frame_basic", "code": "BASIC_INFO", "component_type": "data_frame",
        "title": "Basic Information", "allow_multiples": false,
        "points": [
          // Hidden data point — never rendered, used for interpolation in group title
          {"id": "dp_form_version", "code": "FORM_VERSION", "component_type": "data_point", "type": "text",
            "label": "Form Version", "is_hidden": true,
            "response": {"data_type": "text", "value": "3.1", "status": "valid", "timestamp": "2026-03-01T00:00:00Z"}},
          // Hidden data point as dependency target — controls visibility of admin-only field
          {"id": "dp_access_level", "code": "ACCESS_LEVEL", "component_type": "data_point", "type": "text",
            "label": "Access Level", "is_hidden": true,
            "response": {"data_type": "text", "value": "admin", "status": "valid", "timestamp": "2026-03-01T00:00:00Z"}},
          {"id": "dp_fullname", "code": "FULL_NAME", "component_type": "data_point", "type": "text",
            "label": "Full Name", "placeholder": "John Doe",
            "validation": {"is_required": true, "min_length": 2, "max_length": 100}},
          {"id": "dp_email", "code": "EMAIL", "component_type": "data_point", "type": "email",
            "label": "Email Address", "placeholder": "john@example.com", "is_searchable": true,
            "validation": {"is_required": true}},
          {"id": "dp_phone", "code": "PHONE", "component_type": "data_point", "type": "phone",
            "label": "Phone Number", "placeholder": "+1 (555) 123-4567", "info": "We'll use this to reach {{FULL_NAME}}"},
          {"id": "dp_dob", "code": "DOB", "component_type": "data_point", "type": "date",
            "label": "Date of Birth", "validation": {"is_required": true}},
          // Inline single-select ≤5 — shows selected card UI
          {
            "id": "dp_gender", "code": "GENDER", "component_type": "data_point",
            "type": "single_select", "label": "Gender",
            "validation": {"is_required": true},
            "options": [
              _opt("opt_male", "MALE", titleDpId: "dp_m_t", titleDefault: "Male", subDpId: "dp_m_s", subDefault: "He/Him"),
              _opt("opt_female", "FEMALE", titleDpId: "dp_f_t", titleDefault: "Female", subDpId: "dp_f_s", subDefault: "She/Her"),
              _opt("opt_nonbin", "NON_BINARY", titleDpId: "dp_nb_t", titleDefault: "Non-Binary", subDpId: "dp_nb_s", subDefault: "They/Them"),
              _opt("opt_other_g", "OTHER_G", titleDpId: "dp_og_t", titleDefault: "Other", subDpId: "dp_og_s", subDefault: "Prefer to specify"),
              _opt("opt_pnts", "PNTS", titleDpId: "dp_pn_t", titleDefault: "Prefer not to say", subDpId: "dp_pn_s", subDefault: ""),
            ]
          },
          // ── Visibility: IN on single_select ── gender = "Other" → show specify field
          {"id": "dp_gender_other", "code": "GENDER_OTHER", "component_type": "data_point", "type": "text",
            "label": "Please Specify Gender", "placeholder": "Enter your gender identity",
            "validation": {"is_required": true},
            "dependency": {"target_id": "dp_gender", "operator": "IN", "comparison_value": ["opt_other_g"]}},
          {"id": "dp_bio", "code": "BIO", "component_type": "data_point", "type": "multiline",
            "label": "Short Bio", "placeholder": "Tell us about yourself...", "validation": {"max_length": 500}},
          // ── time type ──
          {"id": "dp_contact_time", "code": "CONTACT_TIME", "component_type": "data_point", "type": "time",
            "label": "Preferred Contact Time", "placeholder": "Select a time"},
          // ── regex_pattern validation ──
          {"id": "dp_linkedin", "code": "LINKEDIN", "component_type": "data_point", "type": "text",
            "label": "LinkedIn Profile URL", "placeholder": "https://linkedin.com/in/...",
            "validation": {"regex_pattern": "^https?://(www\\.)?linkedin\\.com/in/.+", "error_message": "Enter a valid LinkedIn URL"}},
          // ── Hidden data point as dependency target ── visible only when access_level = "admin"
          {"id": "dp_admin_notes", "code": "ADMIN_NOTES", "component_type": "data_point", "type": "multiline",
            "label": "Admin Notes (hidden-field driven)", "placeholder": "Only visible because access_level = admin",
            "info": "This field depends on a hidden data point",
            "dependency": {"target_id": "dp_access_level", "operator": "=", "comparison_value": "admin"}},
        ]
      }]
    },

    // ── 2. Preferences — single_select 7 opts (>5 → sheet), multi_select 12 opts (>10 → sheet) ──
    {
      "id": "grp_prefs", "code": "PREFERENCES", "component_type": "data_frame_group",
      "title": "Preferences for {{FULL_NAME}}", "description": "Customize your experience, {{FULL_NAME}}",
      "frames": [{
        "id": "frame_prefs", "code": "PREF_OPTIONS", "component_type": "data_frame",
        "title": "Options", "allow_multiples": false,
        "points": [
          // ── Per-option cascade: Department → Role ──
          // 4 options → inline cards
          {
            "id": "dp_department", "code": "DEPARTMENT", "component_type": "data_point",
            "type": "single_select", "label": "Department",
            "is_filterable": true,
            "validation": {"is_required": true},
            "options": [
              _opt("opt_dept_eng", "DEPT_ENG", titleDpId: "dp_de_t", titleDefault: "Engineering", subDpId: "dp_de_s", subDefault: "Build products"),
              _opt("opt_dept_design", "DEPT_DESIGN", titleDpId: "dp_dd_t", titleDefault: "Design", subDpId: "dp_dd_s", subDefault: "Craft experiences"),
              _opt("opt_dept_mkt", "DEPT_MKT", titleDpId: "dp_dm_t", titleDefault: "Marketing", subDpId: "dp_dm_s", subDefault: "Grow the brand"),
              _opt("opt_dept_sales", "DEPT_SALES", titleDpId: "dp_ds_t", titleDefault: "Sales", subDpId: "dp_ds_s", subDefault: "Close deals",
                disabled: true, description: "Currently not hiring"),
            ]
          },
          // 7 options with per-option deps → role list cascades based on department
          {
            "id": "dp_role", "code": "ROLE", "component_type": "data_point",
            "type": "single_select", "label": "Primary Role",
            "is_searchable": true,
            "validation": {"is_required": true},
            "dependency": {"target_id": "dp_department", "operator": "!=", "comparison_value": ""},
            "options": [
              // Engineering-only roles
              _opt("opt_dev", "DEVELOPER", titleDpId: "dp_dev_t", titleDefault: "Developer", subDpId: "dp_dev_s", subDefault: "Build & ship code", description: "Software engineers building products",
                dependency: {"target_id": "dp_department", "operator": "IN", "comparison_value": ["opt_dept_eng"]}),
              _opt("opt_qa", "QA", titleDpId: "dp_qa_t", titleDefault: "QA Engineer", subDpId: "dp_qa_s", subDefault: "Ensure quality", description: "Testing & quality assurance",
                dependency: {"target_id": "dp_department", "operator": "IN", "comparison_value": ["opt_dept_eng"]}),
              _opt("opt_devops", "DEVOPS", titleDpId: "dp_do_t", titleDefault: "DevOps", subDpId: "dp_do_s", subDefault: "Infrastructure & CI/CD", description: "Platform & operations",
                dependency: {"target_id": "dp_department", "operator": "IN", "comparison_value": ["opt_dept_eng"]}),
              // Design-only role
              _opt("opt_design", "DESIGNER", titleDpId: "dp_des_t", titleDefault: "Designer", subDpId: "dp_des_s", subDefault: "Craft visual experiences", description: "UX/UI design professionals",
                dependency: {"target_id": "dp_department", "operator": "IN", "comparison_value": ["opt_dept_design"]}),
              // Engineering + Marketing (multi-department)
              _opt("opt_data", "DATA", titleDpId: "dp_da_t", titleDefault: "Data Scientist", subDpId: "dp_da_s", subDefault: "ML & analytics", description: "Machine learning & data analysis",
                dependency: {"target_id": "dp_department", "operator": "IN", "comparison_value": ["opt_dept_eng", "opt_dept_mkt"]}),
              // Per-option compound AND: Engineering dept AND experience > 5
              _opt("opt_architect", "ARCHITECT", titleDpId: "dp_ar_t", titleDefault: "Architect", subDpId: "dp_ar_s", subDefault: "System design & leadership", description: "Senior technical leadership role",
                dependency: {"mode": "AND", "conditions": [
                  {"target_id": "dp_department", "operator": "IN", "comparison_value": ["opt_dept_eng"]},
                  {"target_id": "dp_experience", "operator": ">", "comparison_value": 5}
                ]}),
              // Available in all departments (no per-option dep)
              _opt("opt_pm", "PM", titleDpId: "dp_pm_t", titleDefault: "Product Manager", subDpId: "dp_pm_s", subDefault: "Drive product strategy", description: "Product leadership & roadmaps"),
              _opt("opt_other", "OTHER", titleDpId: "dp_ot_t", titleDefault: "Other", subDpId: "dp_ot_s", subDefault: "Something else", description: "Any other role not listed"),
            ]
          },
          // ── Visibility: = on single_select ── role = Developer → show preferred language
          {"id": "dp_dev_lang", "code": "DEV_LANG", "component_type": "data_point", "type": "text",
            "label": "Preferred Programming Language", "placeholder": "e.g. Dart, Python, Rust...",
            "dependency": {"target_id": "dp_role", "operator": "=", "comparison_value": "opt_dev"}},
          {"id": "dp_experience", "code": "EXPERIENCE", "component_type": "data_point",
            "type": "slider", "label": "Years of Experience", "validation": {"min_value": 0, "max_value": 30}},
          // ── Visibility: > numeric (slider) ── experience > 10 → show senior detail
          {"id": "dp_exp_detail", "code": "EXP_DETAIL", "component_type": "data_point", "type": "multiline",
            "label": "Describe Your Senior Experience", "placeholder": "Share key achievements...",
            "dependency": {"target_id": "dp_experience", "operator": ">", "comparison_value": 10}},
          // ── Visibility: <= numeric ── experience ≤ 2 → show beginner tips
          {"id": "dp_beginner_tips", "code": "BEGINNER_TIPS", "component_type": "data_point", "type": "text",
            "label": "Tip: Check our onboarding guide!", "placeholder": "We'll help you get started",
            "dependency": {"target_id": "dp_experience", "operator": "<=", "comparison_value": 2}},
          // ── Compound AND: visible only when department is set AND experience > 5 ──
          {"id": "dp_senior_dept_note", "code": "SENIOR_DEPT_NOTE", "component_type": "data_point", "type": "text",
            "label": "Senior Role Notes", "placeholder": "Describe your leadership style...",
            "dependency": {"mode": "AND", "conditions": [
              {"target_id": "dp_department", "operator": "!=", "comparison_value": ""},
              {"target_id": "dp_experience", "operator": ">", "comparison_value": 5}
            ]}},
          // ── Compound OR: visible when experience > 20 OR rating >= 5 ──
          {"id": "dp_vip_note", "code": "VIP_NOTE", "component_type": "data_point", "type": "text",
            "label": "VIP Candidate Note", "placeholder": "You've been flagged as VIP...",
            "info": "Visible when experience > 20 OR rating >= 5",
            "dependency": {"mode": "OR", "conditions": [
              {"target_id": "dp_experience", "operator": ">", "comparison_value": 20},
              {"target_id": "dp_rating", "operator": ">=", "comparison_value": 5}
            ]}},
          // ── number type with numeric dependency ──
          {"id": "dp_salary", "code": "SALARY", "component_type": "data_point", "type": "number",
            "label": "Expected Salary (K)", "placeholder": "e.g. 120",
            "validation": {"min_value": 0, "max_value": 999},
            "dependency": {"target_id": "dp_experience", "operator": ">", "comparison_value": 0}},
          // 13 options → bottom sheet with search
          {
            "id": "dp_skills", "code": "SKILLS", "component_type": "data_point",
            "type": "multi_select", "label": "Key Skills",
            "is_searchable": true,
            "validation": {"is_required": true},
            "options": [
              _opt("sk_flutter", "FLUTTER", titleDpId: "dp_sk_fl_t", titleDefault: "Flutter", subDpId: "dp_sk_fl_s", subDefault: "Cross-platform UI", description: "Dart-based mobile & web framework"),
              _opt("sk_dart", "DART", titleDpId: "dp_sk_da_t", titleDefault: "Dart", subDpId: "dp_sk_da_s", subDefault: "Flutter's language", description: "Modern language for Flutter apps"),
              _opt("sk_react", "REACT", titleDpId: "dp_sk_re_t", titleDefault: "React", subDpId: "dp_sk_re_s", subDefault: "Web frontend", description: "JavaScript UI library by Meta"),
              _opt("sk_python", "PYTHON", titleDpId: "dp_sk_py_t", titleDefault: "Python", subDpId: "dp_sk_py_s", subDefault: "Backend & ML", description: "Versatile scripting language"),
              _opt("sk_figma", "FIGMA", titleDpId: "dp_sk_fi_t", titleDefault: "Figma", subDpId: "dp_sk_fi_s", subDefault: "Design tool", description: "Collaborative design platform"),
              _opt("sk_swift", "SWIFT", titleDpId: "dp_sk_sw_t", titleDefault: "Swift", subDpId: "dp_sk_sw_s", subDefault: "iOS native", description: "Apple's programming language"),
              _opt("sk_kotlin", "KOTLIN", titleDpId: "dp_sk_kt_t", titleDefault: "Kotlin", subDpId: "dp_sk_kt_s", subDefault: "Android native", description: "JetBrains language for Android"),
              _opt("sk_rust", "RUST", titleDpId: "dp_sk_rs_t", titleDefault: "Rust", subDpId: "dp_sk_rs_s", subDefault: "Systems programming", description: "Memory-safe systems language"),
              _opt("sk_go", "GO", titleDpId: "dp_sk_go_t", titleDefault: "Go", subDpId: "dp_sk_go_s", subDefault: "Cloud services", description: "Google's concurrent language"),
              _opt("sk_docker", "DOCKER", titleDpId: "dp_sk_dk_t", titleDefault: "Docker", subDpId: "dp_sk_dk_s", subDefault: "Containerization", description: "Container runtime & tooling"),
              _opt("sk_k8s", "K8S", titleDpId: "dp_sk_k8_t", titleDefault: "Kubernetes", subDpId: "dp_sk_k8_s", subDefault: "Orchestration", description: "Container orchestration platform"),
              _opt("sk_aws", "AWS", titleDpId: "dp_sk_aw_t", titleDefault: "AWS", subDpId: "dp_sk_aw_s", subDefault: "Cloud platform", description: "Amazon Web Services ecosystem"),
              _opt("sk_sql", "SQL", titleDpId: "dp_sk_sq_t", titleDefault: "SQL", subDpId: "dp_sk_sq_s", subDefault: "Database queries", description: "Structured Query Language"),
            ]
          },
          // ── Visibility: ALL on multi_select ── skills include BOTH Flutter AND Dart → show proficiency
          {
            "id": "dp_flutter_dart_level", "code": "FLUTTER_DART_LEVEL", "component_type": "data_point",
            "type": "single_select", "label": "Flutter+Dart Proficiency",
            "options": [
              _opt("opt_fdl_beg", "FDL_BEGINNER", titleDpId: "dp_fdl_b_t", titleDefault: "Beginner", subDpId: "dp_fdl_b_s", subDefault: "< 1 year"),
              _opt("opt_fdl_int", "FDL_INTERMEDIATE", titleDpId: "dp_fdl_i_t", titleDefault: "Intermediate", subDpId: "dp_fdl_i_s", subDefault: "1-3 years"),
              _opt("opt_fdl_exp", "FDL_EXPERT", titleDpId: "dp_fdl_e_t", titleDefault: "Expert", subDpId: "dp_fdl_e_s", subDefault: "3+ years"),
            ],
            "dependency": {"target_id": "dp_skills", "operator": "ALL", "comparison_value": ["sk_flutter", "sk_dart"]}
          },
          {"id": "dp_rating", "code": "SATISFACTION", "component_type": "data_point",
            "type": "rating", "label": "How satisfied are you with your current tools?",
            "info": "Tap to rate, tap again to reset", "validation": {"max_value": 5}},
          // ── Visibility: < numeric (rating) ── rating < 3 → ask for feedback
          {"id": "dp_low_rating_feedback", "code": "LOW_RATING_FB", "component_type": "data_point", "type": "multiline",
            "label": "What can we improve?", "placeholder": "Help us do better...",
            "dependency": {"target_id": "dp_rating", "operator": "<", "comparison_value": 3}},
          // ── Visibility: >= numeric ── rating ≥ 4 → nominate
          {"id": "dp_top_performer", "code": "TOP_PERFORMER", "component_type": "data_point", "type": "text",
            "label": "Nominate for Team Lead?", "placeholder": "Enter nominee name",
            "dependency": {"target_id": "dp_rating", "operator": ">=", "comparison_value": 4}},
          {"id": "dp_newsletter", "code": "NEWSLETTER", "component_type": "data_point",
            "type": "switch", "label": "Subscribe to newsletter",
            "info": "Weekly updates on new features", "default_value": true},
          // ── Visibility: = boolean (Chain Level 1) ── newsletter = true → show frequency
          {
            "id": "dp_newsletter_freq", "code": "NEWSLETTER_FREQ", "component_type": "data_point",
            "type": "single_select", "label": "Newsletter Frequency",
            "options": [
              _opt("opt_freq_daily", "FREQ_DAILY", titleDpId: "dp_fd_t", titleDefault: "Daily", subDpId: "dp_fd_s", subDefault: "Every day"),
              _opt("opt_freq_weekly", "FREQ_WEEKLY", titleDpId: "dp_fw_t", titleDefault: "Weekly", subDpId: "dp_fw_s", subDefault: "Once a week"),
              _opt("opt_freq_monthly", "FREQ_MONTHLY", titleDpId: "dp_fm_t", titleDefault: "Monthly", subDpId: "dp_fm_s", subDefault: "Once a month"),
              _opt("opt_freq_custom", "FREQ_CUSTOM", titleDpId: "dp_fc_t", titleDefault: "Custom", subDpId: "dp_fc_s", subDefault: "Set your own schedule"),
            ],
            "dependency": {"target_id": "dp_newsletter", "operator": "=", "comparison_value": true}
          },
          // ── Visibility: IN (Chain Level 2) ── frequency = Custom → show schedule input
          {"id": "dp_custom_schedule", "code": "CUSTOM_SCHEDULE", "component_type": "data_point", "type": "text",
            "label": "Custom Schedule", "placeholder": "e.g. 1st and 15th of each month",
            "dependency": {"target_id": "dp_newsletter_freq", "operator": "IN", "comparison_value": ["opt_freq_custom"]}},
          {"id": "dp_terms", "code": "TERMS", "component_type": "data_point",
            "type": "checkbox", "label": "I agree to the Terms of Service",
            "validation": {"is_required": true, "error_message": "You must agree to continue"}},
          // ── Compact chips: ≤4 options, NO subtitle/description ──
          {
            "id": "dp_work_mode", "code": "WORK_MODE", "component_type": "data_point",
            "type": "single_select", "label": "Preferred Work Mode",
            "options": [
              {"id": "opt_wm_remote", "code": "WM_REMOTE", "component_type": "selection_option",
                "value": {"title": "Remote", "DFUP": {"id": "dfup_wm_r", "code": "DFUP_WM_R", "component_type": "layout", "layout_type": "scroll", "children": [{"id": "fr_wm_r", "code": "FR_WM_R", "component_type": "data_frame", "title": "", "allow_multiples": false, "points": [{"id": "dp_wm_r_t", "code": "WM_R_T", "component_type": "data_point", "type": "text", "label": "T", "response": {"data_type": "text", "value": "Remote", "status": "valid", "timestamp": "2026-02-12T00:00:00Z"}}]}]}}},
              {"id": "opt_wm_hybrid", "code": "WM_HYBRID", "component_type": "selection_option",
                "value": {"title": "Hybrid", "DFUP": {"id": "dfup_wm_h", "code": "DFUP_WM_H", "component_type": "layout", "layout_type": "scroll", "children": [{"id": "fr_wm_h", "code": "FR_WM_H", "component_type": "data_frame", "title": "", "allow_multiples": false, "points": [{"id": "dp_wm_h_t", "code": "WM_H_T", "component_type": "data_point", "type": "text", "label": "T", "response": {"data_type": "text", "value": "Hybrid", "status": "valid", "timestamp": "2026-02-12T00:00:00Z"}}]}]}}},
              {"id": "opt_wm_onsite", "code": "WM_ONSITE", "component_type": "selection_option",
                "value": {"title": "On-site", "DFUP": {"id": "dfup_wm_o", "code": "DFUP_WM_O", "component_type": "layout", "layout_type": "scroll", "children": [{"id": "fr_wm_o", "code": "FR_WM_O", "component_type": "data_frame", "title": "", "allow_multiples": false, "points": [{"id": "dp_wm_o_t", "code": "WM_O_T", "component_type": "data_point", "type": "text", "label": "T", "response": {"data_type": "text", "value": "On-site", "status": "valid", "timestamp": "2026-02-12T00:00:00Z"}}]}]}}},
            ]
          },
          // ── Multi-select inline cards: 6 options with subtitles (≤10 → inline, not sheet) ──
          {
            "id": "dp_benefits", "code": "BENEFITS", "component_type": "data_point",
            "type": "multi_select", "label": "Preferred Benefits",
            "options": [
              _opt("opt_ben_health", "BEN_HEALTH", titleDpId: "dp_bh_t", titleDefault: "Health Insurance", subDpId: "dp_bh_s", subDefault: "Medical coverage"),
              _opt("opt_ben_dental", "BEN_DENTAL", titleDpId: "dp_bd_t", titleDefault: "Dental", subDpId: "dp_bd_s", subDefault: "Dental plan"),
              _opt("opt_ben_vision", "BEN_VISION", titleDpId: "dp_bv_t", titleDefault: "Vision", subDpId: "dp_bv_s", subDefault: "Eye care"),
              _opt("opt_ben_401k", "BEN_401K", titleDpId: "dp_b4_t", titleDefault: "401(k)", subDpId: "dp_b4_s", subDefault: "Retirement savings"),
              _opt("opt_ben_pto", "BEN_PTO", titleDpId: "dp_bp_t", titleDefault: "PTO", subDpId: "dp_bp_s", subDefault: "Paid time off"),
              _opt("opt_ben_remote", "BEN_REMOTE", titleDpId: "dp_br_t", titleDefault: "Remote Stipend", subDpId: "dp_br_s", subDefault: "Home office budget"),
            ]
          },
        ]
      }]
    },

    // ── 3. Work History (multi-instance) ──
    {
      "id": "frame_work", "code": "WORK_HISTORY", "component_type": "data_frame",
      "title": "Work History — {{dp_fullname}}", "description": "Add your previous positions",
      "allow_multiples": true,
      "points": [
        {"id": "dp_company", "code": "COMPANY_NAME", "component_type": "data_point", "type": "text", "label": "Company Name", "validation": {"is_required": true}},
        {"id": "dp_jobtitle", "code": "JOB_TITLE", "component_type": "data_point", "type": "text", "label": "Job Title", "validation": {"is_required": true}},
        {"id": "dp_startdate", "code": "START_DATE", "component_type": "data_point", "type": "date", "label": "Start Date", "validation": {"is_required": true}},
        {"id": "dp_current", "code": "IS_CURRENT", "component_type": "data_point", "type": "switch", "label": "Currently working here"},
        {"id": "dp_enddate", "code": "END_DATE", "component_type": "data_point", "type": "date", "label": "End Date",
          "dependency": {"target_id": "dp_current", "operator": "=", "comparison_value": false}},
        // ── Visibility: != boolean + multi-instance ── current != true → show reason
        {"id": "dp_reason_leaving", "code": "REASON_LEAVING", "component_type": "data_point", "type": "text",
          "label": "Reason for Leaving", "placeholder": "e.g. Career growth, relocation...",
          "dependency": {"target_id": "dp_current", "operator": "!=", "comparison_value": true}},
        // ── Compound AND intra-instance ── NOT current AND has job title → show achievements
        {"id": "dp_achievements", "code": "ACHIEVEMENTS", "component_type": "data_point", "type": "multiline",
          "label": "Key Achievements", "placeholder": "Describe key accomplishments in this role...",
          "dependency": {"mode": "AND", "conditions": [
            {"target_id": "dp_current", "operator": "=", "comparison_value": false},
            {"target_id": "dp_jobtitle", "operator": "!=", "comparison_value": ""}
          ]}},
        // ── Visibility: Cross-frame dependency ── dp_role (Step 2) = PM → show management exp
        {"id": "dp_management_exp", "code": "MGMT_EXP", "component_type": "data_point", "type": "multiline",
          "label": "Management Experience", "placeholder": "Describe team size, responsibilities...",
          "dependency": {"target_id": "dp_role", "operator": "IN", "comparison_value": ["opt_pm"]}},
      ]
    },

    // ── 4. Documents ──
    {
      "id": "grp_docs", "code": "DOCUMENTS", "component_type": "data_frame_group",
      "title": "Documents", "description": "Upload supporting documents for {{FULL_NAME}}",
      "frames": [{
        "id": "frame_docs", "code": "DOC_UPLOADS", "component_type": "data_frame",
        "title": "Attachments", "allow_multiples": false,
        "points": [
          // ── Visibility: Parent for two children ──
          {
            "id": "dp_submission_type", "code": "SUBMISSION_TYPE", "component_type": "data_point",
            "type": "single_select", "label": "Submission Type",
            "validation": {"is_required": true},
            "options": [
              _opt("opt_sub_standard", "SUB_STANDARD", titleDpId: "dp_ss_t", titleDefault: "Standard", subDpId: "dp_ss_s", subDefault: "Normal processing time"),
              _opt("opt_sub_express", "SUB_EXPRESS", titleDpId: "dp_se_t", titleDefault: "Express", subDpId: "dp_se_s", subDefault: "3-5 business days"),
              _opt("opt_sub_priority", "SUB_PRIORITY", titleDpId: "dp_sp_t", titleDefault: "Priority", subDpId: "dp_sp_s", subDefault: "Within 24 hours"),
            ]
          },
          // ── Visibility: IN single value ── submission = Priority → show reason
          {"id": "dp_priority_reason", "code": "PRIORITY_REASON", "component_type": "data_point", "type": "multiline",
            "label": "Why do you need priority processing?", "placeholder": "Explain urgency...",
            "validation": {"is_required": true},
            "dependency": {"target_id": "dp_submission_type", "operator": "IN", "comparison_value": ["opt_sub_priority"]}},
          // ── Visibility: IN multiple values ── submission = Express OR Priority → show fee ack
          {"id": "dp_rush_fee_ack", "code": "RUSH_FEE_ACK", "component_type": "data_point", "type": "checkbox",
            "label": "I understand rush processing fees apply",
            "validation": {"is_required": true, "error_message": "You must acknowledge the rush fee"},
            "dependency": {"target_id": "dp_submission_type", "operator": "IN", "comparison_value": ["opt_sub_express", "opt_sub_priority"]}},
          {"id": "dp_resume", "code": "RESUME", "component_type": "data_point", "type": "file_upload",
            "label": "Resume / CV", "info": "Upload your latest resume",
            "validation": {"is_required": true, "allowed_extensions": ["pdf", "doc", "docx"], "max_size_mb": 10, "min_files": 1, "max_files": 1}},
          {"id": "dp_portfolio", "code": "PORTFOLIO", "component_type": "data_point", "type": "file_upload",
            "label": "Portfolio (optional)",
            "validation": {"allowed_extensions": ["pdf", "zip", "jpg", "png"], "max_size_mb": 25, "max_files": 5}},
          // ── default_value: text ── pre-filled greeting
          {"id": "dp_cover_note", "code": "COVER_NOTE", "component_type": "data_point", "type": "multiline",
            "label": "Cover Note", "default_value": "Dear Hiring Manager,\n\nI am excited to apply for this position.",
            "validation": {"max_length": 1000}},
          // ── default_value: number ── pre-filled notice period
          {"id": "dp_notice_period", "code": "NOTICE_PERIOD", "component_type": "data_point", "type": "number",
            "label": "Notice Period (days)", "default_value": 30, "placeholder": "e.g. 30",
            "validation": {"min_value": 0, "max_value": 180}},
          // ── boolean type ──
          {"id": "dp_has_referral", "code": "HAS_REFERRAL", "component_type": "data_point", "type": "boolean",
            "label": "I have a referral"},
          {"id": "dp_password_test", "code": "SECRET_CODE", "component_type": "data_point", "type": "password",
            "label": "Referral Code", "placeholder": "Enter code if you have one", "info": "Optional referral code"},
          {"id": "dp_meeting_time", "code": "MEETING_TIME", "component_type": "data_point", "type": "datetime",
            "label": "Preferred Meeting Time for {{FULL_NAME}}", "placeholder": "Select interview slot"},
        ]
      }]
    },
  ]
};
