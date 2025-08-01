import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import 'notification_service.dart';

class BookService {
  final _client = Supabase.instance.client;

  Future<List<Book>> fetchBooks() async {
    final response = await _client
        .from('books')
        .select()
        .eq('is_deleted', false)
        .order('title', ascending: true);
    return (response as List)
        .map((data) => Book.fromMap(data as Map<String, dynamic>))
        .toList();
  }

  Future<List<Book>> fetchBooksByUser(String author) async {
    final response = await _client
        .from('books')
        .select()
        .eq('is_deleted', false)
        .eq('author', author)
        .order('title', ascending: true);
    return (response as List)
        .map((data) => Book.fromMap(data as Map<String, dynamic>))
        .toList();
  }

  Future<void> addBook(Book book) async {
    try {
      // Buat map data untuk insertion, tidak termasuk 'id' kerana ia auto-generated oleh Supabase
      final dataToInsert = book.toMap();
      dataToInsert.remove('id');

      final response = await Supabase.instance.client
          .from('books')
          .insert(dataToInsert)
          .select();

      // Buat notification untuk admin
      if (response.isNotEmpty) {
        final currentUser = Supabase.instance.client.auth.currentUser;
        final userName = currentUser?.email ?? 'Unknown User';
        final userId = currentUser?.id ?? '';

        final notificationService = NotificationService();
        await notificationService.createBookAddedNotification(
          bookTitle: book.title,
          addedBy: userName,
          bookId: response.first['id'],
          userId: userId,
        );
      }
    } catch (e) {
      debugPrint('Error adding book: $e');
      rethrow;
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      await _client.from('books').update(book.toMap()).eq('id', book.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await _client.from('books').update({'is_deleted': true}).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Simpan harga baru ke price_history
  Future<void> addBookPrice(String bookId, double price) async {
    await _client.from('price_history').insert({
      'book_id': bookId,
      'price': price,
    });
  }

  // Dapatkan harga semasa (terkini) untuk buku
  Future<double?> getCurrentPrice(String bookId) async {
    final result = await _client
        .from('price_history')
        .select('price')
        .eq('book_id', bookId)
        .order('effective_from', ascending: false)
        .limit(1);
    if (result is List && result.isNotEmpty) {
      return (result.first['price'] as num).toDouble();
    }
    return null;
  }

  // Dapatkan top 3 buku paling laris (top sales) hari ini
  Future<List<Map<String, dynamic>>> getTopSalesTodayList() async {
    final today = DateTime.now();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final txs = await _client
        .from('sales_transactions')
        .select('id, created_at')
        .gte('created_at', '${todayStr}T00:00:00')
        .lte('created_at', '${todayStr}T23:59:59');
    if (txs is! List || txs.isEmpty) return [];
    final txIds = txs.map((tx) => tx['id']).toList();
    final items = await _client
        .from('sales_transaction_items')
        .select('book_id, book_title, quantity, price_each')
        .in_('transaction_id', txIds);
    if (items is! List || items.isEmpty) return [];
    final Map<String, Map<String, dynamic>> sales = {};
    for (final item in items) {
      final bookId = item['book_id'];
      final title = item['book_title'] ?? '-';
      final qty = (item['quantity'] ?? 0) as int;
      final total = (item['price_each'] ?? 0) * qty;
      if (!sales.containsKey(bookId)) {
        sales[bookId] = {
          'book_id': bookId,
          'title': title,
          'qty': 0,
          'total': 0.0,
        };
      }
      sales[bookId]!['qty'] += qty;
      sales[bookId]!['total'] += total;
    }
    if (sales.isEmpty) return [];
    final sorted = sales.values.toList()
      ..sort((a, b) => (b['qty'] as int).compareTo(a['qty'] as int));
    return sorted.take(3).toList();
  }

  // Dapatkan total jualan hari ini dari database
  Future<double> getTotalDailySales() async {
    final today = DateTime.now();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    try {
      // Ambil semua transaksi hari ini
      final txs = await _client
          .from('sales_transactions')
          .select('id, created_at')
          .gte('created_at', '${todayStr}T00:00:00')
          .lte('created_at', '${todayStr}T23:59:59');

      if (txs is! List || txs.isEmpty) return 0.0;

      // Ambil ID transaksi
      final txIds = txs.map((tx) => tx['id']).toList();

      // Ambil semua item dari transaksi hari ini
      final items = await _client
          .from('sales_transaction_items')
          .select('transaction_id, quantity, price_each')
          .in_('transaction_id', txIds);

      if (items is! List || items.isEmpty) return 0.0;

      // Kira total jualan
      double total = 0.0;
      for (final item in items) {
        final qty = (item['quantity'] ?? 0) as num;
        final price = (item['price_each'] ?? 0) as num;
        total += qty * price;
      }

      return total;
    } catch (e) {
      debugPrint('Error fetching total daily sales: $e');
      return 0.0;
    }
  }
}
