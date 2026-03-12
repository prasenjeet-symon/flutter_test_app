// lib/dfup_file_input.dart

import 'package:flutter/material.dart';
import 'dfup_models.dart';
import 'dfup_utils.dart';
import 'dfup_theme.dart';
import 'dfup_label_row.dart';

class DfupFileInput extends StatefulWidget {
  final DataPoint dataPoint;
  final Map<String, DataPoint>? registry;
  final VoidCallback onMutated;
  const DfupFileInput({super.key, required this.dataPoint, this.registry, required this.onMutated});
  @override
  State<DfupFileInput> createState() => _DfupFileInputState();
}

class _DfupFileInputState extends State<DfupFileInput> {
  List<FileMetadata> _files = [];
  String? _error;
  DataPoint get dp => widget.dataPoint;

  @override
  void initState() {
    super.initState();
    if (dp.response is FileUploadResponse) _files = List.from((dp.response as FileUploadResponse).value);
  }

  void _mutate() {
    final err = DfupValidator.validateFile(dp, _files);
    dp.response = FileUploadResponse(value: List.from(_files), status: err == null ? ResponseStatus.valid : ResponseStatus.invalid);
    setState(() => _error = err);
    widget.onMutated();
  }

  Future<void> _pickFiles() async {
    final ext = dp.fileValidation?.allowedExtensions;
    final simExt = ext != null && ext.isNotEmpty ? ext.first : 'pdf';
    final simMime = simExt == 'pdf' ? 'application/pdf' : simExt == 'jpg' || simExt == 'png' ? 'image/$simExt' : 'application/octet-stream';
    final sim = FileMetadata(fileName: 'upload_${DateTime.now().millisecondsSinceEpoch}.$simExt', fileSizeBytes: 512 * 1024 + (DateTime.now().millisecond * 1024), mimeType: simMime, url: 'file://simulated_upload');
    setState(() => _files.add(sim));
    _mutate();
  }

  void _remove(int i) { setState(() => _files.removeAt(i)); _mutate(); }
  String _fmtSize(int b) { if (b < 1024) return '$b B'; if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB'; return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB'; }

  IconData _fIcon(String mime) {
    if (mime.contains('image')) return Icons.image_outlined;
    if (mime.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (mime.contains('video')) return Icons.videocam_outlined;
    if (mime.contains('audio')) return Icons.audiotrack_outlined;
    if (mime.contains('word') || mime.contains('doc')) return Icons.description_outlined;
    if (mime.contains('sheet') || mime.contains('excel')) return Icons.grid_on_outlined;
    if (mime.contains('zip') || mime.contains('rar')) return Icons.folder_zip_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Color _fColor(String mime) {
    if (mime.contains('image')) return const Color(0xFF10B981);
    if (mime.contains('pdf')) return const Color(0xFFEF4444);
    if (mime.contains('video')) return const Color(0xFF8B5CF6);
    if (mime.contains('audio')) return const Color(0xFFF59E0B);
    if (mime.contains('word') || mime.contains('doc')) return const Color(0xFF3B82F6);
    if (mime.contains('sheet') || mime.contains('excel')) return const Color(0xFF10B981);
    return const Color(0xFF6C5CE7);
  }

  @override
  Widget build(BuildContext context) {
    final c = Cx.of(context);
    final allowedExt = dp.fileValidation?.allowedExtensions;
    final maxSize = dp.fileValidation?.maxSizeMb;

    return SizedBox(width: double.infinity, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DfupLabelRow(label: dp.label, isRequired: dp.fileValidation?.isRequired ?? false, info: dp.info, registry: widget.registry),
      const SizedBox(height: S.sm),
      GestureDetector(
        onTap: _pickFiles,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: S.xl, vertical: S.xxl),
          decoration: BoxDecoration(
            color: c.primarySurface,
            borderRadius: BorderRadius.circular(R.lg),
            border: Border.all(color: _error != null ? c.error : c.primary.withValues(alpha: 0.25), width: 1.5)),
          child: Column(children: [
            Container(width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c.primary.withValues(alpha: 0.15), c.primary.withValues(alpha: 0.06)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(R.lg)),
              child: Icon(Icons.cloud_upload_outlined, color: c.primary, size: 28)),
            const SizedBox(height: S.lg),
            Text('Tap to upload files', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.text1)),
            const SizedBox(height: S.xs),
            if (allowedExt != null || maxSize != null)
              Text([if (allowedExt != null && allowedExt.isNotEmpty) allowedExt.map((e) => '.${e.toUpperCase()}').join('  '), if (maxSize != null) 'Max ${maxSize}MB'].join('  •  '),
                style: TextStyle(fontSize: 12, color: c.hint, letterSpacing: 0.3), textAlign: TextAlign.center),
          ]),
        ),
      ),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: S.sm, left: S.sm),
        child: Text(_error!, style: TextStyle(fontSize: 12, color: c.error, fontWeight: FontWeight.w500))),
      if (_files.isNotEmpty) ...[
        const SizedBox(height: S.md),
        ...List.generate(_files.length, (i) {
          final f = _files[i]; final fc = _fColor(f.mimeType);
          return Padding(padding: const EdgeInsets.only(bottom: S.sm), child: Container(
            width: double.infinity, padding: const EdgeInsets.all(S.md),
            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(R.md),
              border: Border.all(color: c.border, width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: fc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(R.md)),
                child: Icon(_fIcon(f.mimeType), size: 22, color: fc)),
              const SizedBox(width: S.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.fileName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.text1), overflow: TextOverflow.ellipsis, maxLines: 1),
                const SizedBox(height: 2),
                Row(children: [
                  Text(_fmtSize(f.fileSizeBytes), style: TextStyle(fontSize: 12, color: c.hint)),
                  const SizedBox(width: S.sm),
                  Container(width: 4, height: 4, decoration: BoxDecoration(color: c.hint.withValues(alpha: 0.5), shape: BoxShape.circle)),
                  const SizedBox(width: S.sm),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: fc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(f.fileName.split('.').last.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fc, letterSpacing: 0.5))),
                ]),
              ])),
              const SizedBox(width: S.sm),
              Container(width: 30, height: 30, decoration: BoxDecoration(color: c.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.check, size: 15, color: c.success)),
              const SizedBox(width: S.xs),
              GestureDetector(onTap: () => _remove(i),
                child: Container(width: 30, height: 30, decoration: BoxDecoration(color: c.error.withValues(alpha: 0.08), shape: BoxShape.circle),
                  child: Icon(Icons.close, size: 15, color: c.error))),
            ]),
          ));
        }),
      ],
    ]));
  }
}
