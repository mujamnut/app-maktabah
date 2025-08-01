import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final String? initialTab;
  const ReportsScreen({Key? key, this.onBack, this.initialTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack,
        ),
        title: const Text('Reports',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: const Center(child: Text('Reports Page')),
    );
  }
}
