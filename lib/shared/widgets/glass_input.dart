import 'package:flutter/material.dart';
import '../../core/theme/liquid_glass_theme.dart';

/// Glass-styled TextFormField wrapper.
/// Provides the Liquid Glass look: dark fill, subtle border, accent focus glow.
class GlassInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final int? maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final bool alignLabelWithHint;

  const GlassInput({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.maxLines = 1,
    this.validator,
    this.onFieldSubmitted,
    this.alignLabelWithHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autocorrect: autocorrect,
      maxLines: maxLines,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: LiquidGlass.body(),
      cursorColor: LiquidGlass.accentBlue,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        alignLabelWithHint: alignLabelWithHint,
      ),
    );
  }
}
