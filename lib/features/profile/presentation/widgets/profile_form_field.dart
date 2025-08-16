import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';

class ProfileFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final bool required;
  final bool enabled;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function()? onTap;
  final bool readOnly;
  final Widget? suffix;
  final TextDirection? textDirection;
  final bool obscureText;
  final bool showCounter;
  final Color? glowColor;

  const ProfileFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.required = false,
    this.enabled = true,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.suffix,
    this.textDirection,
    this.obscureText = false,
    this.showCounter = true,
    this.glowColor,
  });

  @override
  State<ProfileFormField> createState() => _ProfileFormFieldState();
}

class _ProfileFormFieldState extends State<ProfileFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _animationController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      _validateField();
    }
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(widget.controller.text);
    }
    
    // Clear error when user starts typing
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _errorText = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = widget.glowColor ?? AppColors.neonTurquoise;
    final hasError = _errorText != null;
    
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(),
            const SizedBox(height: 8),
            _buildField(effectiveGlowColor, hasError),
            if (hasError) ...[
              const SizedBox(height: 8),
              _buildErrorMessage(),
            ],
            if (widget.maxLength != null && widget.showCounter && !hasError) ...[
              const SizedBox(height: 4),
              _buildCharacterCounter(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Icon(
          widget.icon,
          color: _isFocused 
              ? (widget.glowColor ?? AppColors.neonTurquoise)
              : AppColors.secondaryText,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          widget.required ? '${widget.label} *' : widget.label,
          style: GoogleFonts.assistant(
            color: _isFocused
                ? (widget.glowColor ?? AppColors.neonTurquoise)
                : AppColors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.required)
          Text(
            ' *',
            style: GoogleFonts.assistant(
              color: AppColors.error,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildField(Color glowColor, bool hasError) {
    return NeonGlowContainer(
      glowColor: hasError ? AppColors.error : glowColor,
      glowRadius: _isFocused ? 15 : 8,
      opacity: _isFocused ? 0.3 : 0.15,
      animate: _isFocused,
      isSubtle: true,
      borderRadius: BorderRadius.circular(12),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        textDirection: widget.textDirection ?? TextDirection.rtl,
        style: GoogleFonts.assistant(
          color: widget.enabled 
              ? AppColors.primaryText 
              : AppColors.disabledText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        onTap: widget.onTap,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.assistant(
            color: AppColors.secondaryText.withOpacity(0.7),
            fontSize: 16,
          ),
          border: _buildBorder(AppColors.inputBorder),
          enabledBorder: _buildBorder(
            hasError 
                ? AppColors.error.withOpacity(0.5)
                : AppColors.inputBorder.withOpacity(0.5),
          ),
          focusedBorder: _buildBorder(
            hasError ? AppColors.error : glowColor,
            width: 2,
          ),
          errorBorder: _buildBorder(AppColors.error),
          focusedErrorBorder: _buildBorder(AppColors.error, width: 2),
          disabledBorder: _buildBorder(AppColors.inputBorder.withOpacity(0.3)),
          filled: true,
          fillColor: widget.enabled 
              ? AppColors.darkSurface.withOpacity(0.8)
              : AppColors.darkSurface.withOpacity(0.3),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: widget.maxLines > 1 ? 16 : 14,
          ),
          suffixIcon: widget.suffix,
          counterText: '', // Hide default counter
        ),
        validator: widget.validator,
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _errorText!,
            style: GoogleFonts.assistant(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterCounter() {
    final currentLength = widget.controller.text.length;
    final maxLength = widget.maxLength!;
    final isNearLimit = currentLength > (maxLength * 0.8);
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '$currentLength / $maxLength',
        style: GoogleFonts.assistant(
          color: isNearLimit ? AppColors.warning : AppColors.secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}

// Specialized form fields for common use cases
class NameFormField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;

  const NameFormField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileFormField(
      controller: controller,
      label: 'שם מלא',
      icon: Icons.person_outline,
      hint: 'הזינו את שמכם המלא',
      required: true,
      glowColor: AppColors.neonTurquoise,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'אנא הזינו שם מלא';
        }
        if (value.trim().length < 2) {
          return 'השם חייב להכיל לפחות 2 תווים';
        }
        if (!RegExp(r'^[א-ת\s\-\'\"\.]+$').hasMatch(value.trim())) {
          return 'השם יכול להכיל רק אותיות בעברית, רווחים ומקפים';
        }
        return null;
      },
    );
  }
}

class PhoneFormField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;

  const PhoneFormField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileFormField(
      controller: controller,
      label: 'טלפון',
      icon: Icons.phone_outlined,
      hint: '050-123-4567',
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      glowColor: AppColors.neonPink,
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\+\s\(\)]')),
        LengthLimitingTextInputFormatter(15),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (value.length < 9) {
            return 'מספר טלפון חייב להכיל לפחות 9 ספרות';
          }
          if (!RegExp(r'^[0-9\-\+\s\(\)]+$').hasMatch(value)) {
            return 'מספר טלפון לא תקין';
          }
          // Basic Israeli phone number validation
          final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
          if (digitsOnly.length < 9 || digitsOnly.length > 10) {
            return 'מספר טלפון לא תקין';
          }
        }
        return null;
      },
    );
  }
}

