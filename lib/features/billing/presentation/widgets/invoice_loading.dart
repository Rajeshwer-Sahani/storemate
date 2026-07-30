import 'package:flutter/material.dart';

class InvoiceLoading extends StatelessWidget {
  const InvoiceLoading({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const _InvoiceLoadingCard();
      },
    );
  }
}

class _InvoiceLoadingCard extends StatelessWidget {
  const _InvoiceLoadingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          _LoadingBox(width: 56, height: 56, borderRadius: 16),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoadingBox(width: 120, height: 18),

                const SizedBox(height: 10),

                _LoadingBox(width: 170, height: 14),

                const SizedBox(height: 8),

                _LoadingBox(width: 110, height: 14),

                const SizedBox(height: 14),

                Row(
                  children: [
                    _LoadingBox(width: 75, height: 26, borderRadius: 100),

                    const Spacer(),

                    _LoadingBox(width: 80, height: 18),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
