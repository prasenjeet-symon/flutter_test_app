import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test_app/aws-image.dart';
import 'package:flutter_test_app/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrbitSearchInput<T extends SearchResult> extends StatefulWidget {
  final String orbitKey;
  final String? orbitParentKey;
  final OrbitFormManager? orbitFormManager;
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final double borderRadius;
  final bool isCompact;
  final bool isLocal;
  final Future<List<T>> Function(String) onSearch;
  final EdgeInsetsGeometry? padding;
  final double? verticalMargin;
  final VoidCallback? onFocused;
  final VoidCallback? onBlur;
  final IconData? leftIcon;
  final ValueChanged<T?>? onChanged;

  const OrbitSearchInput({
    super.key,
    required this.orbitKey,
    this.orbitParentKey,
    this.orbitFormManager,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.borderRadius = 12.0,
    this.isCompact = false,
    this.isLocal = false,
    required this.onSearch,
    this.padding,
    this.verticalMargin,
    this.onFocused,
    this.onBlur,
    this.leftIcon = Icons.search,
    this.onChanged,
  });

  @override
  State<OrbitSearchInput<T>> createState() => _OrbitSearchInputState<T>();
}

class _OrbitSearchInputState<T extends SearchResult> extends State<OrbitSearchInput<T>> with SingleTickerProviderStateMixin {
  final _focusNode = FocusNode();
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  final _inputKey = GlobalKey();
  bool _hasError = false;
  List<T> _searchResults = [];
  List<T> _allResults = [];
  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;
  bool _isResultSelected = false;
  StreamSubscription? _parentSubscription;
  T? _selectedResult;
  AnimationController? _animationController;
  Animation<double>? _borderOpacityAnimation;
  Timer? _overlayDelayTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..repeat(reverse: true);
    _borderOpacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut));
    if (widget.controller.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await _loadInitialResult();
        }
      });
    } else {
      widget.orbitFormManager?.set(widget.orbitKey, null);
    }
    // Load initial data for isLocal: true in initState
    if (widget.isLocal && widget.orbitParentKey == null) {
      _initializeData();
    }
    // Subscribe to parent changes for parent-dependent inputs
    if (widget.orbitParentKey != null) {
      _subscribeToParent();
    }
    _focusNode.addListener(() {
      if (mounted) {
        if (_focusNode.hasFocus) {
          widget.onFocused?.call();
          if (_allResults.isNotEmpty && widget.controller.text.isEmpty) {
            setState(() {
              _searchResults = _allResults;
            });
            _delayedShowOverlay();
          } else if (_searchResults.isNotEmpty || widget.controller.text.isNotEmpty) {
            _delayedShowOverlay();
          }
        } else {
          widget.onBlur?.call();
          _cancelOverlayDelay();
          _hideOverlay();
        }
        setState(() {});
      }
    });
    widget.controller.addListener(() {
      if (mounted) {
        if (_hasError) {
          setState(() {
            _hasError = false;
            _fieldKey.currentState?.didChange(widget.controller.text);
          });
        }
      }
    });
  }

  Future<void> _loadInitialResult() async {
    final prefs = await SharedPreferences.getInstance();
    final resultJson = prefs.getString('search_result_${widget.orbitKey}_${widget.controller.text}');
    T? initialResult;
    if (resultJson != null) {
      try {
        final jsonData = jsonDecode(resultJson);
        initialResult = SearchResult.fromJson(jsonData) as T;
      } catch (e) {
        // Handle JSON decode error
      }
    }
    if (mounted) {
      if (initialResult != null) {
        _fieldKey.currentState?.didChange(widget.controller.text);
        setState(() {
          _hasError = _fieldKey.currentState?.hasError ?? false;
          _isResultSelected = true;
          _selectedResult = initialResult;
        });
        widget.orbitFormManager?.set(widget.orbitKey, initialResult);
        widget.onChanged?.call(initialResult);
      } else {
        widget.controller.clear();
        _fieldKey.currentState?.didChange('');
        setState(() {
          _hasError = _fieldKey.currentState?.hasError ?? false;
          _isResultSelected = false;
          _selectedResult = null;
        });
        widget.orbitFormManager?.set(widget.orbitKey, null);
        widget.onChanged?.call(null);
      }
    }
  }

  void _subscribeToParent() {
    if (widget.orbitFormManager != null && widget.orbitParentKey != null) {
      _parentSubscription = widget.orbitFormManager!.get(widget.orbitParentKey!).listen((parentValue) async {
        if (parentValue == null) {
          if (mounted) {
            setState(() {
              _searchResults = [];
              _allResults = [];
              _isResultSelected = false;
              _selectedResult = null;
              widget.controller.clear();
              _fieldKey.currentState?.didChange('');
              _hasError = _fieldKey.currentState?.hasError ?? false;
            });
            widget.orbitFormManager?.set(widget.orbitKey, null);
            widget.onChanged?.call(null);
            _hideOverlay();
          }
        } else if (widget.isLocal) {
          final results = await widget.onSearch('');
          if (mounted) {
            setState(() {
              _allResults = results;
              _searchResults = results;
            });
            if (_focusNode.hasFocus && !_isResultSelected) {
              _delayedShowOverlay();
            }
          }
        }
      });
    }
  }

  Future<void> _initializeData() async {
    final results = await widget.onSearch('');
    if (mounted) {
      setState(() {
        _allResults = results;
        _searchResults = results;
      });
      if (_focusNode.hasFocus && !_isResultSelected) {
        _delayedShowOverlay();
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.dispose();
    _animationController?.dispose();
    _hideOverlay();
    _parentSubscription?.cancel();
    _overlayDelayTimer?.cancel();
    super.dispose();
  }

  void _delayedShowOverlay() {
    _cancelOverlayDelay();
    _overlayDelayTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && _focusNode.hasFocus && !_isResultSelected) {
        _showOverlay();
      }
    });
  }

  void _cancelOverlayDelay() {
    _overlayDelayTimer?.cancel();
    _overlayDelayTimer = null;
  }

  void _performSearch(String query) {
    _debounceTimer?.cancel();
    if (_isResultSelected && query.isEmpty) {
      setState(() {
        _isResultSelected = false;
        _selectedResult = null;
        _searchResults = widget.isLocal ? _allResults : [];
      });
      widget.orbitFormManager?.set(widget.orbitKey, null);
      widget.onChanged?.call(null);
      if (widget.isLocal && _allResults.isNotEmpty && _focusNode.hasFocus) {
        _delayedShowOverlay();
      } else {
        _hideOverlay();
      }
      return;
    }
    if (widget.isLocal && _allResults.isNotEmpty) {
      setState(() {
        _searchResults = query.isEmpty ? _allResults : _allResults.where((result) => result.title.toLowerCase().contains(query.toLowerCase()) || (result.subtitle?.toLowerCase().contains(query.toLowerCase()) ?? false)).toList();
      });
      if (_focusNode.hasFocus && !_isResultSelected) {
        _delayedShowOverlay();
      } else {
        _hideOverlay();
      }
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        if (mounted) {
          try {
            final results = await widget.onSearch(query);
            if (mounted) {
              setState(() {
                _searchResults = results;
                if (widget.isLocal && query.isEmpty) {
                  _allResults = results;
                }
              });
              if (_focusNode.hasFocus && !_isResultSelected) {
                _delayedShowOverlay();
              } else {
                _hideOverlay();
              }
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _searchResults = [];
              });
              if (_focusNode.hasFocus && !_isResultSelected) {
                _delayedShowOverlay();
              } else {
                _hideOverlay();
              }
            }
          }
        }
      });
    }
  }

  void _showOverlay() {
    _hideOverlay();
    final renderBox = _inputKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final isCompact = widget.isCompact;
    final avatarRadius = isCompact ? 14.r : 16.r;
    final titleFontSize = isCompact ? 14.sp : 14.sp;
    final subtitleFontSize = isCompact ? 12.sp : 12.sp;
    final borderWidth = isCompact ? 1.1.w : 1.2.w;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _hideOverlay();
                  widget.onBlur?.call();
                },
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
              Positioned(
                left: position.dx,
                top: position.dy + size.height + 4.h,
                width: size.width,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(widget.borderRadius.r),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 200.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: borderWidth),
                      borderRadius: BorderRadius.circular(widget.borderRadius.r),
                    ),
                    child: SingleChildScrollView(
                      child:
                          _searchResults.isEmpty && widget.controller.text.isNotEmpty
                              ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off, color: Theme.of(context).colorScheme.onSurfaceVariant, size: isCompact ? 20.sp : 24.sp),
                                    SizedBox(width: 8.w),
                                    Text('No results found', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: isCompact ? 14.sp : 16.sp)),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                padding: EdgeInsets.only(bottom: 8.h, left: 8.w, right: 8.w),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  return ListTile(
                                    onTap: () async {
                                      final prefs = await SharedPreferences.getInstance();
                                      await prefs.setString('search_result_${widget.orbitKey}_${result.id}', jsonEncode(result.toJson()));
                                      widget.controller.text = result.id;
                                      widget.orbitFormManager?.set(widget.orbitKey, result);
                                      widget.onChanged?.call(result);
                                      setState(() {
                                        _isResultSelected = true;
                                        _selectedResult = result;
                                        _searchResults = [];
                                        _hasError = false;
                                        _fieldKey.currentState?.didChange(widget.controller.text);
                                      });
                                      _hideOverlay();
                                      _focusNode.unfocus();
                                      widget.onBlur?.call();
                                    },
                                    leading: result.profilePicture != null ? AwsImageCommonWidget(radius: avatarRadius, imageKey: result.profilePicture!, key: Key(result.id ?? '')) : Icon(Icons.person, size: 16.sp),
                                    title: Text(result.title, style: TextStyle(fontSize: titleFontSize)),
                                    subtitle: result.subtitle != null ? Text(result.subtitle!, style: TextStyle(fontSize: subtitleFontSize)) : null,
                                    trailing: result.isVerified == true ? Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 16.sp) : null,
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

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _clearSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_result_${widget.orbitKey}_${widget.controller.text}');
    widget.controller.clear();
    widget.orbitFormManager?.set(widget.orbitKey, null);
    widget.onChanged?.call(null);
    setState(() {
      _isResultSelected = false;
      _selectedResult = null;
      _searchResults = widget.isLocal ? _allResults : [];
      _hasError = false;
      _fieldKey.currentState?.didChange('');
    });
    _hideOverlay();
    _focusNode.requestFocus();
    if (widget.isLocal && _allResults.isNotEmpty) {
      _delayedShowOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide child input if parent value is null
    if (widget.orbitParentKey != null && widget.orbitFormManager != null) {
      final parentValue = widget.orbitFormManager!.get(widget.orbitParentKey!).value;
      if (parentValue == null) {
        return const SizedBox.shrink();
      }
    }

    final isCompact = widget.isCompact;
    final verticalPadding = isCompact ? 4.h : 8.h;
    final horizontalPadding = isCompact ? 8.w : 12.w;
    final labelFontSize = isCompact ? 10.sp : 12.sp;
    final textFontSize = isCompact ? 14.sp : 16.sp;
    final subtitleFontSize = isCompact ? 12.sp : 14.sp;
    final avatarRadius = isCompact ? 14.r : 16.r;
    final iconSize = isCompact ? 16.sp : 20.sp;
    final errorFontSize = isCompact ? 10.sp : 12.sp;
    final errorPadding = isCompact ? 2.h : 4.h;
    final borderWidth = isCompact ? 1.0.w : 1.2.w;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.verticalMargin ?? 0),
      child: FormField<String>(
        key: _fieldKey,
        validator: widget.validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        builder: (FormFieldState<String> field) {
          _hasError = field.hasError;
          return AnimatedBuilder(
            animation: _animationController!,
            builder: (context, child) {
              final borderColor =
                  _hasError
                      ? Theme.of(context).colorScheme.error
                      : _focusNode.hasFocus || widget.controller.text.isNotEmpty
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5);
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
                        SizedBox(height: 4.h),
                      ],
                    ),
                  Container(
                    key: _inputKey,
                    decoration: BoxDecoration(
                      color: _focusNode.hasFocus || _isResultSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      border: Border.all(color: borderColor, width: borderWidth),
                      borderRadius: BorderRadius.circular(widget.borderRadius.r),
                    ),
                    padding: widget.padding ?? EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                    child: Row(
                      children: [
                        if (_isResultSelected && _selectedResult != null && _selectedResult!.profilePicture != null)
                          Padding(padding: EdgeInsets.only(right: 8.w), child: AwsImageCommonWidget(radius: avatarRadius, imageKey: _selectedResult!.profilePicture!, key: Key(_selectedResult?.id ?? '')))
                        else if (!_isResultSelected)
                          Padding(padding: EdgeInsets.only(right: 8.w), child: Icon(widget.leftIcon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: iconSize)),
                        Expanded(
                          child:
                              _isResultSelected && _selectedResult != null
                                  ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedResult!.title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: textFontSize, fontWeight: FontWeight.w400),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (_selectedResult!.subtitle != null)
                                        Text(
                                          _selectedResult!.subtitle!,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: subtitleFontSize),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  )
                                  : TextField(
                                    controller: widget.controller,
                                    focusNode: _focusNode,
                                    readOnly: _isResultSelected,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: textFontSize, fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      hintText: widget.hintText ?? 'Search...',
                                      hintStyle: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(_focusNode.hasFocus ? 0.9 : 0.7), fontSize: textFontSize, fontWeight: FontWeight.w400),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isCollapsed: true,
                                    ),
                                    onChanged: (value) {
                                      if (!_isResultSelected) {
                                        field.didChange(value);
                                        _performSearch(value);
                                      }
                                    },
                                    onTap: _isResultSelected ? _clearSelection : null,
                                    onTapOutside: (_) {},
                                  ),
                        ),
                        if (_isResultSelected) GestureDetector(onTap: _clearSelection, child: Padding(padding: EdgeInsets.only(left: 8.w), child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant, size: iconSize))),
                      ],
                    ),
                  ),
                  if (_hasError && field.errorText != null)
                    Padding(
                      padding: EdgeInsets.only(top: errorPadding, left: horizontalPadding),
                      child: Text(field.errorText!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error, fontSize: errorFontSize)),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
