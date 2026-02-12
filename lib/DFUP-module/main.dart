// lib/main.dart

import 'dart:convert';
import 'package:flutter/material.dart';
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
                child: const Text('DFUP 2.2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5))),
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
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
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
      body: Padding(padding: const EdgeInsets.all(S.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Paste your DFUP JSON document below:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.text1)),
        const SizedBox(height: S.md),
        Expanded(child: TextField(controller: _ctrl, maxLines: null, expands: true, textAlignVertical: TextAlignVertical.top,
          style: TextStyle(fontSize: 13, fontFamily: 'monospace', color: c.text1),
          decoration: InputDecoration(hintText: '{\n  "id": "...",\n  ...\n}', errorText: _err))),
        const SizedBox(height: S.lg),
        ElevatedButton(onPressed: _load, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: S.lg)),
          child: const Text('Render Form')),
      ])),
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
     String? description, bool disabled = false}) {
  return {
    "id": id, "code": code, "component_type": "selection_option", "is_disabled": disabled,
    "value": {
      "code": code, "title": titleDpId, "subtitle": subDpId,
      if (description != null) "description": description,
      "DFUP": {
        "id": "dfup_$id", "code": "DFUP_$code", "component_type": "layout", "layout_type": "scroll",
        "children": [{"id": "frame_$id", "code": "FRAME_$code", "component_type": "data_frame",
          "title": "", "allow_multiples": false,
          "points": [
            {"id": titleDpId, "code": "${code}_TITLE", "component_type": "data_point", "type": "text", "label": "Title", "default_value": titleDefault},
            {"id": subDpId, "code": "${code}_SUBTITLE", "component_type": "data_point", "type": "text", "label": "Subtitle", "default_value": subDefault},
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
      "title": "Personal Details", "description": "Tell us about yourself",
      "frames": [{
        "id": "frame_basic", "code": "BASIC_INFO", "component_type": "data_frame",
        "title": "Basic Information", "allow_multiples": false,
        "points": [
          {"id": "dp_fullname", "code": "FULL_NAME", "component_type": "data_point", "type": "text",
            "label": "Full Name", "placeholder": "John Doe",
            "validation": {"is_required": true, "min_length": 2, "max_length": 100}},
          {"id": "dp_email", "code": "EMAIL", "component_type": "data_point", "type": "email",
            "label": "Email Address", "placeholder": "john@example.com", "is_searchable": true,
            "validation": {"is_required": true}},
          {"id": "dp_phone", "code": "PHONE", "component_type": "data_point", "type": "phone",
            "label": "Phone Number", "placeholder": "+1 (555) 123-4567", "info": "Include country code"},
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
          {"id": "dp_bio", "code": "BIO", "component_type": "data_point", "type": "multiline",
            "label": "Short Bio", "placeholder": "Tell us about yourself...", "validation": {"max_length": 500}},
        ]
      }]
    },

    // ── 2. Preferences — single_select 7 opts (>5 → sheet), multi_select 12 opts (>10 → sheet) ──
    {
      "id": "grp_prefs", "code": "PREFERENCES", "component_type": "data_frame_group",
      "title": "Preferences", "description": "Customize your experience",
      "frames": [{
        "id": "frame_prefs", "code": "PREF_OPTIONS", "component_type": "data_frame",
        "title": "Options", "allow_multiples": false,
        "points": [
          // 7 options → bottom sheet with search
          {
            "id": "dp_role", "code": "ROLE", "component_type": "data_point",
            "type": "single_select", "label": "Primary Role",
            "is_searchable": true,
            "validation": {"is_required": true},
            "options": [
              _opt("opt_dev", "DEVELOPER", titleDpId: "dp_dev_t", titleDefault: "Developer", subDpId: "dp_dev_s", subDefault: "Build & ship code", description: "Software engineers building products"),
              _opt("opt_design", "DESIGNER", titleDpId: "dp_des_t", titleDefault: "Designer", subDpId: "dp_des_s", subDefault: "Craft visual experiences", description: "UX/UI design professionals"),
              _opt("opt_pm", "PM", titleDpId: "dp_pm_t", titleDefault: "Product Manager", subDpId: "dp_pm_s", subDefault: "Drive product strategy", description: "Product leadership & roadmaps"),
              _opt("opt_qa", "QA", titleDpId: "dp_qa_t", titleDefault: "QA Engineer", subDpId: "dp_qa_s", subDefault: "Ensure quality", description: "Testing & quality assurance"),
              _opt("opt_devops", "DEVOPS", titleDpId: "dp_do_t", titleDefault: "DevOps", subDpId: "dp_do_s", subDefault: "Infrastructure & CI/CD", description: "Platform & operations"),
              _opt("opt_data", "DATA", titleDpId: "dp_da_t", titleDefault: "Data Scientist", subDpId: "dp_da_s", subDefault: "ML & analytics", description: "Machine learning & data analysis"),
              _opt("opt_other", "OTHER", titleDpId: "dp_ot_t", titleDefault: "Other", subDpId: "dp_ot_s", subDefault: "Something else", description: "Any other role not listed"),
            ]
          },
          {"id": "dp_experience", "code": "EXPERIENCE", "component_type": "data_point",
            "type": "slider", "label": "Years of Experience", "validation": {"min_value": 0, "max_value": 30}},
          // 12 options → bottom sheet with search
          {
            "id": "dp_skills", "code": "SKILLS", "component_type": "data_point",
            "type": "multi_select", "label": "Key Skills",
            "is_searchable": true,
            "validation": {"is_required": true},
            "options": [
              _opt("sk_flutter", "FLUTTER", titleDpId: "dp_sk_fl_t", titleDefault: "Flutter", subDpId: "dp_sk_fl_s", subDefault: "Cross-platform UI", description: "Dart-based mobile & web framework"),
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
          {"id": "dp_rating", "code": "SATISFACTION", "component_type": "data_point",
            "type": "rating", "label": "How satisfied are you with your current tools?",
            "info": "Tap to rate, tap again to reset", "validation": {"max_value": 5}},
          {"id": "dp_newsletter", "code": "NEWSLETTER", "component_type": "data_point",
            "type": "switch", "label": "Subscribe to newsletter",
            "info": "Weekly updates on new features", "default_value": true},
          {"id": "dp_terms", "code": "TERMS", "component_type": "data_point",
            "type": "checkbox", "label": "I agree to the Terms of Service",
            "validation": {"is_required": true, "error_message": "You must agree to continue"}},
        ]
      }]
    },

    // ── 3. Work History (multi-instance) ──
    {
      "id": "frame_work", "code": "WORK_HISTORY", "component_type": "data_frame",
      "title": "Work History", "description": "Add your previous positions",
      "allow_multiples": true,
      "points": [
        {"id": "dp_company", "code": "COMPANY_NAME", "component_type": "data_point", "type": "text", "label": "Company Name", "validation": {"is_required": true}},
        {"id": "dp_jobtitle", "code": "JOB_TITLE", "component_type": "data_point", "type": "text", "label": "Job Title", "validation": {"is_required": true}},
        {"id": "dp_startdate", "code": "START_DATE", "component_type": "data_point", "type": "date", "label": "Start Date", "validation": {"is_required": true}},
        {"id": "dp_current", "code": "IS_CURRENT", "component_type": "data_point", "type": "switch", "label": "Currently working here"},
        {"id": "dp_enddate", "code": "END_DATE", "component_type": "data_point", "type": "date", "label": "End Date",
          "dependency": {"target_id": "dp_current", "operator": "=", "comparison_value": false}},
      ]
    },

    // ── 4. Documents ──
    {
      "id": "grp_docs", "code": "DOCUMENTS", "component_type": "data_frame_group",
      "title": "Documents", "description": "Upload supporting documents",
      "frames": [{
        "id": "frame_docs", "code": "DOC_UPLOADS", "component_type": "data_frame",
        "title": "Attachments", "allow_multiples": false,
        "points": [
          {"id": "dp_resume", "code": "RESUME", "component_type": "data_point", "type": "file_upload",
            "label": "Resume / CV", "info": "Upload your latest resume",
            "validation": {"is_required": true, "allowed_extensions": ["pdf", "doc", "docx"], "max_size_mb": 10}},
          {"id": "dp_portfolio", "code": "PORTFOLIO", "component_type": "data_point", "type": "file_upload",
            "label": "Portfolio (optional)",
            "validation": {"allowed_extensions": ["pdf", "zip", "jpg", "png"], "max_size_mb": 25}},
          {"id": "dp_password_test", "code": "SECRET_CODE", "component_type": "data_point", "type": "password",
            "label": "Referral Code", "placeholder": "Enter code if you have one", "info": "Optional referral code"},
          {"id": "dp_meeting_time", "code": "MEETING_TIME", "component_type": "data_point", "type": "datetime",
            "label": "Preferred Meeting Time", "placeholder": "Select interview slot"},
        ]
      }]
    },
  ]
};
