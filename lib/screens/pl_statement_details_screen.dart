import 'package:flutter/material.dart';

class PLStatementDetailsScreen extends StatefulWidget {
  const PLStatementDetailsScreen({super.key});

  @override
  State<PLStatementDetailsScreen> createState() =>
      _PLStatementDetailsScreenState();
}

class _PLStatementDetailsScreenState extends State<PLStatementDetailsScreen> {
  int selectedRange = 0; // 0: Monthly, 1: Quarterly, 2: Yearly
  String selectedPeriod = 'July 2024';
  final List<String> periods = ['July 2024', 'June 2024', 'May 2024'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profit & Loss',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const SizedBox(height: 8),
          const Text(
            'Date Range',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _buildRangeTabs(),
          const SizedBox(height: 16),
          _buildDropdown(periods, selectedPeriod,
              (val) => setState(() => selectedPeriod = val!)),
          const SizedBox(height: 24),
          const Text(
            'Statement',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatementSection(),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F0FE),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Download',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1978E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Print',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeTabs() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          _buildTab('Monthly', 0),
          _buildTab('Quarterly', 1),
          _buildTab('Yearly', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int idx) {
    final bool selected = selectedRange == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRange = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.blueGrey,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStatementSection() {
    // Dummy data, boleh ganti dengan data sebenar
    const bookSales = 12500.0;
    const marketing = 1500.0;
    const printing = 2000.0;
    const distribution = 1000.0;
    const totalExpenses = marketing + printing + distribution;
    const netProfit = bookSales - totalExpenses;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text('Revenue',
            style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
        const SizedBox(height: 8),
        _buildStatementRow('Book Sales', bookSales),
        const Divider(height: 32),
        const Text('Expenses',
            style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
        const SizedBox(height: 8),
        _buildStatementRow('Marketing', marketing),
        _buildStatementRow('Printing', printing),
        _buildStatementRow('Distribution', distribution),
        const Divider(height: 32),
        _buildStatementRow('Total Expenses', totalExpenses, isBold: true),
        const Divider(height: 32),
        _buildStatementRow('Net Profit (Loss)', netProfit, isBold: true),
      ],
    );
  }

  Widget _buildStatementRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 17 : 16,
              ),
            ),
          ),
          Text(
            ' 4${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 17 : 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
