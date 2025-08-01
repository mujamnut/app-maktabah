// lib/widgets/book_card.dart
import 'package:flutter/material.dart';
import '../models/book.dart'; // Import model Book

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Book cover or initials
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(int.parse(
                      (book.coverColor ?? '#FFFFFF').replaceAll('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(8),
                  image: (book.coverUrl ?? '').isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(book.coverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (book.coverUrl ?? '').isEmpty
                    ? Center(
                        child: Text(
                          book.title
                              .split(' ')
                              .take(2)
                              .map((e) => e[0])
                              .join(''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    Text(
                      'In Stock: ${book.copies}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF637488),
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatusBadge(book.status ?? ''),
                        const SizedBox(width: 8),
                        _buildCategoryBadge(book.category ?? ''),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF637488)),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isAvailable = status == 'available';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isAvailable ? Colors.green : Colors.orange)
            .withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Borrowed',
        style: TextStyle(
          fontSize: 12,
          color: isAvailable ? Colors.green[700] : Colors.orange[700],
          fontWeight: FontWeight.w500,
          fontFamily: 'SF Pro Display',
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
          fontFamily: 'SF Pro Display',
        ),
      ),
    );
  }
}
