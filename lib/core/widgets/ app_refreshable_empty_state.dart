import 'package:flutter/material.dart';

class AppRefreshableEmptyState extends StatelessWidget {
  const AppRefreshableEmptyState({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.62,
          child: child,
        ),
      ],
    );
  }
}