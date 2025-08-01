import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class TransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final List<dynamic> items;
  const TransactionDetailScreen(
      {Key? key, required this.transaction, required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime dateTime =
        DateTime.tryParse(transaction['created_at'] ?? '') ?? DateTime.now();
    final String receiptNumber =
        transaction['receipt_id']?.toString() ?? transaction['id'].toString();
    final String paymentType = transaction['payment_type'] ?? '-';
    final double subtotal = items.fold(
        0.0,
        (sum, item) =>
            sum + ((item['price_each'] ?? 0) * (item['quantity'] ?? 0)));
    final double tip = (transaction['tip'] ?? 0) * 1.0;
    final double salesTax = (transaction['sales_tax'] ?? 0) * 1.0;
    final double serviceFee = (transaction['service_fee'] ?? 0) * 1.0;
    final double total =
        (transaction['total'] ?? subtotal + tip + salesTax + serviceFee);
    final String dateTimeStr = _formatDateTime(dateTime);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Transaction Details',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            _sectionTitle('Receipt', context),
            _row('Receipt Number', receiptNumber, context),
            const SizedBox(height: 24),
            _sectionTitle('Items', context),
            ...items.map((item) => _row(
                  '${item['book_title'] ?? item['name']} (x${item['quantity'] ?? item['qty']})',
                  'RM${((item['price_each'] ?? item['price']) * (item['quantity'] ?? item['qty'])).toStringAsFixed(2)}',
                  context,
                )),
            if (tip > 0) _row('Tip', 'RM${tip.toStringAsFixed(2)}', context),
            const SizedBox(height: 24),
            _sectionTitle('Taxes & Fees', context),
            _row('Sales Tax', 'RM${salesTax.toStringAsFixed(2)}', context),
            _row('Service Fee', 'RM${serviceFee.toStringAsFixed(2)}', context),
            const SizedBox(height: 24),
            _sectionTitle('Total', context),
            _row('Amount', 'RM${total.toStringAsFixed(2)}', context),
            const SizedBox(height: 16),
            _row('Payment Method', paymentType, context),
            _row('Date & Time', dateTimeStr, context),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final pdfData = await _generateReceiptPdf();
                  await Printing.layoutPdf(onLayout: (format) async => pdfData);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Download Receipt',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );

  Widget _row(String left, String right, BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                left,
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              right,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ],
        ),
      );

  String _formatDateTime(DateTime dt) {
    return '${_monthName(dt.month)} ${dt.day}, ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  Future<Uint8List> _generateReceiptPdf() async {
    final pdf = pw.Document();
    final fontData = await rootBundle
        .load('book_app/assets/fonts/Roboto/Roboto-VariableFont_wdth,wght.ttf');
    final ttf = pw.Font.ttf(fontData);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Receipt',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(
                  'Receipt Number: ${transaction['receipt_id'] ?? transaction['id']}',
                  style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 16),
              pw.Text('Items:',
                  style:
                      pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
              ...items.map((item) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                          '${item['book_title'] ?? item['name']} (x${item['quantity'] ?? item['qty']})',
                          style: pw.TextStyle(font: ttf)),
                      pw.Text(
                          'RM${((item['price_each'] ?? item['price']) * (item['quantity'] ?? item['qty'])).toStringAsFixed(2)}',
                          style: pw.TextStyle(font: ttf)),
                    ],
                  )),
              if ((transaction['tip'] ?? 0) > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tip', style: pw.TextStyle(font: ttf)),
                    pw.Text('RM${(transaction['tip'] ?? 0).toStringAsFixed(2)}',
                        style: pw.TextStyle(font: ttf)),
                  ],
                ),
              pw.SizedBox(height: 16),
              pw.Text('Taxes & Fees:',
                  style:
                      pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Sales Tax', style: pw.TextStyle(font: ttf)),
                  pw.Text(
                      'RM${(transaction['sales_tax'] ?? 0).toStringAsFixed(2)}',
                      style: pw.TextStyle(font: ttf)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Service Fee', style: pw.TextStyle(font: ttf)),
                  pw.Text(
                      'RM${(transaction['service_fee'] ?? 0).toStringAsFixed(2)}',
                      style: pw.TextStyle(font: ttf)),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text('Total:',
                  style:
                      pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Amount', style: pw.TextStyle(font: ttf)),
                  pw.Text('RM${(transaction['total'] ?? 0).toStringAsFixed(2)}',
                      style: pw.TextStyle(font: ttf)),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text('Payment Method: ${transaction['payment_type'] ?? '-'}',
                  style: pw.TextStyle(font: ttf)),
              pw.Text(
                  'Date & Time: ${_formatDateTime(DateTime.tryParse(transaction['created_at'] ?? '') ?? DateTime.now())}',
                  style: pw.TextStyle(font: ttf)),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }
}
