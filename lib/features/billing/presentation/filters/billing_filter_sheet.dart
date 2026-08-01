import 'package:flutter/material.dart';

import 'package:storemate/core/widgets/filter_sheet/app_filter_choice_group.dart';
import 'package:storemate/core/widgets/filter_sheet/app_filter_radio_group.dart';
import 'package:storemate/core/widgets/filter_sheet/app_filter_section.dart';
import 'package:storemate/core/widgets/filter_sheet/app_filter_sheet.dart';

import 'package:storemate/features/billing/presentation/filters/billing_filter_controller.dart';
import 'package:storemate/features/billing/presentation/filters/billing_filter_models.dart';

class BillingFilterSheet extends StatefulWidget {
  const BillingFilterSheet({super.key, required this.initialFilter});

  final BillingFilter initialFilter;

  //---------------------------------------------------------------------------
  // Show
  //---------------------------------------------------------------------------

  static Future<BillingFilter?> show({
    required BuildContext context,
    required BillingFilter currentFilter,
  }) {
    return AppFilterSheet.show<BillingFilter>(
      context: context,
      child: BillingFilterSheet(initialFilter: currentFilter),
    );
  }

  @override
  State<BillingFilterSheet> createState() => _BillingFilterSheetState();
}

class _BillingFilterSheetState extends State<BillingFilterSheet> {
  late final BillingFilterController _controller;

  @override
  void initState() {
    super.initState();

    _controller = BillingFilterController(initialFilter: widget.initialFilter);
  }
  //---------------------------------------------------------------------------
  // Build
  //---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AppFilterSheet(
          title: 'Filter & Sort',
          subtitle: 'Refine how your invoices are displayed.',
          icon: Icons.receipt_long_rounded,

          onReset: () {
            _controller.reset();

            Navigator.of(context).pop(_controller.filter);
          },

          onApply: () {
            Navigator.of(context).pop(_controller.filter);
          },

          isApplyEnabled: true,

          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //------------------------------------------------------------------
              // Invoice Status
              //------------------------------------------------------------------
              AppFilterSection(
                title: 'Invoice Status',
                subtitle: 'Filter invoices by payment status.',
                child: AppFilterChoiceGroup<InvoiceStatusFilter>(
                  options: InvoiceStatusFilter.values,

                  selectedValue: _controller.invoiceStatus,

                  labelBuilder: (status) => status.label,

                  onSelected: _controller.updateInvoiceStatus,
                ),
              ),
              const SizedBox(),

              //------------------------------------------------------------------
              // Payment Method
              //------------------------------------------------------------------
              AppFilterSection(
                title: 'Payment Method',
                subtitle: 'Filter invoices by payment method.',
                child: AppFilterChoiceGroup<PaymentMethodFilter>(
                  options: PaymentMethodFilter.values,

                  selectedValue: _controller.paymentMethod,

                  labelBuilder: (method) => method.label,

                  onSelected: _controller.updatePaymentMethod,
                ),
              ),

              const SizedBox(),

              //------------------------------------------------------------------
              // Sort
              //------------------------------------------------------------------
              AppFilterSection(
                title: 'Sort Invoices',
                subtitle: 'Choose how invoices are ordered.',
                child: AppFilterRadioGroup<InvoiceSortOption>(
                  options: InvoiceSortOption.values,

                  selectedValue: _controller.sortOption,

                  labelBuilder: (option) => option.label,

                  subtitleBuilder: (option) => option.description,

                  leadingBuilder: (option) => Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      option.icon,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  onChanged: _controller.updateSortOption,
                ),
              ),
              const SizedBox(),
            ],
          ),
        );
      },
    );
  }
}
