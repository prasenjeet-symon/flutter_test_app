import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrbitPasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final double borderRadius;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry? padding;
  final double? verticalMargin;
  final bool isCompact;
  final IconData? leftIcon;

  const OrbitPasswordInput({super.key, required this.controller, this.labelText, this.hintText, this.validator, this.borderRadius = 12.0, this.onChanged, this.padding, this.verticalMargin, this.isCompact = false, this.leftIcon});

  @override
  State<OrbitPasswordInput> createState() => _OrbitPasswordInputState();
}

class _OrbitPasswordInputState extends State<OrbitPasswordInput> {
  final _focusNode = FocusNode();
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  bool _hasError = false;
  bool _obscureText = true;

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

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*]).{8,}$').hasMatch(value)) {
      return 'Password must include uppercase, lowercase, digit, and special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.isCompact;
    final verticalPadding = isCompact ? 4.h : 8.h;
    final horizontalPadding = isCompact ? 8.w : 12.w;
    final labelFontSize = isCompact ? 11.sp : 12.sp;
    final textFontSize = isCompact ? 14.sp : 16.sp;
    final iconSize = isCompact ? 16.sp : 20.sp;
    final errorFontSize = isCompact ? 10.sp : 12.sp;
    final errorPadding = isCompact ? 2.h : 4.h;
    final borderWidth = isCompact ? 1.w : 1.2.w;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.verticalMargin ?? 0),
      child: FormField<String>(
        key: _fieldKey,
        validator: widget.validator ?? _defaultValidator,
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
              Container(
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
                    if (widget.leftIcon != null) Padding(padding: EdgeInsets.only(right: 8.w), child: Icon(widget.leftIcon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: iconSize)),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscureText,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: textFontSize, fontWeight: FontWeight.w400),
                        decoration: InputDecoration(
                          hintText: widget.hintText ?? 'Enter password',
                          hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(_focusNode.hasFocus ? 0.9 : 0.7), fontSize: textFontSize, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          widget.onChanged?.call(value);
                          field.didChange(value);
                        },
                        onTapOutside: (event) => _focusNode.unfocus(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).colorScheme.onSurfaceVariant, size: iconSize),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ],
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
