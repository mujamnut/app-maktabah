import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryValuationDetailsScreen extends StatefulWidget {
  const InventoryValuationDetailsScreen({super.key});

  @override
  State<InventoryValuationDetailsScreen> createState() =>
      _InventoryValuationDetailsScreenState();
}

class _InventoryValuationDetailsScreenState
    extends State<InventoryValuationDetailsScreen> {
  List<_BookStock> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final response = await Supabase.instance.client
          .from('books')
          .select('title, price, status');
      setState(() {
        books = (response as List)
            .map((b) => _BookStock(
                  b['title'] ?? '-',
                  (b['price'] ?? 0) is int
                      ? b['price']
                      : (b['price'] ?? 0).toInt(),
                  b['status'] ?? 'In Stock',
                ))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalValue = books.fold(0, (sum, book) => sum + book.price);
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
          'Inventory Valuation',
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
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total Inventory Value',
                  value: ' ${totalValue.toStringAsFixed(2)}',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  label: 'Unique Titles',
                  value: books.length.toString(),
                  isBold: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Books in Stock',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : books.isEmpty
                  ? const Text('No books found.',
                      style: TextStyle(color: Colors.grey))
                  : Column(
                      children: books
                          .map((book) => _BookStockTile(book: book))
                          .toList(),
                    ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _SummaryCard(
      {required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookStock {
  final String title;
  final int price;
  final String status;
  _BookStock(this.title, this.price, this.status);
}

class _BookStockTile extends StatelessWidget {
  final _BookStock book;
  const _BookStockTile({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                book.status,
                style: TextStyle(
                  color:
                      book.status == 'Low Stock' ? Colors.red : Colors.blueGrey,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Text(
            book.price == 0 ? 'N/A' : ' ${book.price.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
