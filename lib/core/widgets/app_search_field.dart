import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.suffixIcon,
    this.readOnly = false,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
  });

  final TextEditingController? controller;

  final String hintText;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onSubmitted;

  final VoidCallback? onTap;

  final Widget? suffixIcon;

  final bool readOnly;

  final bool autofocus;

  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      textInputAction: textInputAction,

      decoration: InputDecoration(
        hintText: hintText,

        prefixIcon: const Icon(
          Icons.search_rounded,
        ),

        suffixIcon: suffixIcon,

        filled: true,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      style: theme.textTheme.bodyLarge,
    );
  }
}