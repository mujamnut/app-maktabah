import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SalesDetailsScreen extends StatefulWidget {
  const SalesDetailsScreen({super.key});

  @override
  State<SalesDetailsScreen> createState() => _SalesDetailsScreenState();
}

class _SalesDetailsScreenState extends State<SalesDetailsScreen> {
  DateTime? selectedDate;
  String? selectedCustomer;
  String? selectedItem;
  String? selectedMethod;
  String? selectedStatus;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final List<String> customers = [
    'Sophia Clark',
    'Ethan Miller',
    'Olivia Davis'
  ];
  final List<String> items = ['Book A', 'Book B', 'Book C'];
  final List<String> methods = ['Cash', 'Credit Card', 'Online'];
  final List<String> statuses = ['Paid', 'Pending', 'Cancelled'];

  final List<_Transaction> transactions = [
    _Transaction(
        date: DateTime(2024, 7, 14), name: 'Sophia Clark', amount: 25.00),
    _Transaction(
        date: DateTime(2024, 7, 13), name: 'Ethan Miller', amount: 18.50),
    _Transaction(
        date: DateTime(2024, 7, 12), name: 'Olivia Davis', amount: 32.00),
  ];

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
        title: Text(
          'sales_payment_records'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          GestureDetector(
            onTap: () => _showAddTransactionDialog(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Text(
                  'add_transaction'.tr(),
                  style: const TextStyle(
                    color: Color(0xFF222B45),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'recent_transactions'.tr(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...transactions.map((tx) => _buildTransactionTile(tx)).toList(),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'add_transaction'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabel('date'.tr()),
                _buildDatePicker(context),
                const SizedBox(height: 16),
                _buildLabel('customer'.tr()),
                _buildDropdown(
                    customers,
                    selectedCustomer,
                    (val) => setState(() => selectedCustomer = val),
                    'select_customer'.tr()),
                const SizedBox(height: 16),
                _buildLabel('items_sold'.tr()),
                _buildDropdown(
                    items,
                    selectedItem,
                    (val) => setState(() => selectedItem = val),
                    'select_item'.tr()),
                const SizedBox(height: 16),
                _buildLabel('quantity'.tr()),
                _buildTextField(quantityController, 'enter_quantity'.tr(),
                    TextInputType.number),
                const SizedBox(height: 16),
                _buildLabel('price'.tr()),
                _buildTextField(
                    priceController, 'enter_price'.tr(), TextInputType.number),
                const SizedBox(height: 16),
                _buildLabel('payment_method'.tr()),
                _buildDropdown(
                    methods,
                    selectedMethod,
                    (val) => setState(() => selectedMethod = val),
                    'select_method'.tr()),
                const SizedBox(height: 16),
                _buildLabel('status'.tr()),
                _buildDropdown(
                    statuses,
                    selectedStatus,
                    (val) => setState(() => selectedStatus = val),
                    'select_status'.tr()),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Tambah logik simpan transaksi di sini jika perlu
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1978E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('record_sale'.tr(),
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
      );

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) setState(() => selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? 'select_date'.tr()
                  : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: selectedDate == null ? Colors.grey : Colors.black,
                fontSize: 16,
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? value,
      Function(String?) onChanged, String hint) {
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
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  Widget _buildTransactionTile(_Transaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(tx.date),
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              Text(
                tx.name,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          Text(
            ' 24${tx.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }
}

class _Transaction {
  final DateTime date;
  final String name;
  final double amount;
  _Transaction({required this.date, required this.name, required this.amount});
}
