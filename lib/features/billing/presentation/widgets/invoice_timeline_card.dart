import 'package:flutter/material.dart';

import '../../data/models/invoice_timeline_model.dart';
import 'invoice_timeline_empty.dart';
import 'invoice_timeline_tile.dart';

class InvoiceTimelineCard extends StatelessWidget {
  const InvoiceTimelineCard({
    super.key,
    required this.timeline,
  });

  final List<InvoiceTimelineModel> timeline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: .35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: timeline.isEmpty
          ? const InvoiceTimelineEmpty()
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timeline.length,
              separatorBuilder: (_, __) => const SizedBox(height: 28),
              itemBuilder: (context, index) {
                return InvoiceTimelineTile(
                  timeline: timeline[index],
                  isLast: index == timeline.length - 1,
                );
              },
            ),
    );
  }
}