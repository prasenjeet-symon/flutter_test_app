import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FileUploadResult {
  final String id;
  final String name;
  final double progress;
  final String s3Key;
  final String type;

  FileUploadResult({required this.id, required this.name, required this.progress, required this.s3Key, required this.type});
}

class OrbitFileInput extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final double borderRadius;
  final bool isCompact;
  final Function(FileUploadResult, PlatformFile) onFileUploaded;
  final List<String>? allowedMimeTypes;

  const OrbitFileInput({super.key, required this.controller, this.labelText, this.hintText, this.validator, this.borderRadius = 12.0, this.isCompact = false, required this.onFileUploaded, this.allowedMimeTypes});

  @override
  State<OrbitFileInput> createState() => _OrbitFileInputState();
}

class _OrbitFileInputState extends State<OrbitFileInput> with SingleTickerProviderStateMixin {
  final _focusNode = FocusNode();
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  bool _hasError = false;
  String? _fileName;
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // Map MIME types to file extensions
  List<String>? _getAllowedExtensions() {
    if (widget.allowedMimeTypes == null || widget.allowedMimeTypes!.isEmpty) return null;
    final extensions = <String>{};
    for (var mimeType in widget.allowedMimeTypes!) {
      if (mimeType == 'image/*') {
        extensions.addAll(['jpg', 'jpeg', 'png', 'gif', 'bmp']);
      } else if (mimeType == 'application/pdf') {
        extensions.add('pdf');
      } else if (mimeType == 'text/plain') {
        extensions.add('txt');
      } else if (mimeType == 'application/msword' || mimeType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
        extensions.addAll(['doc', 'docx']);
      }
      // Add more MIME type mappings as needed
    }
    return extensions.toList();
  }

  @override
  void initState() {
    super.initState();
    // Ensure controller is empty initially
    widget.controller.text = '';
    // Initialize animation controller for progress simulation
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_progressController)..addListener(() {
      setState(() {
        _uploadProgress = _progressAnimation.value;
      });
    });
    // Validate on controller change
    widget.controller.addListener(() {
      if (_hasError && mounted) {
        setState(() {
          _hasError = false;
          _fieldKey.currentState?.didChange(widget.controller.text);
        });
      }
    });
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (_isUploading) return; // Prevent picking during upload
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false, allowedExtensions: _getAllowedExtensions(), type: widget.allowedMimeTypes != null ? FileType.custom : FileType.any);
      if (result != null && result.files.isNotEmpty && mounted) {
        final file = result.files.first;
        setState(() {
          _fileName = file.name;
          _isUploading = true;
          _uploadProgress = 0.0;
        });
        // Simulate file upload
        _progressController.reset();
        _progressController.forward().then((_) {
          if (mounted) {
            final fileResult = FileUploadResult(id: DateTime.now().millisecondsSinceEpoch.toString(), name: file.name, progress: 1.0, s3Key: 'uploads/${file.name}_${DateTime.now().millisecondsSinceEpoch}', type: file.extension ?? 'unknown');
            widget.controller.text = fileResult.s3Key;
            widget.onFileUploaded(fileResult, file);
            setState(() {
              _isUploading = false;
              _fieldKey.currentState?.didChange(widget.controller.text);
              _hasError = _fieldKey.currentState?.hasError ?? false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.isCompact;
    final verticalPadding = isCompact ? 4.h : 8.h;
    final horizontalPadding = isCompact ? 8.w : 12.w;
    final labelFontSize = isCompact ? 10.sp : 12.sp;
    final textFontSize = isCompact ? 14.sp : 16.sp;
    final iconSize = isCompact ? 16.sp : 20.sp;
    final errorFontSize = isCompact ? 10.sp : 12.sp;
    final errorPadding = isCompact ? 2.h : 4.h;
    final borderWidth = isCompact ? 1.w : 1.2.w;

    return FormField<String>(
      key: _fieldKey,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<String> field) {
        _hasError = field.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _isUploading ? null : _pickFile,
              child: Container(
                decoration: BoxDecoration(
                  color: _focusNode.hasFocus || widget.controller.text.isNotEmpty ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  border: Border.all(
                    color:
                        _hasError
                            ? Theme.of(context).colorScheme.error
                            : _focusNode.hasFocus || widget.controller.text.isNotEmpty
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                    width: borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(widget.borderRadius.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.labelText != null)
                      Text(widget.labelText!, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _hasError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant, fontSize: labelFontSize)),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.only(right: 8.w), child: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.onSurfaceVariant, size: iconSize)),
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            readOnly: true,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: textFontSize, fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                              hintText: _fileName ?? widget.hintText ?? 'Select a file',
                              hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(_focusNode.hasFocus ? 0.9 : 0.7), fontSize: textFontSize, fontWeight: FontWeight.w400),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onTap: _isUploading ? null : _pickFile,
                            onTapOutside: (event) => _focusNode.unfocus(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_isUploading)
              Padding(
                padding: EdgeInsets.only(top: 4.h, left: 12.w, right: 12.w),
                child: LinearProgressIndicator(value: _uploadProgress, backgroundColor: Theme.of(context).colorScheme.surfaceVariant, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary), minHeight: 4.h),
              ),
            if (_hasError && field.errorText != null)
              Padding(padding: EdgeInsets.only(top: errorPadding, left: 12.w), child: Text(field.errorText!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error, fontSize: errorFontSize))),
          ],
        );
      },
    );
  }
}
