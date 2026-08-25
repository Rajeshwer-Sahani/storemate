import 'package:flutter/material.dart';

class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search',
    this.hintStyle,
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

  final TextStyle? hintStyle;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onSubmitted;

  final VoidCallback? onTap;

  final Widget? suffixIcon;

  final bool readOnly;

  final bool autofocus;

  final TextInputAction textInputAction;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget? _buildSuffixIcon(ThemeData theme) {
    final hasText = widget.controller?.text.isNotEmpty ?? false;

    if (!hasText && widget.suffixIcon == null) {
      return null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasText)
          IconButton(
            tooltip: 'Clear',
            splashRadius: 20,
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              widget.controller?.clear();
              widget.onChanged?.call('');
              setState(() {});
            },
          ),

        if (widget.suffixIcon != null) widget.suffixIcon!,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 56,
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        onTapOutside: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        textInputAction: widget.textInputAction,

        decoration: InputDecoration(
          hintStyle:
              widget.hintStyle ??
              TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),

          hintText: widget.hintText,

          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.search_rounded,
              size: 26,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 58),

          suffixIcon: _buildSuffixIcon(theme),

          fillColor: theme.colorScheme.surface,
          filled: true,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),

        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}
