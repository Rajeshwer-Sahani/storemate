import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/%20app_refreshable_empty_state.dart';

import 'package:storemate/core/widgets/app_empty_state.dart';

class EmiEmptyState extends StatelessWidget {
  const EmiEmptyState({
    super.key,
    required this.onCreateEmiPlan,
    required this.onRefresh,
  });

  final VoidCallback onCreateEmiPlan;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: AppRefreshableEmptyState(
        child: AppEmptyState(
          icon: Icons.payments_outlined,
          title: 'No EMI plans yet',
          message:
              'Your active and completed EMI plans will appear here.\n'
              'Create an EMI plan to start tracking customer repayments.',
          buttonText: 'Create EMI Plan',
          onPressed: onCreateEmiPlan,
        ),
      ),
    );
  }
}