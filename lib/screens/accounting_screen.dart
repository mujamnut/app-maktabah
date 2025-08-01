import 'package:flutter/material.dart';
import 'sales_details_screen.dart';
import 'expenses_details_screen.dart';
import 'inventory_valuation_details_screen.dart';
import 'pl_statement_details_screen.dart';
import 'taxes_sst_details_screen.dart';

class AccountingScreen extends StatelessWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_AccountingCardData> cards = [
      const _AccountingCardData(
        title: 'Sales & Payment Records',
        amount: 'RM 12,345.67',
        subtitle: 'Total Sales',
        image:
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=200&q=80',
      ),
      const _AccountingCardData(
        title: 'Company Expenses',
        amount: 'RM 4,567.89',
        subtitle: 'Total Expenses',
        image:
            'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=200&q=80',
      ),
      const _AccountingCardData(
        title: 'Inventory Valuation',
        amount: 'RM 8,765.43',
        subtitle: 'Total Inventory Value',
        image:
            'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=200&q=80',
      ),
      const _AccountingCardData(
        title: 'P&L Statement',
        amount: 'RM 7,777.77',
        subtitle: 'Net Profit',
        image:
            'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=200&q=80',
      ),
      const _AccountingCardData(
        title: 'Taxes & SST',
        amount: 'RM 1,234.56',
        subtitle: 'Total Taxes Due',
        image:
            'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=200&q=80',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            backgroundColor: Color(0xFFF8F9FA),
            elevation: 0,
            floating: true,
            snap: true,
            pinned: false,
            centerTitle: true,
            title: Text(
              'Accounting',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          SliverToBoxAdapter(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111418),
                  ),
                ),
                const SizedBox(height: 16),
                ...cards.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final card = entry.value;
                  return _AccountingCard(
                    card: card,
                    onViewDetails: idx == 0
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SalesDetailsScreen()),
                            )
                        : idx == 1
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ExpensesDetailsScreen()),
                                )
                            : idx == 2
                                ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const InventoryValuationDetailsScreen()),
                                    )
                                : idx == 3
                                    ? () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const PLStatementDetailsScreen()),
                                        )
                                    : idx == 4
                                        ? () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const TaxesSSTDetailsScreen()),
                                            )
                                        : null,
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountingCardData {
  final String title;
  final String amount;
  final String subtitle;
  final String image;
  const _AccountingCardData({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.image,
  });
}

class _AccountingCard extends StatelessWidget {
  final _AccountingCardData card;
  final VoidCallback? onViewDetails;
  const _AccountingCard({required this.card, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.amount,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  card.subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F3F6),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              card.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
