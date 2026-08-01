import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BillingSummaryCarousel extends StatefulWidget {
  const BillingSummaryCarousel({
    super.key,
    required this.totalSales,
    required this.totalInvoices,
    required this.pendingAmount,
  });

  final double totalSales;
  final int totalInvoices;
  final double pendingAmount;

  @override
  State<BillingSummaryCarousel> createState() => _BillingSummaryCarouselState();
}

class _BillingSummaryCarouselState extends State<BillingSummaryCarousel> {
  //---------------------------------------------------------------------------
  // Controllers
  //---------------------------------------------------------------------------

  late final PageController _pageController;

  Timer? _autoScrollTimer;

  bool _isUserInteracting = false;

  int _currentPage = 0;

  static const int _pageCount = 3;

  //---------------------------------------------------------------------------
  // Currency Formatter
  //---------------------------------------------------------------------------

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  String _formatCurrency(num value) {
    return _currencyFormatter.format(value);
  }

  //---------------------------------------------------------------------------
  // Lifecycle
  //---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: .90);

    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  //---------------------------------------------------------------------------
  // Auto Scroll
  //---------------------------------------------------------------------------

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;

      if (_isUserInteracting) return;

      if (!_pageController.hasClients) return;

      _currentPage++;

      if (_currentPage >= _pageCount) {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Restart timer after manual swipe
    _startAutoScroll();
  }

  //---------------------------------------------------------------------------
  // Build
  //---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,

          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _isUserInteracting = true;
              }

              if (notification is ScrollEndNotification) {
                _isUserInteracting = false;
              }

              return false;
            },
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,

              children: [
                _buildSalesCard(),

                _buildInvoicesCard(),

                _buildPendingDueCard(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        AnimatedSmoothIndicator(
          activeIndex: _currentPage,
          count: _pageCount,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            spacing: 8,
            radius: 20,
            activeDotColor: Theme.of(context).colorScheme.primary,
            dotColor: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ],
    );
  }

  //--------------------------------------------------------------------------
  // Sales Card
  //--------------------------------------------------------------------------

  Widget _buildSalesCard() {
    return _BillingSummaryCard(
      icon: Icons.payments_rounded,
      iconColor: Colors.green,
      title: 'Today\'s Sales',
      value: _formatCurrency(widget.totalSales),
      subtitle:
          '${widget.totalInvoices} invoice${widget.totalInvoices == 1 ? '' : 's'} generated today',
    );
  }

  //--------------------------------------------------------------------------
  // Today's Invoices
  //--------------------------------------------------------------------------

  Widget _buildInvoicesCard() {
    return _BillingSummaryCard(
      icon: Icons.receipt_long_rounded,
      iconColor: Colors.blue,
      title: 'Today\'s Bills',
      value: widget.totalInvoices.toString(),
      subtitle:
          '${widget.totalInvoices == 1 ? 'Invoice' : 'Invoices'} generated today',
    );
  }

  //--------------------------------------------------------------------------
  // Pending Due
  //--------------------------------------------------------------------------

  Widget _buildPendingDueCard() {
    return _BillingSummaryCard(
      icon: Icons.pending_actions_rounded,
      iconColor: Colors.orange,
      title: 'Pending Due',
      value: _formatCurrency(widget.pendingAmount),
      subtitle: 'Outstanding customer payments',
    );
  }
}

//==============================================================================
// Billing Summary Card
//==============================================================================

class _BillingSummaryCard extends StatelessWidget {
  const _BillingSummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: .5),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              //----------------------------------------------------------------
              // Icon
              //----------------------------------------------------------------
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 25),
              ),

              const SizedBox(width: 20),

              //----------------------------------------------------------------
              // Text
              //----------------------------------------------------------------
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
