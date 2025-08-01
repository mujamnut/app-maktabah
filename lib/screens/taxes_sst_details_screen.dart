import 'package:flutter/material.dart';

class TaxesSSTDetailsScreen extends StatelessWidget {
  const TaxesSSTDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_TaxDeadline> deadlines = [
      _TaxDeadline(
          'Sales Tax - Q2 2024', 'Due: July 15, 2024', Icons.calendar_today),
      _TaxDeadline('Service Tax - H1 2024', 'Due: August 31, 2024',
          Icons.calendar_today),
    ];
    final List<_TaxRecord> records = [
      _TaxRecord('Sales Tax - Q1 2024', 'Submitted: April 10, 2024',
          Icons.receipt_long),
      _TaxRecord('Service Tax - H2 2023', 'Submitted: January 15, 2024',
          Icons.receipt_long),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Taxes & SST',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const SizedBox(height: 8),
          const Text(
            'Tax Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total Tax Due',
                  value: ' 41,250.00',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  label: 'Total Tax Paid',
                  value: ' 4800.00',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Upcoming Deadlines',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          ...deadlines.map((d) => _TaxDeadlineTile(deadline: d)).toList(),
          const SizedBox(height: 32),
          const Text(
            'Tax Records',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          ...records.map((r) => _TaxRecordTile(record: r)).toList(),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 24),
              label: const Text(
                'Add Tax Record',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1978E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxDeadline {
  final String title;
  final String due;
  final IconData icon;
  _TaxDeadline(this.title, this.due, this.icon);
}

class _TaxDeadlineTile extends StatelessWidget {
  final _TaxDeadline deadline;
  const _TaxDeadlineTile({required this.deadline});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(deadline.icon, color: Colors.blueGrey, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deadline.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                deadline.due,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaxRecord {
  final String title;
  final String submitted;
  final IconData icon;
  _TaxRecord(this.title, this.submitted, this.icon);
}

class _TaxRecordTile extends StatelessWidget {
  final _TaxRecord record;
  const _TaxRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(record.icon, color: Colors.blueGrey, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                record.submitted,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
