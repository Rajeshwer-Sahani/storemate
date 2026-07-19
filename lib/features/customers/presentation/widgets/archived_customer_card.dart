import 'package:flutter/material.dart';

import '../../data/models/customer_model.dart';
import 'customer_avatar.dart';

class ArchivedCustomerCard extends StatelessWidget {
  const ArchivedCustomerCard({
    super.key,
    required this.customer,
    required this.onRestore,
  });

  final CustomerModel customer;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: null,
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

              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: 'Restore',
                  onPressed: onRestore,
                  icon: Icon(
                    Icons.restore_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
