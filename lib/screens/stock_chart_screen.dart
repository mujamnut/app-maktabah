// lib/screens/stock_chart_screen.dart
// ignore_for_file: unused_element, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'add_book_screen.dart'; // Added import for AddBookScreen

class StockChartScreen extends StatefulWidget {
  const StockChartScreen({Key? key}) : super(key: key);

  @override
  State<StockChartScreen> createState() => _StockChartScreenState();
}

class _StockChartScreenState extends State<StockChartScreen> {
  List<Book> books = [];
  List<Book> filteredBooks = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() => isLoading = true);
    books = await BookService().fetchBooks();
    filteredBooks = books;
    setState(() => isLoading = false);
  }

  void _onSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredBooks = books
          .where((b) =>
              (b.title).toLowerCase().contains(query.toLowerCase()) ||
              (b.isbn ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateToAddBook() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBookScreen()),
    );
    if (result != null) {
      fetchBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Books',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 28),
                    onPressed: _navigateToAddBook,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                onChanged: _onSearch,
                decoration: const InputDecoration(
                  prefixIcon:
                      Icon(Icons.search, color: Colors.blueGrey, size: 28),
                  hintText: 'Search books',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 18, color: Colors.blueGrey),
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: filteredBooks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Price: RM${(book.price ?? 0.0).toStringAsFixed(2)} | Status: ${book.status ?? ''} | Stock: ${book.copies ?? 0}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_horiz),
                              onPressed: () async {
                                final selected =
                                    await showModalBottomSheet<String>(
                                  context: context,
                                  builder: (context) => SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.edit),
                                          title: const Text('Edit'),
                                          onTap: () =>
                                              Navigator.pop(context, 'edit'),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete,
                                              color: Colors.red),
                                          title: const Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                          onTap: () =>
                                              Navigator.pop(context, 'delete'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                if (selected == 'edit') {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddBookScreen(bookToEdit: book),
                                    ),
                                  );
                                  if (!mounted) return;
                                  if (result != null) {
                                    await BookService().updateBook(result);
                                    fetchBooks();
                                  }
                                } else if (selected == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Padam Buku'),
                                      content: Text(
                                          'Anda pasti mahu padam "${book.title}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Padam',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (!mounted) return;
                                  if (confirm == true) {
                                    await BookService().deleteBook(book.id);
                                    fetchBooks();
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DummyLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: _LineChartPainter(),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(size.width * 0.2, size.height * 0.2, size.width * 0.4,
        size.height * 0.8, size.width * 0.6, size.height * 0.4);
    path.cubicTo(size.width * 0.8, size.height * 0.1, size.width * 0.9,
        size.height * 0.9, size.width, size.height * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DummyBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Bar(label: 'Fiction', value: 0.8),
        _Bar(label: 'Non-Fiction', value: 0.6),
        _Bar(label: 'Children', value: 0.4),
        _Bar(label: 'Other', value: 0.8),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  const _Bar({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 80 * value,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _DummyDistributorBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _DistributorBar(label: 'Distributor A', value: 0.9),
        _DistributorBar(label: 'Distributor B', value: 0.7),
        _DistributorBar(label: 'Distributor C', value: 0.5),
        _DistributorBar(label: 'Distributor D', value: 0.8),
      ],
    );
  }
}

class _DistributorBar extends StatelessWidget {
  final String label;
  final double value;
  const _DistributorBar({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 15)),
          ),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
