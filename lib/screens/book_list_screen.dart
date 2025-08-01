// ignore_for_file: unused_import, unused_element

import 'package:flutter/material.dart';
import '../models/book.dart'; // Import model Book
import '../widgets/book_card.dart'; // Import widget BookCard
import 'book_details_screen.dart'; // Import skrin perincian buku
import 'add_book_screen.dart'; // Import skrin tambah buku
import '../services/book_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'settings_screen.dart';
import 'book_dashboard.dart';
import 'book_list_tab.dart';
// Import skrin chart stok yang baru

class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  const HomeDashboardScreen({Key? key, this.onMenuPressed}) : super(key: key);

  @override
  HomeDashboardScreenState createState() => HomeDashboardScreenState();
}

class HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List<Book> books = [];
  String searchQuery = '';
  String selectedGenre = 'All';
  String selectedAuthor = 'All';
  final BookService _bookService = BookService();
  bool isLoading = true;
  double salesToday = 0.0;
  double totalDailySales = 0.0; // Tambah state untuk total daily sales
  int lowStockCount = 0;

  @override
  void initState() {
    super.initState();
    fetchBooksFromSupabase();
    fetchSalesToday();
    fetchTotalDailySales(); // Tambah panggilan untuk fetch total daily sales
  }

  Future<void> fetchBooksFromSupabase() async {
    setState(() {
      isLoading = true;
    });
    final fetchedBooks = await _bookService.fetchBooks();
    setState(() {
      books = fetchedBooks;
      lowStockCount = books.where((b) => (b.copies ?? 0) < 10).length;
      isLoading = false;
    });
  }

  Future<void> fetchSalesToday() async {
    final total = await _bookService.getTotalDailySales();
    setState(() {
      salesToday = total;
    });
  }

  Future<void> fetchTotalDailySales() async {
    final total = await _bookService.getTotalDailySales();
    setState(() {
      totalDailySales = total;
    });
  }

  List<String> get genres => [
        'All',
        ...{...books.map((b) => b.category ?? '')}
      ];
  List<String> get authors => [
        'All',
        ...{...books.map((b) => b.author ?? '')}
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Stack(
                  children: [
                    BookDashboard(
                      books: books,
                      salesToday: salesToday,
                      lowStockCount: lowStockCount,
                      onAddBook: _navigateToAddBook,
                      totalDailySales: totalDailySales, // Hantar data sebenar
                      topSalesList: const [],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.settings,
                            color: Theme.of(context).colorScheme.onSurface),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildStatCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
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
            value,
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

  Widget _buildActionButton(
      {required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToBookDetail(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(book: book),
      ),
    );
  }

  void _navigateToAddBook() async {
    final newBook = await Navigator.push<Book>(
      context,
      MaterialPageRoute(builder: (context) => const AddBookScreen()),
    );
    if (newBook != null) {
      await _bookService.addBook(newBook);
      await fetchBooksFromSupabase();
    }
  }

  void _navigateToEditBook(Book book) async {
    final updatedBook = await Navigator.push<Book>(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookScreen(bookToEdit: book),
      ),
    );
    if (updatedBook != null) {
      await _bookService.updateBook(updatedBook);
      await fetchBooksFromSupabase();
    }
  }

  void _deleteBook(Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text('Anda yakin ingin menghapus "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _bookService.deleteBook(book.id);
      await fetchBooksFromSupabase();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${book.title}" dihapus.')),
      );
    }
  }
}
