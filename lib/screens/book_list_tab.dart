import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'add_book_screen.dart';
import '../widgets/book_card.dart';
import 'book_details_screen.dart';

class BookListTab extends StatefulWidget {
  const BookListTab({Key? key}) : super(key: key);

  @override
  State<BookListTab> createState() => _BookListTabState();
}

class _BookListTabState extends State<BookListTab> {
  List<Book> books = [];
  List<Book> filteredBooks = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedLocation = 'All';

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

  void _applyFilters() {
    setState(() {
      filteredBooks = books.where((b) {
        final matchSearch = (b.title)
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            (b.isbn ?? '').toLowerCase().contains(searchQuery.toLowerCase());
        final matchLocation = selectedLocation == 'All' ||
            (b.location ?? '').toLowerCase() == selectedLocation.toLowerCase();
        return matchSearch && matchLocation;
      }).toList();
    });
  }

  void _onSearch(String query) {
    searchQuery = query;
    _applyFilters();
  }

  void _onLocationFilter(String loc) {
    selectedLocation = loc;
    _applyFilters();
  }

  void _navigateToAddBook() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBookScreen()),
    );
    if (result != null) {
      await BookService().addBook(result);
      fetchBooks();
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
      await BookService().updateBook(updatedBook);
      fetchBooks();
    }
  }

  void _deleteBook(Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Padam Buku'),
        content: Text('Anda pasti mahu padam "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Padam', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await BookService().deleteBook(book.id);
      await fetchBooks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${book.title}" dipadam.')),
      );
    }
  }

  void _navigateToBookDetail(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(book: book),
      ),
    );
  }

  Widget _buildLocationFilterButton(String label) {
    final isSelected = selectedLocation == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () => _onLocationFilter(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          foregroundColor: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.08 * 255).toInt()),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                      if (Theme.of(context).brightness == Brightness.dark)
                        BoxShadow(
                          color: Colors.white.withAlpha((0.08 * 255).toInt()),
                          blurRadius: 6,
                          offset: const Offset(0, 0),
                        ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _onSearch,
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.search, color: Colors.blueGrey, size: 28),
                      hintText: 'Cari buku',
                      border: InputBorder.none,
                      hintStyle:
                          TextStyle(fontSize: 18, color: Colors.blueGrey),
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildLocationFilterButton('All'),
                    _buildLocationFilterButton('Malaysia'),
                    _buildLocationFilterButton('Mesir'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : BookListView(
                    books: filteredBooks,
                    onEdit: _navigateToEditBook,
                    onDelete: _deleteBook,
                    onDetail: _navigateToBookDetail,
                  ),
          ),
        ],
      ),
    );
  }
}

class BookListView extends StatelessWidget {
  final List<Book> books;
  final void Function(Book) onEdit;
  final void Function(Book) onDelete;
  final void Function(Book) onDetail;

  const BookListView({
    Key? key,
    required this.books,
    required this.onEdit,
    required this.onDelete,
    required this.onDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: BookCard(
            book: book,
            onTap: () => onDetail(book),
            onEdit: () => onEdit(book),
            onDelete: () => onDelete(book),
          ),
        );
      },
    );
  }
}