class AddressFormField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;

  const AddressFormField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileFormField(
      controller: controller,
      label: 'כתובת',
      icon: Icons.location_on_outlined,
      hint: 'רחוב, מספר בית, עיר',
      maxLines: 2,
      maxLength: 200,
      glowColor: AppColors.neonPurple,
      onChanged: onChanged,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (value.length < 5) {
            return 'כתובת חייבת להכיל לפחות 5 תווים';
          }
          if (value.length > 200) {
            return 'כתובת לא יכולה להיות ארוכה מ-200 תווים';
          }
        }
        return null;
      },
    );
  }
}

class BioFormField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;

  const BioFormField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileFormField(
      controller: controller,
      label: 'ביוגרפיה',
      icon: Icons.edit_note,
      hint: 'ספרו קצת על עצמכם, התחביבים שלכם, החלומות שלכם...',
      maxLines: 4,
      maxLength: 500,
      glowColor: AppColors.neonPink,
      onChanged: onChanged,
      validator: (value) {
        if (value != null && value.length > 500) {
          return 'הביוגרפיה לא יכולה להיות ארוכה מ-500 תווים';
        }
        return null;
      },
    );
  }
}

class EmailDisplayField extends StatelessWidget {
  final String email;

  const EmailDisplayField({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileFormField(
      controller: TextEditingController(text: email),
      label: 'אימייל',
      icon: Icons.email_outlined,
      hint: 'כתובת האימייל לא ניתנת לשינוי',
      enabled: false,
      readOnly: true,
      textDirection: TextDirection.ltr,
      glowColor: AppColors.secondaryText,
    );
  }
}

// Date picker field
class DatePickerField extends StatefulWidget {
  final String label;
  final IconData icon;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hint;
  final bool required;

  const DatePickerField({
    super.key,
    required this.label,
    required this.icon,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.hint,
    this.required = false,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _updateController();
  }

  void _updateController() {
    _controller = TextEditingController(
      text: widget.selectedDate != null
          ? '${widget.selectedDate!.day.toString().padLeft(2, '0')}/${widget.selectedDate!.month.toString().padLeft(2, '0')}/${widget.selectedDate!.year}'
          : '',
    );
  }

  @override
  void didUpdateWidget(DatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _updateController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileFormField(
      controller: _controller,
      label: widget.label,
      icon: widget.icon,
      hint: widget.hint ?? 'לחצו לבחירת תאריך',
      required: widget.required,
      readOnly: true,
      glowColor: AppColors.neonTurquoise,
      suffix: Icon(
        Icons.calendar_today,
        color: AppColors.secondaryText,
        size: 18,
      ),
      onTap: _selectDate,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime(2000),
      firstDate: widget.firstDate ?? DateTime(1950),
      lastDate: widget.lastDate ?? DateTime.now(),
      locale: const Locale('he', 'IL'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonTurquoise,
              onPrimary: AppColors.darkBackground,
              surface: AppColors.authCardBackground,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != widget.selectedDate) {
      widget.onDateSelected(picked);
    }
  }
}