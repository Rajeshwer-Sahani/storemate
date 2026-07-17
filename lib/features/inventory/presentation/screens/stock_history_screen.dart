import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:storemate/features/inventory/data/models/stock_adjustment_model.dart';
import 'package:storemate/features/inventory/data/services/inventory_service.dart';
import 'package:storemate/features/inventory/presentation/widgets/%20history_section_header.dart';

import 'package:storemate/features/inventory/presentation/widgets/stock_history_card.dart';




class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  final String productId;
  final String productName;

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

//------------------------------------
// Stock History Screen State
//------------------------------------

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  final InventoryService _inventoryService = InventoryService();

  bool _isLoading = true;

  List<StockAdjustmentModel> _history = [];

  @override
  void initState() {
    super.initState();

    _loadHistory();
  }

  

  //------------------------------------
  // Load Stock History
  //------------------------------------
  Future<void> _loadHistory() async {
    try {
      final response = await _inventoryService.getStockAdjustmentHistory(
        productId: widget.productId,
      );

      if (!mounted) return;

      setState(() {
        _history = response.map(StockAdjustmentModel.fromJson).toList();

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  //------------------------------------
  // Section Title Helper
  //------------------------------------
  String _sectionTitle(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    final value = DateTime(date.year, date.month, date.day);

    if (value == today) {
      return 'Today';
    }

    if (value == yesterday) {
      return 'Yesterday';
    }

    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock History')),
      body: RefreshIndicator(onRefresh: _loadHistory, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text('Loading stock history...'),
          ],
        ),
      );
    }

    if (_history.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),

          Icon(Icons.history_rounded, size: 72),

          SizedBox(height: 24),

          Center(child: Text('No stock adjustments yet.')),
        ],
      );
    }

    final groupedHistory = groupBy(
      _history,
      (StockAdjustmentModel item) => _sectionTitle(item.createdAt),
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: groupedHistory.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HistorySectionHeader(title: entry.key),

            const SizedBox(height: 14),

            ...entry.value.map(
              (adjustment) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: StockHistoryCard(adjustment: adjustment),
              ),
            ),

            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }
}



  