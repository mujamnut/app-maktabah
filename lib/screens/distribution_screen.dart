import 'package:flutter/material.dart';

class DistributionScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const DistributionScreen({Key? key, this.onBack}) : super(key: key);

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> orders = [
    {'destination': 'Bookstore A', 'order': '#12345', 'status': 'Shipped'},
    {'destination': 'Bookstore B', 'order': '#12346', 'status': 'In Transit'},
    {'destination': 'Bookstore C', 'order': '#12347', 'status': 'Delivered'},
    {'destination': 'Bookstore D', 'order': '#12348', 'status': 'Shipped'},
    {'destination': 'Bookstore E', 'order': '#12349', 'status': 'In Transit'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
        title: const Text('Distribution',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.blueGrey,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(orders),
                _buildOrderList(orders
                    .where((o) =>
                        o['status'] == 'In Transit' || o['status'] == 'Shipped')
                    .toList()),
                _buildOrderList(
                    orders.where((o) => o['status'] == 'Delivered').toList()),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildOrderList(List<Map<String, String>> orders) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Destination: ${order['destination']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 4),
                  Text('Order ${order['order']}',
                      style: const TextStyle(
                          fontSize: 16, color: Colors.blueGrey)),
                ],
              ),
            ),
            Text(order['status'] ?? '',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
          ],
        );
      },
    );
  }
}
