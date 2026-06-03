import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/app_colors.dart';

class QyzmetTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;

  const QyzmetTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
  });

  @override
  State<QyzmetTextField> createState() => _QyzmetTextFieldState();
}

class _QyzmetTextFieldState extends State<QyzmetTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      autofocus: widget.autofocus,
      textCapitalization: widget.textCapitalization,
      focusNode: widget.focusNode,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              )
            : widget.suffixIcon,
        counterText: '',
      ),
    );
  }
}
