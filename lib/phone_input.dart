import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Simple data model for country codes
class CountryCode {
  final String code;
  final String country;
  final String flag;

  const CountryCode({required this.code, required this.country, required this.flag});
}

class OrbitPhoneInput extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final double borderRadius;
  final ValueChanged<String>? onChanged;
  final bool isCompact;
  final EdgeInsetsGeometry? padding;
  final double? verticalMargin;

  const OrbitPhoneInput({super.key, required this.controller, this.labelText, this.hintText, this.validator, this.borderRadius = 12.0, this.onChanged, this.isCompact = false, this.padding, this.verticalMargin});

  @override
  State<OrbitPhoneInput> createState() => _OrbitPhoneInputState();
}

class _OrbitPhoneInputState extends State<OrbitPhoneInput> {
  final _focusNode = FocusNode();
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  bool _hasError = false;
  OverlayEntry? _overlayEntry;
  CountryCode _selectedCountryCode = const CountryCode(code: '+1', country: 'United States', flag: '🇺🇸'); // Default to US
  final _inputKey = GlobalKey();

  // Sample list of country codes with flags
  final List<CountryCode> _countryCodes = const [
    CountryCode(code: '+1', country: 'United States', flag: '🇺🇸'),
    CountryCode(code: '+44', country: 'United Kingdom', flag: '🇬🇧'),
    CountryCode(code: '+91', country: 'India', flag: '🇮🇳'),
    CountryCode(code: '+86', country: 'China', flag: '🇨🇳'),
    CountryCode(code: '+81', country: 'Japan', flag: '🇯🇵'),
  ];

  // Country-specific phone number length validation
  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    final phoneNumber = value.replaceFirst(RegExp(r'^\+\d+'), '').trim();
    switch (_selectedCountryCode.code) {
      case '+1': // United States: 10 digits
        if (phoneNumber.length != 10) {
          return 'US phone number must be 10 digits';
        }
        break;
      case '+44': // United Kingdom: 10 digits
        if (phoneNumber.length != 10) {
          return 'UK phone number must be 10 digits';
        }
        break;
      case '+91': // India: 10 digits
        if (phoneNumber.length != 10) {
          return 'Indian phone number must be 10 digits';
        }
        break;
      case '+86': // China: 11 digits
        if (phoneNumber.length != 11) {
          return 'Chinese phone number must be 11 digits';
        }
        break;
      case '+81': // Japan: 10 digits
        if (phoneNumber.length != 10) {
          return 'Japanese phone number must be 10 digits';
        }
        break;
      default:
        if (phoneNumber.length < 7) {
          return 'Phone number must be at least 7 digits';
        }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Check initial controller value and validate if non-empty
    if (widget.controller.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final initialValue = widget.controller.text;
          final matchedCode = _countryCodes.firstWhere((code) => initialValue.startsWith(code.code), orElse: () => _countryCodes.first);
          setState(() {
            _selectedCountryCode = matchedCode;
            // Keep full number in controller
            widget.controller.text = initialValue;
            _fieldKey.currentState?.didChange(initialValue);
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
    _removeOverlay();
    super.dispose();
  }

  String _getDisplayPhoneNumber() {
    // Display only the digits after the country code
    return widget.controller.text.replaceFirst(RegExp(r'^\+\d+'), '').trim();
  }

  void _updateControllerWithCountryCode(CountryCode newCountryCode) {
    final currentPhoneNumber = widget.controller.text.replaceFirst(RegExp(r'^\+\d+'), '').trim();
    widget.controller.text = '${newCountryCode.code}$currentPhoneNumber';
  }

  void _showCountryCodePicker() {
    if (_overlayEntry != null) return;

    final RenderBox renderBox = _inputKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    final isCompact = widget.isCompact;
    final itemHorizontalPadding = isCompact ? 10.w : 12.w;
    final itemVerticalPadding = isCompact ? 3.h : 4.h;
    final titleFontSize = isCompact ? 14.sp : 16.sp;
    final borderWidth = isCompact ? 1.w : 1.2.w;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              GestureDetector(onTap: _removeOverlay, behavior: HitTestBehavior.translucent, child: Container(color: Colors.transparent)),
              Positioned(
                left: position.dx,
                top: position.dy + size.height + 4.h,
                width: size.width, // Full width of the input field
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
                        itemCount: _countryCodes.length,
                        itemBuilder: (context, index) {
                          final countryCode = _countryCodes[index];
                          return ListTile(
                            leading: Text(countryCode.flag, style: TextStyle(fontSize: titleFontSize)),
                            title: Text('${countryCode.code} (${countryCode.country})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400, fontSize: titleFontSize)),
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  _selectedCountryCode = countryCode;
                                  _updateControllerWithCountryCode(countryCode);
                                  _hasError = false;
                                  _fieldKey.currentState?.didChange(widget.controller.text);
                                  widget.onChanged?.call(widget.controller.text);
                                });
                              }
                              _removeOverlay();
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
                key: _inputKey,
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
                    GestureDetector(
                      onTap: _showCountryCodePicker,
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Row(
                          children: [
                            Text(_selectedCountryCode.flag, style: TextStyle(fontSize: textFontSize)),
                            SizedBox(width: 4.w),
                            Text(_selectedCountryCode.code, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: textFontSize, fontWeight: FontWeight.w400)),
                            SizedBox(width: 4.w),
                            Icon(_overlayEntry != null ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurfaceVariant, size: iconSize),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.phone,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: textFontSize, fontWeight: FontWeight.w400),
                        decoration: InputDecoration(
                          hintText: widget.hintText ?? 'Enter phone number',
                          hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(_focusNode.hasFocus ? 0.9 : 0.7), fontSize: textFontSize, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          // Prepend country code when user types
                          final newValue = value.startsWith(_selectedCountryCode.code) ? value : '${_selectedCountryCode.code}$value';
                          if (newValue != widget.controller.text) {
                            widget.controller.text = newValue;
                            widget.controller.selection = TextSelection.collapsed(offset: newValue.length);
                          }
                          widget.onChanged?.call(newValue);
                          field.didChange(newValue);
                        },
                        onTapOutside: (event) => _focusNode.unfocus(),
                        inputFormatters: [
                          // Optional: Add a formatter to prevent manual country code edits if needed
                        ],
                      ),
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
