import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'transaction_detail_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SalesHistoryScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const SalesHistoryScreen({Key? key, this.onBack}) : super(key: key);

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  List<dynamic> transactions = [];
  Map<String, List<dynamic>> transactionItems = {};
  bool isLoading = true;
  DateTime? selectedDate;
  String? selectedMethod;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    // 1. Fetch all transactions
    final txs = await Supabase.instance.client
        .from('sales_transactions')
        .select(
            'id, receipt_id, amount_paid, payment_type, created_at, total_amount, change_returned')
        .order('created_at', ascending: false);

    // 2. Fetch all items for these transactions
    final txIds = txs.map((tx) => tx['id']).toList();
    final items = txIds.isEmpty
        ? []
        : await Supabase.instance.client
            .from('sales_transaction_items')
            .select('transaction_id, book_title, quantity, price_each')
            .in_('transaction_id', txIds);

    // 3. Group items by transaction_id
    final Map<String, List<dynamic>> grouped = {};
    for (final item in items) {
      final txId = item['transaction_id'];
      grouped.putIfAbsent(txId, () => []).add(item);
    }

    setState(() {
      transactions = txs;
      transactionItems = grouped;
      isLoading = false;
    });
  }

  double _getTotalPayments() {
    double total = 0.0;
    for (final tx in transactions) {
      final items = transactionItems[tx['id']] ?? [];
      for (final item in items) {
        final qty = (item['quantity'] ?? 0) as num;
        final price = (item['price_each'] ?? 0) as num;
        total += qty * price;
      }
    }
    return total;
  }

  int _getTotalBookSold() {
    int total = 0;
    for (final tx in transactions) {
      final items = transactionItems[tx['id']] ?? [];
      for (final item in items) {
        final qty = (item['quantity'] ?? 0) as num;
        total += qty.toInt();
      }
    }
    return total;
  }

  List<dynamic> get filteredTransactions {
    return transactions.where((tx) {
      bool matchDate = selectedDate == null ||
          (tx['created_at']?.split('T')?.first ==
              selectedDate!.toIso8601String().split('T').first);
      bool matchMethod =
          selectedMethod == null || tx['payment_type'] == selectedMethod;
      return matchDate && matchMethod;
    }).toList();
  }

  List<String> get allMethods {
    final set = <String>{};
    for (final tx in transactions) {
      if (tx['payment_type'] != null) set.add(tx['payment_type']);
    }
    return set.toList();
  }

  Widget _buildSoldBooksSummary() {
    final Map<String, Map<String, dynamic>> soldBooks = {};
    for (final tx in transactions) {
      final items = transactionItems[tx['id']] ?? [];
      for (final item in items) {
        final title = item['book_title'] ?? 'Unknown';
        final qty = (item['quantity'] ?? 0) as int;
        final price = (item['price_each'] ?? 0) as num;
        if (!soldBooks.containsKey(title)) {
          soldBooks[title] = {'qty': 0, 'total': 0.0};
        }
        soldBooks[title]!['qty'] += qty;
        soldBooks[title]!['total'] += qty * price;
      }
    }
    final entries = soldBooks.entries.toList()
      ..sort((a, b) => b.value['qty'].compareTo(a.value['qty']));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.10 * 255).toInt()),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          if (Theme.of(context).brightness == Brightness.dark)
            BoxShadow(
              color: Colors.white.withAlpha((0.08 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
        ],
        // Tiada border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Buku Terjual',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text('Tiada buku terjual.',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color)),
          ...entries.asMap().entries.map((entry) {
            final e = entry.value;
            return Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.book_outlined,
                        size: 22,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(e.key,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha((0.12 * 255).toInt()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('x${e.value['qty']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary)),
                    ),
                    const SizedBox(width: 12),
                    Text('RM${(e.value['total'] as num).toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color)),
                  ],
                ),
                if (entry.key != entries.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                        height: 1, color: Theme.of(context).dividerColor),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Sales History',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  child: IconButton(
                    icon: Icon(Icons.add,
                        size: 28,
                        color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () {}, // Tambah fungsi jika perlu
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'overview'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        title: 'total_payment'.tr(),
                        amount: 'RM${_getTotalPayments().toStringAsFixed(2)}',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCard(
                        title: 'total_book_sold'.tr(),
                        amount: _getTotalBookSold().toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'completed_payment'.tr(),
                  amount: 'RM${_getTotalPayments().toStringAsFixed(2)}',
                ),
                const SizedBox(height: 40),
                _buildSoldBooksSummary(),
                Text(
                  'payment_history'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: _buildFilterButton(selectedDate == null
                          ? 'Date'
                          : selectedDate!.toIso8601String().split('T').first),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () async {
                        final method = await showModalBottomSheet<String>(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...allMethods.map((m) => ListTile(
                                        title: Text(m),
                                        onTap: () => Navigator.pop(context, m),
                                      )),
                                  ListTile(
                                    title: const Text('All Methods'),
                                    onTap: () => Navigator.pop(context, null),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                        setState(() => selectedMethod = method);
                      },
                      child: _buildFilterButton(selectedMethod ?? 'Method'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...filteredTransactions.map((tx) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailScreen(
                                transaction: tx,
                                items: transactionItems[tx['id']] ?? [],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withAlpha((0.04 * 255).toInt()),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'sale'.tr(
                                          args: [tx['receipt_id'] ?? tx['id']]),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDateTimeLocal(tx['created_at']),
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(transactionItems[tx['id']] ?? []).length} ${((transactionItems[tx['id']] ?? []).length == 1 ? 'item'.tr() : 'items'.tr())}',
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'RM${((transactionItems[tx['id']] ?? []).fold<num>(0, (sum, item) => sum + ((item['quantity'] ?? 0) as num) * ((item['price_each'] ?? 0) as num))).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.blueGrey, size: 28),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
              ],
            ),
    );
  }

  Widget _buildCard({required String title, required String amount}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.10 * 255).toInt()),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          if (Theme.of(context).brightness == Brightness.dark)
            BoxShadow(
              color: Colors.white.withAlpha((0.08 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
        ],
        // Tiada border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface
            .withAlpha((0.12 * 255).toInt()),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  String _formatDateTimeLocal(String? dateTimeStr) {
    if (dateTimeStr == null) return '-';
    final dt = DateTime.tryParse(dateTimeStr)?.toLocal();
    if (dt == null) return dateTimeStr;
    final date = '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$date, $hour:$minute $ampm';
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
