// lib/screens/add_book_screen.dart
// ignore_for_file: library_private_types_in_public_api, unused_element

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/book.dart'; // Import model Book
import '../services/book_service.dart'; // Import BookService
import 'package:supabase_flutter/supabase_flutter.dart';

class AddBookScreen extends StatefulWidget {
  final Book? bookToEdit;

  const AddBookScreen({super.key, this.bookToEdit});

  @override
  AddBookScreenState createState() => AddBookScreenState();
}

class AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _isbnController = TextEditingController();
  final _locationController = TextEditingController();
  final _costPriceController =
      TextEditingController(); // Controller untuk cost_price
  final _priceController =
      TextEditingController(); // Controller baru untuk harga
  String _selectedCategory = '';
  String _selectedStatus = 'available'; // Status default
  DateTime? _selectedDueDate;
  int _copies = 1;
  int _totalCopies = 1;

  final List<String> _categories = [
    'Fiction',
    'Non-Fiction',
    'Science',
    'Technology',
    'History',
    'Biography',
    'Business',
    'Other'
  ];

  final List<String> _colors = [
    '#F5F5DC',
    '#F0F0F0',
    '#FFF8DC',
    '#F4A460',
    '#DEB887'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bookToEdit != null) {
      _titleController.text = widget.bookToEdit!.title;
      _authorController.text = widget.bookToEdit!.author ?? '';
      _descriptionController.text = widget.bookToEdit!.description ?? '';
      _isbnController.text = widget.bookToEdit!.isbn ?? '';
      _locationController.text = widget.bookToEdit!.location ?? '';
      _selectedCategory = widget.bookToEdit!.category ?? '';
      _copies = widget.bookToEdit!.copies ?? 1;
      _totalCopies = widget.bookToEdit!.totalCopies ?? 1;
      _costPriceController.text =
          widget.bookToEdit!.cost_price?.toString() ?? '';
      _priceController.text =
          widget.bookToEdit!.price?.toString() ?? ''; // Isi controller harga
      _selectedStatus = widget.bookToEdit!.status ?? 'available'; // Isi status
    } else {
      // Jika tambah buku baru, auto set author kepada email user login
      final user = Supabase.instance.client.auth.currentUser;
      _authorController.text = user?.email ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _isbnController.dispose();
    _locationController.dispose();
    _costPriceController.dispose();
    _priceController.dispose(); // Dispose controller harga
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _saveBook() async {
    if (_formKey.currentState!.validate()) {
      final newPrice = double.tryParse(_priceController.text);
      final book = widget.bookToEdit?.copyWith(
            title: _titleController.text,
            author: _authorController.text,
            description: _descriptionController.text,
            coverUrl: '',
            category: _selectedCategory,
            isbn: _isbnController.text,
            status: _selectedStatus, // Guna status dari dropdown
            location: _locationController.text,
            coverColor: _colors[DateTime.now().millisecond % _colors.length],
            copies: _copies,
            totalCopies: _totalCopies,
            dateAdded: DateTime.now(),
            price: newPrice, // Guna harga dari input
            cost_price: double.tryParse(_costPriceController.text),
          ) ??
          Book(
            id: const Uuid().v4(),
            title: _titleController.text,
            author: _authorController.text,
            description: _descriptionController.text,
            coverUrl: '',
            category: _selectedCategory,
            isbn: _isbnController.text,
            status: _selectedStatus, // Guna status dari dropdown
            location: _locationController.text,
            coverColor: _colors[DateTime.now().millisecond % _colors.length],
            copies: _copies,
            totalCopies: _totalCopies,
            dateAdded: DateTime.now(),
            price: newPrice, // Guna harga dari input
            cost_price: double.tryParse(_costPriceController.text),
          );
      // Jika edit dan harga berubah, simpan ke price_history
      if (widget.bookToEdit != null &&
          newPrice != null &&
          newPrice != widget.bookToEdit!.price) {
        await BookService().addBookPrice(book.id, newPrice);
      }
      if (mounted) {
        Navigator.pop(context, book);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Normalisasi value location supaya sentiasa 'Malaysia' atau 'Mesir' jika sesuai
    String locationValue = _locationController.text.trim();
    if (locationValue.toLowerCase() == 'malaysia') locationValue = 'Malaysia';
    if (locationValue.toLowerCase() == 'mesir') locationValue = 'Mesir';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.bookToEdit != null ? 'Edit Book' : 'Add New Book',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildLabel('Book Name', context),
              _buildTextField(_titleController, 'Enter book name',
                  context: context),
              const SizedBox(height: 18),
              _buildLabel('Author', context),
              _buildTextField(_authorController, 'Enter author',
                  validator: (value) => null,
                  maxLines: 1,
                  enabled: false,
                  context: context),
              const SizedBox(height: 18),
              _buildLabel('Description', context),
              _buildTextField(
                _descriptionController,
                'Enter description',
                maxLines: 3,
                validator: (value) => null, // optional
                context: context,
              ),
              const SizedBox(height: 18),
              _buildLabel('ISBN', context), // Ubah label SKU ke ISBN
              _buildTextField(
                _isbnController,
                'Enter ISBN',
                validator: (value) => null, // optional
                context: context,
              ),
              const SizedBox(height: 18),
              _buildLabel('Category', context),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withAlpha((0.12 * 255).toInt())
                        : Theme.of(context).dividerColor,
                    width: 1.2,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value:
                      _selectedCategory.isNotEmpty ? _selectedCategory : null,
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedCategory = val ?? '');
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  dropdownColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 18),
              _buildLabel('Status', context),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withAlpha((0.12 * 255).toInt())
                        : Theme.of(context).dividerColor,
                    width: 1.2,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(
                        value: 'available', child: Text('Available')),
                    DropdownMenuItem(
                        value: 'borrowed', child: Text('Borrowed')),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedStatus = val ?? 'available');
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  dropdownColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 18),
              _buildLabel('Location', context),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withAlpha((0.12 * 255).toInt())
                        : Theme.of(context).dividerColor,
                    width: 1.2,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: locationValue.isNotEmpty ? locationValue : null,
                  items: const [
                    DropdownMenuItem(
                        value: 'Malaysia', child: Text('Malaysia')),
                    DropdownMenuItem(value: 'Mesir', child: Text('Mesir')),
                  ],
                  onChanged: (val) {
                    setState(() => _locationController.text = val ?? '');
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  dropdownColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 18),
              _buildLabel('Price', context), // Label untuk harga
              _buildNumberField(
                initialValue: _priceController.text,
                label: 'Enter price',
                onChanged: (value) {
                  _priceController.text = value;
                },
                context: context,
              ),
              const SizedBox(height: 18),
              _buildLabel('Cost Price', context),
              _buildTextField(
                _costPriceController,
                'Enter cost price',
                validator: (value) => null, // optional
                context: context,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Stock', context),
                        _buildNumberField(
                          initialValue: _copies.toString(),
                          label: 'Enter stock',
                          onChanged: (value) {
                            setState(() {
                              _copies = int.tryParse(value) ?? 1;
                            });
                          },
                          context: context,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Total Copies', context),
                        _buildNumberField(
                          initialValue: _totalCopies.toString(),
                          label: 'Enter total copies',
                          onChanged: (value) {
                            setState(() {
                              _totalCopies = int.tryParse(value) ?? 1;
                            });
                          },
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDCE8F6),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Text(
                    widget.bookToEdit != null ? 'Save Book' : 'Add Book',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {FormFieldValidator<String>? validator,
      int maxLines = 1,
      bool enabled = true,
      BuildContext? context}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      style: TextStyle(
          color:
              context != null ? Theme.of(context).colorScheme.onSurface : null),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: context != null
                ? Theme.of(context).textTheme.bodySmall?.color
                : null),
        filled: true,
        fillColor: context != null
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context != null
                ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withAlpha((0.12 * 255).toInt())
                    : Theme.of(context).dividerColor)
                : Colors.grey,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context != null
                ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withAlpha((0.12 * 255).toInt())
                    : Theme.of(context).dividerColor)
                : Colors.grey,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context != null
                ? Theme.of(context).colorScheme.primary
                : Colors.blue,
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }

  Widget _buildNumberField(
      {required String initialValue,
      required String label,
      required Function(String) onChanged,
      BuildContext? context}) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      style: TextStyle(
          color:
              context != null ? Theme.of(context).colorScheme.onSurface : null),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
            color: context != null
                ? Theme.of(context).textTheme.bodySmall?.color
                : null),
        filled: true,
        fillColor: context != null
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context != null
                ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withAlpha((0.12 * 255).toInt())
                    : Theme.of(context).dividerColor)
                : Colors.grey,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context != null
                ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withAlpha((0.12 * 255).toInt())
                    : Theme.of(context).dividerColor)
                : Colors.grey,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context != null
                ? Theme.of(context).colorScheme.primary
                : Colors.blue,
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field required';
        }
        if (int.tryParse(value) == null) {
          return 'Must be a number';
        }
        return null;
      },
    );
  }
}
