import 'dart:async';

import 'package:flutter/material.dart';

class CustomerSearchBar extends StatefulWidget {
  const CustomerSearchBar({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  State<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends State<CustomerSearchBar> {
  final TextEditingController _controller = TextEditingController();

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => widget.onChanged(value.trim()),
    );

    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();

    widget.onChanged('');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      textInputAction: TextInputAction.search,

      decoration: InputDecoration(
        hintText: 'Search by name or phone',

        prefixIcon: const Icon(Icons.search_rounded),

        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: _clearSearch,
                icon: const Icon(Icons.close_rounded),
              ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}