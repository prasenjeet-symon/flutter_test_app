import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test_app/utils.dart';
import 'package:shimmer/shimmer.dart';

// Reusable OrbitDropdown widget with generic type
class OrbitDropdown<T extends DropdownOption> extends StatefulWidget {
  final String orbitKey;
  final String? orbitParentKey;
  final Future<List<T>> Function(dynamic)? data;
  final OrbitFormManager? orbitFormManager;
  final List<T> options;
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<T>? validator;
  final double borderRadius;
  final ValueChanged<T?>? onChanged;
  final bool isCompact;

  const OrbitDropdown({
    required this.orbitKey,
    this.orbitParentKey,
    this.data,
    this.orbitFormManager,
    required this.options,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.borderRadius = 12.0,
    this.onChanged,
    this.isCompact = false,
    super.key,
  });

  @override
  State<OrbitDropdown<T>> createState() => _OrbitDropdownState<T>();
}

class _OrbitDropdownState<T extends DropdownOption> extends State<OrbitDropdown<T>> {
  T? _selectedOption;
  OverlayEntry? _overlayEntry;
  final _inputKey = GlobalKey();
  final _focusNode = FocusNode();
  bool _hasError = false;
  final _fieldKey = GlobalKey<FormFieldState<T>>();
  List<T> _options = [];
  bool _isLoading = false;
  StreamSubscription? _parentSubscription;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _initializeData() async {
    if (widget.orbitParentKey != null && widget.orbitFormManager != null && widget.data != null) {
      if (mounted) {
        setState(() => _isLoading = true);
      }
      _parentSubscription = widget.orbitFormManager!.get(widget.orbitParentKey!).listen((parentValue) async {
        if (parentValue == null) {
          if (mounted) {
            setState(() {
              _options = [];
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() => _isLoading = true);
          }
          final newOptions = await widget.data!(parentValue);
          if (mounted) {
            setState(() {
              _options = newOptions;
              _isLoading = false;
              _setDefaultValue();
            });
          }
        }
      });
    } else if (widget.data != null) {
      if (mounted) {
        setState(() => _isLoading = true);
      }
      final newOptions = await widget.data!(null);
      if (mounted) {
        setState(() {
          _options = newOptions;
          _isLoading = false;
          _setDefaultValue();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _options = widget.options;
          _setDefaultValue();
        });
      }
    }
  }

  void _setDefaultValue() {
    if (widget.controller.text.isNotEmpty && _options.isNotEmpty) {
      _selectedOption = _options.firstWhere((option) => option.id == widget.controller.text || option.title == widget.controller.text, orElse: () => _options.first);
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.onChanged?.call(_selectedOption);
        widget.orbitFormManager?.set(widget.orbitKey, _selectedOption);
        _fieldKey.currentState?.didChange(_selectedOption);
        _hasError = _fieldKey.currentState?.hasError ?? false;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _removeOverlay();
    _parentSubscription?.cancel();
    super.dispose();
  }

  void _showDropdown() {
    if (_overlayEntry != null || _options.isEmpty) return;

    final RenderBox renderBox = _inputKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    final isCompact = widget.isCompact;
    final itemHorizontalPadding = isCompact ? 10.w : 12.w;
    final itemVerticalPadding = isCompact ? 3.h : 4.h;
    final avatarRadius = isCompact ? 14.r : 16.r;
    final titleFontSize = isCompact ? 15.sp : 16.sp;
    final subtitleFontSize = isCompact ? 11.sp : 12.sp;
    final borderWidth = isCompact ? 1.1.w : 1.2.w;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              GestureDetector(onTap: _removeOverlay, behavior: HitTestBehavior.translucent, child: Container(color: Colors.transparent)),
              Positioned(
                left: position.dx,
                top: position.dy + size.height + 4.h,
                width: size.width,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(widget.borderRadius.r),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 200.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: borderWidth),
                      borderRadius: BorderRadius.circular(widget.borderRadius.r),
                    ),
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _options.length,
                        itemBuilder: (context, index) {
                          final option = _options[index];
                          return ListTile(
                            leading: option.profileImageUrl != null ? CircleAvatar(radius: avatarRadius, backgroundImage: NetworkImage(option.profileImageUrl!), onBackgroundImageError: (_, __) => const Icon(Icons.error)) : null,
                            title: Text(option.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400, fontSize: titleFontSize)),
                            subtitle: option.subtitle != null ? Text(option.subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: subtitleFontSize)) : null,
                            trailing: option.actionIcon != null ? Icon(option.actionIcon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: isCompact ? 18.sp : 20.sp) : null,
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  _selectedOption = option;
                                  widget.controller.text = option.id ?? option.title;
                                  _hasError = false;
                                  _fieldKey.currentState?.didChange(_selectedOption);
                                });
                              }
                              widget.onChanged?.call(_selectedOption);
                              widget.orbitFormManager?.set(widget.orbitKey, _selectedOption);
                              _removeOverlay();
                              _focusNode.unfocus();
                            },
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: itemHorizontalPadding, vertical: itemVerticalPadding),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildShimmer() {
    final isCompact = widget.isCompact;
    final verticalPadding = isCompact ? 6.h : 8.h;
    final horizontalPadding = isCompact ? 10.w : 12.w;
    final avatarRadius = isCompact ? 14.r : 16.r;
    final borderWidth = isCompact ? 1.1.w : 1.2.w;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        key: _inputKey,
        decoration: BoxDecoration(color: Colors.grey[300], border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), width: borderWidth), borderRadius: BorderRadius.circular(widget.borderRadius.r)),
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
        child: Row(
          children: [
            CircleAvatar(radius: avatarRadius, backgroundColor: Colors.grey[300]),
            SizedBox(width: 8.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 100.w, height: 16.h, color: Colors.grey[300]), SizedBox(height: 4.h), Container(width: 60.w, height: 12.h, color: Colors.grey[300])])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmer();
    }

    if (_options.isEmpty && widget.orbitParentKey != null) {
      return const SizedBox.shrink();
    }

    final isCompact = widget.isCompact;
    final verticalPadding = isCompact ? 8.h : 8.h;
    final horizontalPadding = isCompact ? 10.w : 12.w;
    final labelFontSize = isCompact ? 11.sp : 12.sp;
    final textFontSize = isCompact ? 15.sp : 16.sp;
    final subtitleFontSize = isCompact ? 11.sp : 12.sp;
    final avatarRadius = isCompact ? 14.r : 16.r;
    final iconSize = isCompact ? 18.sp : 20.sp;
    final errorFontSize = isCompact ? 11.sp : 12.sp;
    final errorPadding = isCompact ? 3.h : 4.h;
    final borderWidth = isCompact ? 1.1.w : 1.2.w;

    return FormField<T>(
      key: _fieldKey,
      validator:
          widget.validator ??
          (value) {
            if (_selectedOption == null) {
              return 'Please select an option';
            }
            return null;
          },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<T> field) {
        _hasError = field.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (_overlayEntry == null) {
                  _showDropdown();
                } else {
                  _removeOverlay();
                }
                if (mounted) {
                  setState(() {
                    _hasError = false;
                    field.didChange(_selectedOption);
                  });
                }
              },
              child: Container(
                key: _inputKey,
                decoration: BoxDecoration(
                  color: _focusNode.hasFocus || _selectedOption != null ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  border: Border.all(
                    color:
                        _hasError
                            ? Theme.of(context).colorScheme.error
                            : _focusNode.hasFocus || _selectedOption != null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                    width: borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(widget.borderRadius.r),
                ),
                padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.labelText != null)
                      Text(widget.labelText!, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _hasError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant, fontSize: labelFontSize)),
                    Row(
                      children: [
                        if (_selectedOption != null && _selectedOption!.profileImageUrl != null)
                          Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: CircleAvatar(radius: avatarRadius, backgroundImage: NetworkImage(_selectedOption!.profileImageUrl!), onBackgroundImageError: (_, __) => Icon(Icons.error, size: avatarRadius)),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedOption?.title ?? (widget.hintText ?? 'Choose an option'),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: _selectedOption == null ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(_focusNode.hasFocus ? 0.9 : 0.7) : Theme.of(context).colorScheme.onSurface,
                                  fontSize: textFontSize,
                                ),
                              ),
                              if (_selectedOption != null && _selectedOption!.subtitle != null)
                                Text(_selectedOption!.subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: subtitleFontSize)),
                            ],
                          ),
                        ),
                        Icon(_overlayEntry != null ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurfaceVariant, size: iconSize),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_hasError && field.errorText != null)
              Padding(padding: EdgeInsets.only(top: errorPadding, left: 12.w), child: Text(field.errorText!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error, fontSize: errorFontSize))),
          ],
        );
      },
    );
  }
}
