import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PosPaymentsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final String? initialTab;
  const PosPaymentsScreen({Key? key, this.onBack, this.initialTab})
      : super(key: key);

  @override
  State<PosPaymentsScreen> createState() => _PosPaymentsScreenState();
}

class _PosPaymentsScreenState extends State<PosPaymentsScreen> {
  List<Book> books = [];
  final Map<String, int> cart = {};
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchBooks();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  Future<void> fetchBooks() async {
    setState(() => isLoading = true);
    books = await BookService().fetchBooks();
    setState(() => isLoading = false);
  }

  List<Book> get filteredBooks {
    if (searchQuery.isEmpty) return books;
    return books
        .where((b) => b.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void addToCart(String title) {
    setState(() {
      cart.update(title, (qty) => qty + 1, ifAbsent: () => 1);
    });
  }

  double get subtotal {
    double total = 0;
    cart.forEach((title, qty) {
      final book = books.firstWhere((b) => b.title == title,
          orElse: () => Book(
                id: '',
                title: '',
                author: '',
                description: '',
                coverUrl: '',
                category: '',
                isbn: '',
                status: '',
                location: '',
                coverColor: '#FFFFFF',
                copies: 1,
                totalCopies: 1,
                dateAdded: DateTime.now(),
                price: 0.0,
                cost_price: 0.0,
              ));
      total += (book.price ?? 0.0) * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: Text('POS',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : isTablet
                  ? _buildTabletLayout()
                  : _buildPhoneLayout(),
          backgroundColor: Theme.of(context).colorScheme.surface,
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Senarai item dipilih
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Item',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 16),
                // ignore: prefer_const_constructors
                Row(
                  children: [
                    Expanded(
                        child: Text('Item',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(context).colorScheme.onSurface))),
                    Text('Harga',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
                Divider(color: Theme.of(context).dividerColor),
                Expanded(
                  child: ListView(
                    children: cart.entries.map((entry) {
                      final book = books.firstWhere((b) => b.title == entry.key,
                          orElse: () => Book(
                                id: '',
                                title: '',
                                author: '',
                                description: '',
                                coverUrl: '',
                                category: '',
                                isbn: '',
                                status: '',
                                location: '',
                                coverColor: '#FFFFFF',
                                copies: 1,
                                totalCopies: 1,
                                dateAdded: DateTime.now(),
                                price: 0.0,
                                cost_price: 0.0,
                              ));
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                                    '${entry.key}${entry.value > 1 ? ' x${entry.value}' : ''}')),
                            Text('RM${(book.price ?? 0.0).toStringAsFixed(2)}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Divider(color: Theme.of(context).dividerColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface)),
                    Text('RM${subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: _buildPayButton('Bayar Tunai', Icons.payments)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPayButton('Bayar QR', Icons.qr_code)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildPayButton('Bayar Kad', Icons.credit_card)),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Grid buku
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari buku',
                    prefixIcon: Icon(Icons.search,
                        color: Theme.of(context).iconTheme.color),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withAlpha((0.9 * 255).toInt()),
                  ),
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: filteredBooks
                        .map((book) => _buildBookTile(book))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari buku',
              prefixIcon:
                  Icon(Icons.search, color: Theme.of(context).iconTheme.color),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Theme.of(context)
                  .colorScheme
                  .surface
                  .withAlpha((0.9 * 255).toInt()),
            ),
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children:
                  filteredBooks.map((book) => _buildBookTile(book)).toList(),
            ),
          ),
          const SizedBox(height: 8),
          if (cart.isNotEmpty) ...[
            Divider(color: Theme.of(context).dividerColor),
            ...cart.entries.map((entry) {
              final book = books.firstWhere((b) => b.title == entry.key,
                  orElse: () => Book(
                        id: '',
                        title: '',
                        author: '',
                        description: '',
                        coverUrl: '',
                        category: '',
                        isbn: '',
                        status: '',
                        location: '',
                        coverColor: '#FFFFFF',
                        copies: 1,
                        totalCopies: 1,
                        dateAdded: DateTime.now(),
                        price: 0.0,
                        cost_price: 0.0,
                      ));
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${entry.key} x${entry.value}'),
                  Text(
                      'RM${((book.price ?? 0.0) * entry.value).toStringAsFixed(2)}'),
                ],
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                Text('RM${subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPayButton('Bayar Tunai', Icons.payments)),
                const SizedBox(width: 12),
                Expanded(child: _buildPayButton('Bayar QR', Icons.qr_code)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookTile(Book book) {
    final cardColor = Color(
        int.parse((book.coverColor ?? '#FFFFFF').replaceAll('#', '0xFF')));
    final brightness = ThemeData.estimateBrightnessForColor(cardColor);
    final textColor =
        brightness == Brightness.dark ? Colors.white : Colors.black87;
    return GestureDetector(
      onTap: () => addToCart(book.title),
      onDoubleTap: () {
        setState(() {
          if (cart.containsKey(book.title)) {
            if (cart[book.title]! > 1) {
              cart[book.title] = cart[book.title]! - 1;
            } else {
              cart.remove(book.title);
            }
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 40, color: textColor),
            const SizedBox(height: 8),
            Text(book.title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor)),
            const SizedBox(height: 4),
            Text('RM${(book.price ?? 0.0).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 15, color: textColor)),
          ],
        ),
      ),
    );
  }

  String generateReceiptId() {
    final now = DateTime.now();
    return 'RCPT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 10000}';
  }

  Future<void> _showCashPaymentDialog(double totalAmount) async {
    final TextEditingController cashController = TextEditingController();
    double? change;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan jumlah tunai diterima'),
          content: TextField(
            controller: cashController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Tunai diterima (RM)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final received = double.tryParse(cashController.text) ?? 0.0;
                if (received >= totalAmount) {
                  change = received - totalAmount;
                  Navigator.pop(context);
                }
              },
              child: const Text('Sahkan'),
            ),
          ],
        );
      },
    );
    if (change != null) {
      await _saveTransaction(
        paymentType: 'cash',
        amountPaid: double.tryParse(cashController.text) ?? 0.0,
        changeReturned: change!,
        totalAmount: totalAmount,
      );
      _showSuccessDialog(change!);
      setState(() {
        cart.clear();
      });
    }
  }

  Future<void> _saveTransaction({
    required String paymentType,
    required double amountPaid,
    required double changeReturned,
    required double totalAmount,
  }) async {
    final receiptId = generateReceiptId();
    // 1. Simpan transaksi utama
    final response = await Supabase.instance.client
        .from('sales_transactions')
        .insert({
          'payment_type': paymentType,
          'amount_paid': amountPaid,
          'total_amount': totalAmount,
          'change_returned': changeReturned,
          'receipt_id': receiptId,
        })
        .select()
        .single();

    final transactionId = response['id'];

    // 2. Simpan setiap item dalam transaksi
    for (final entry in cart.entries) {
      final book = books.firstWhere((b) => b.title == entry.key);
      await Supabase.instance.client.from('sales_transaction_items').insert({
        'transaction_id': transactionId,
        'book_id': book.id,
        'book_title': book.title, // tambah nama buku
        'quantity': entry.value,
        'price_each': book.price,
      });
      // 3. Update stok buku
      await Supabase.instance.client.from('books').update(
          {'copies': (book.copies ?? 0) - entry.value}).eq('id', book.id);
    }
  }

  void _showSuccessDialog(double change) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaksi Berjaya'),
        content: Text('Baki dipulangkan: RM${change.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: label == 'Bayar Tunai'
          ? () => _showCashPaymentDialog(subtotal)
          : () {},
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1978E5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
