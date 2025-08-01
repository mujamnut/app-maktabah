import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import 'package:easy_localization/easy_localization.dart';

class BookDetailsPage extends StatelessWidget {
  final Book? book;
  const BookDetailsPage({Key? key, this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data dummy jika book null
    final String coverUrl = (book != null &&
            (book!.coverUrl?.isNotEmpty ?? false))
        ? book!.coverUrl!
        : 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=600&fit=crop';
    final String title = book?.title ?? "The Dragon's Legacy";
    final String genre = book?.category ?? "Fantasy";
    const String about =
        "Amelia Stone is a rising star in the fantasy genre, known for her intricate world-building and compelling characters. Her debut novel, The Dragon's Legacy, has captivated readers with its blend of adventure, magic, and heart.";

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            floating: true,
            snap: true,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Book Details',
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            // Tiada actions (buang icon share)
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Book Cover
                Center(
                  child: Container(
                    width: 220,
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.18 * 255).toInt()),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Progress Bar Stock
                if (book != null &&
                    book!.copies != null &&
                    book!.totalCopies != null &&
                    book!.totalCopies != 0) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Stock',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color)),
                            Text(
                              '${book!.copies}/${book!.totalCopies} (${((book!.copies! / book!.totalCopies!) * 100).toStringAsFixed(0)}%)',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (book!.copies! / book!.totalCopies!),
                            minHeight: 8,
                            backgroundColor: Theme.of(context).dividerColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Stock',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color)),
                            Text('75%',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.75,
                            minHeight: 8,
                            backgroundColor: Theme.of(context).dividerColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'by ${book?.author ?? 'Unknown Author'}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$genre | ${book?.status ?? 'Unknown Status'}', // Menggunakan status dari database
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (book?.location != null && book!.location!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Location: ${book!.location}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                if (book?.cost_price != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'cost_price'
                        .tr(args: [book!.cost_price!.toStringAsFixed(2)]),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                          child: _statCard(
                              context,
                              book != null ? book!.copies.toString() : '0',
                              'Stock')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _statCard(
                              context,
                              book != null ? book!.totalCopies.toString() : '0',
                              'Total Stock')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _statCard(
                              context,
                              book != null && book!.price != null
                                  ? 'RM${book!.price!.toStringAsFixed(2)}'
                                  : 'RM0.00',
                              'Price')),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'summary'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    book?.description ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      height: 1.6,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // About the Author
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'about_author'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    about,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      height: 1.6,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withAlpha((0.12 * 255).toInt())
              : Theme.of(context).dividerColor,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.tr(),
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
