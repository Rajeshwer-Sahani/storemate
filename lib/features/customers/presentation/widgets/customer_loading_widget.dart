import 'package:flutter/material.dart';

class CustomerLoadingWidget extends StatelessWidget {
  const CustomerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _CustomerLoadingCard(),
    );
  }
}

class _CustomerLoadingCard extends StatelessWidget {
  const _CustomerLoadingCard();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LoadingBar(
                    width: 160,
                    height: 16,
                    color: color,
                  ),

                  const SizedBox(height: 12),

                  _LoadingBar(
                    width: 120,
                    height: 14,
                    color: color,
                  ),

                  const SizedBox(height: 8),

                  _LoadingBar(
                    width: 180,
                    height: 14,
                    color: color,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}