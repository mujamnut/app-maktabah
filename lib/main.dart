// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as flutter_provider;
import 'package:easy_localization/easy_localization.dart';
import 'theme_provider.dart';
import 'screens/main_navigation.dart';
import 'models/book.dart';
import 'screens/book_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'services/book_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  await Supabase.initialize(
    url: 'https://hbrblzkqjeyevbxcxijn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhicmJsemtxamV5ZXZieGN4aWpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2NjU3NDIsImV4cCI6MjA2ODI0MTc0Mn0.MHQoTTQl8PmASqo3C6PCE55uHDR6fkvv01SVZ_Vb6ug',
  );
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ms')],
      path: '/langs',
      fallbackLocale: const Locale('en'),
      child: flutter_provider.ChangeNotifierProvider.value(
        value: themeProvider,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = flutter_provider.Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Book Manager',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        scaffoldBackgroundColor: Theme.of(context).colorScheme.background,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        scaffoldBackgroundColor: Theme.of(context).colorScheme.background,
      ),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = Supabase.instance.client.auth.currentSession;
          if (session == null) {
            return const LoginScreen();
          } else {
            return const MainNavigation();
          }
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Book> books = [];
  String searchQuery = '';
  bool showAddForm = false;
  Book? editingBook;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String selectedCategory = '';
  bool isLoading = false;

  final List<String> categories = [
    'Fiction',
    'Non-Fiction',
    'Classic',
    'Romance',
    'Dystopian',
    'Business',
    'Programming',
    'Design',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    List<Book> filteredBooks = books
        .where((book) =>
            (book.title).toLowerCase().contains(searchQuery.toLowerCase()) ||
            (book.author ?? '')
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (showAddForm) _buildAddBookForm(),
            _buildSearchBar(),
            Expanded(
              child: books.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'no_books_found'.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        return GestureDetector(
                          onTap: () => _navigateToBookDetail(book),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha((0.04 * 255).toInt()),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(
                                        (book.coverColor ?? '#FFFFFF')
                                            .replaceAll('#', '0xFF'))),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_u
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(
                                      child: Text(
                                        book.title
                                            .split(' ')
                                            .take(2)
                                            .map((e) => e[0])
                                            .join(''),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book.author ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: book.status == 'available'
                                                  ? Colors.green
                                                      .withOpacity(0.1)
                                                  : Colors.orange
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              book.status == 'available'
                                                  ? 'available'.tr()
                                                  : 'borrowed'.tr(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    book.status == 'available'
                                                        ? Colors.green[700]
                                                        : Colors.orange[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.blue.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              book.category ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () => _editBook(book),
                                      icon: const Icon(Icons.edit, size: 20),
                                      color: Colors.grey[600],
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteBook(book.id),
                                      icon: const Icon(Icons.delete, size: 20),
                                      color: Colors.red[400],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Books',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: _showAddBookDialog,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1978E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'search_books'.tr(),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAddBookForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            editingBook != null ? 'edit_book'.tr() : 'add_new_book'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'book_title'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _authorController,
            decoration: InputDecoration(
              labelText: 'author'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _isbnController,
            decoration: InputDecoration(
              labelText: 'isbn'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedCategory.isEmpty ? null : selectedCategory,
            decoration: InputDecoration(
              labelText: 'category'.tr(),
              border: const OutlineInputBorder(),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.tr()),
              );
            }).toList(),
            onChanged: (value) =>
                setState(() => selectedCategory = value ?? ''),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'location'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1978E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                      editingBook != null ? 'update'.tr() : 'add_book'.tr()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: _cancelAddBook,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('cancel'.tr()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddBookDialog() {
    setState(() {
      showAddForm = true;
      editingBook = null;
      _clearForm();
    });
  }

  void _editBook(Book book) {
    setState(() {
      showAddForm = true;
      editingBook = book;
      _titleController.text = book.title;
      _authorController.text = book.author ?? '';
      _isbnController.text = book.isbn ?? '';
      _locationController.text = book.location ?? '';
      selectedCategory = book.category ?? '';
    });
  }

  void _saveBook() async {
    if (_titleController.text.isNotEmpty && _authorController.text.isNotEmpty) {
      final List<String> colors = [
        '#F5F5DC',
        '#F0F0F0',
        '#FFF8DC',
        '#F4A460',
        '#DEB887'
      ];
      if (editingBook != null) {
        int index = books.indexWhere((b) => b.id == editingBook!.id);
        final updatedBook = editingBook!.copyWith(
          title: _titleController.text,
          author: _authorController.text,
          description: 'A book about ${_titleController.text}',
          isbn: _isbnController.text,
          category: selectedCategory,
          location: _locationController.text,
        );
        setState(() {
          books[index] = updatedBook;
        });
        await BookService().updateBook(updatedBook);
        await fetchBooksFromSupabase();
      } else {
        final newBook = Book(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          author: _authorController.text,
          description: 'A book about ${_titleController.text}',
          coverUrl: '',
          category: selectedCategory,
          isbn: _isbnController.text,
          status: 'available',
          location: _locationController.text,
          coverColor: colors[books.length % colors.length],
          copies: 0,
          totalCopies: 0,
          dateAdded: DateTime.now(),
          price: 0.0,
          cost_price: 0.0,
        );
        setState(() {
          books.add(newBook);
        });
        await BookService().addBook(newBook);
        await fetchBooksFromSupabase();
      }
      _cancelAddBook();
    }
  }

  void _cancelAddBook() {
    setState(() {
      showAddForm = false;
      editingBook = null;
      _clearForm();
    });
  }

  void _clearForm() {
    _titleController.clear();
    _authorController.clear();
    _isbnController.clear();
    _locationController.clear();
    selectedCategory = '';
  }

  void _deleteBook(String id) {
    setState(() {
      books.removeWhere((book) => book.id == (id));
    });
    BookService().deleteBook(id);
    fetchBooksFromSupabase();
  }

  void _navigateToBookDetail(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(book: book),
      ),
    );
  }

  Future<void> fetchBooksFromSupabase() async {
    setState(() {
      isLoading = true;
    });
    final fetchedBooks = await BookService().fetchBooks();
    setState(() {
      books = fetchedBooks;
      isLoading = false;
    });
  }
}
