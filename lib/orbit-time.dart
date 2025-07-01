import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class OrbitTimeInput extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final double borderRadius;
  final ValueChanged<TimeOfDay>? onTimeSelected;
  final bool isCompact;
  final TimeOfDay? initialTime;
  final EdgeInsetsGeometry? padding;
  final double? verticalMargin;

  const OrbitTimeInput({super.key, required this.controller, this.labelText, this.hintText, this.validator, this.borderRadius = 12.0, this.onTimeSelected, this.isCompact = false, this.initialTime, this.padding, this.verticalMargin});

  @override
  State<OrbitTimeInput> createState() => _OrbitTimeInputState();
}

class _OrbitTimeInputState extends State<OrbitTimeInput> {
  final _focusNode = FocusNode();
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Check initial controller value and validate if non-empty
    if (widget.controller.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fieldKey.currentState?.didChange(widget.controller.text);
          setState(() {
            _hasError = _fieldKey.currentState?.hasError ?? false;
          });
        }
      });
    }
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    widget.controller.addListener(() {
      if (_hasError && mounted) {
        setState(() {
          _hasError = false;
          _fieldKey.currentState?.didChange(widget.controller.text);
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).colorScheme.primary, onPrimary: Theme.of(context).colorScheme.onPrimary, surface: Theme.of(context).colorScheme.surface, onSurface: Theme.of(context).colorScheme.onSurface),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      final formattedTime = DateFormat.jm().format(DateTime(2025, 1, 1, picked.hour, picked.minute));
      widget.controller.text = formattedTime;
      widget.onTimeSelected?.call(picked);
      _fieldKey.currentState?.didChange(formattedTime);
      setState(() {
        _hasError = _fieldKey.currentState?.hasError ?? false;
      });
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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.verticalMargin ?? 0),
      child: FormField<String>(
        key: _fieldKey,
        validator: widget.validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        builder: (FormFieldState<String> field) {
          _hasError = field.hasError;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.labelText != null)
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.labelText!, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _hasError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant, fontSize: labelFontSize)),
                    ),
                    SizedBox(height: 4.h), // Small spacing between label and input
                  ],
                ),
              GestureDetector(
                onTap: () => _selectTime(context),
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
                  padding: widget.padding ?? EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                  child: Row(
                    children: [
                      Padding(padding: EdgeInsets.only(right: 8.w), child: Icon(Icons.access_time, color: Theme.of(context).colorScheme.onSurfaceVariant, size: iconSize)),
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          readOnly: true, // Prevent manual text input
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: textFontSize, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                            hintText: widget.hintText ?? 'Select a time',
                            hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(_focusNode.hasFocus ? 0.9 : 0.7), fontSize: textFontSize, fontWeight: FontWeight.w400),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onTap: () => _selectTime(context),
                          onTapOutside: (event) => _focusNode.unfocus(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_hasError && field.errorText != null)
                Padding(padding: EdgeInsets.only(top: errorPadding, left: horizontalPadding), child: Text(field.errorText!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error, fontSize: errorFontSize))),
            ],
          );
        },
      ),
    );
  }
}
