import 'package:flutter/material.dart';

import 'package:storemate/features/billing/data/models/invoice_timeline_model.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_timeline_card.dart';

class InvoiceTimelineScreen extends StatelessWidget {
  const InvoiceTimelineScreen({
    super.key,
    required this.invoiceNumber,
    required this.timeline,
  });

  final String invoiceNumber;
  final List<InvoiceTimelineModel> timeline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Timeline'),
      ),

      body: SafeArea(
        child: timeline.isEmpty
            ? const Center(
                child: Text(
                  'No timeline available.',
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoiceNumber,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Activity history for this invoice',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),

                    const SizedBox(height: 24),

                    InvoiceTimelineCard(
                      timeline: timeline,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}