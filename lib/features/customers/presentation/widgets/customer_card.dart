import 'package:flutter/material.dart';
import 'package:storemate/features/customers/presentation/widgets/customer_avatar.dart';

import '../../data/models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.customer, this.onTap});

  final CustomerModel customer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomerAvatar(fullName: customer.fullName, radius: 26),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: Text(
                            customer.phoneNumber,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    if (customer.email != null &&
                        customer.email!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              customer.email!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
