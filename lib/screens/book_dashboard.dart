import 'package:flutter/material.dart';
import '../models/book.dart';
import 'manage_staff_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/notification_service.dart';
import 'notifications_screen.dart';

class BookDashboard extends StatefulWidget {
  final List<Book> books;
  final double salesToday;
  final int lowStockCount;
  final VoidCallback onAddBook;
  final String? userRole;
  final double totalDailySales;
  final List<Map<String, dynamic>> topSalesList;

  const BookDashboard({
    Key? key,
    required this.books,
    required this.salesToday,
    required this.lowStockCount,
    required this.onAddBook,
    this.userRole,
    this.totalDailySales = 0.0,
    required this.topSalesList,
  }) : super(key: key);

  @override
  State<BookDashboard> createState() => _BookDashboardState();
}

class _BookDashboardState extends State<BookDashboard> {
  final NotificationService _notificationService = NotificationService();
  int unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.userRole == 'admin') {
      _loadNotificationCount();
      _subscribeToNotifications();
    }
  }

  Future<void> _loadNotificationCount() async {
    final count = await _notificationService.getUnreadNotificationCount();
    setState(() {
      unreadNotificationCount = count;
    });
  }

  void _subscribeToNotifications() {
    _notificationService.subscribeToNotifications((notifications) {
      setState(() {
        unreadNotificationCount = notifications.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (widget.userRole == 'admin')
              Positioned(
                top: 8,
                right: 0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 30, // besarkan ikon
                      ),
                      padding: const EdgeInsets.all(8),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    if (unreadNotificationCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadNotificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'total_books'.tr(),
                value: widget.books.isNotEmpty
                    ? widget.books.length.toString()
                    : '0',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'sales_today'.tr(),
                value: widget.salesToday > 0
                    ? 'RM${widget.salesToday.toStringAsFixed(2)}'
                    : '0',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'low_stock'.tr(),
                value: widget.books.isNotEmpty
                    ? widget.lowStockCount.toString()
                    : '0',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'total_daily_sales'.tr(),
                value: 'RM${widget.totalDailySales.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'quick_actions'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context: context,
          label: 'add_product'.tr(),
          onTap: widget.onAddBook,
        ),
        if (widget.userRole != 'staff') const SizedBox(height: 12),
        if (widget.userRole != 'staff')
          _buildActionButton(
            context: context,
            label: 'view_agents'.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageStaffScreen()),
              );
            },
          ),
        const SizedBox(height: 12),
        _buildActionButton(
          context: context,
          label: 'view_sales'.tr(),
          onTap: () {},
        ),
        // Paparan Top Sales (List Mini/Bar Chart) di bawah Quick Actions
        const SizedBox(height: 32),
        _buildTopSalesTabSection(),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 8),
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
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withAlpha((0.7 * 255).toInt())),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  // Tambah fungsi baru untuk tab toggle dan paparan List/Bar
  Widget _buildTopSalesTabSection() {
    int selectedTab = 0;
    return StatefulBuilder(
      builder: (context, setState) {
        final topSales = widget.topSalesList;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
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
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 22),
                  const SizedBox(width: 8),
                  Text('Top Sales Hari Ini',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                  ToggleButtons(
                    isSelected: [selectedTab == 0, selectedTab == 1],
                    onPressed: (i) => setState(() => selectedTab = i),
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: Colors.blue,
                    color: Colors.blue,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('List'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Bar'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (selectedTab == 0)
                _buildTopSalesList(context, topSales)
              else
                _buildTopSalesBarChart(topSales),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopSalesList(
      BuildContext context, List<Map<String, dynamic>> topSales) {
    final list = topSales.take(3).toList();
    if (list.isEmpty) {
      return Text('Tiada jualan hari ini.',
          style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withAlpha((0.7 * 255).toInt())));
    }
    return Column(
      children: list.asMap().entries.map((entry) {
        final i = entry.key + 1;
        final item = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text('$i.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withAlpha((0.7 * 255).toInt()))),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(item['title'] ?? '-',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color:
                              Theme.of(context).textTheme.bodyLarge?.color))),
              Text('x${item['qty'] ?? 0}',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
              const SizedBox(width: 8),
              Text('RM${(item['total'] ?? 0).toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopSalesBarChart(List<Map<String, dynamic>> topSales) {
    final list = topSales.take(3).toList();
    if (list.isEmpty) {
      return const Text('Tiada jualan hari ini.',
          style: TextStyle(color: Colors.grey));
    }
    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (list
                      .map((e) => (e['qty'] as num?) ?? 0)
                      .fold<num>(0, (a, b) => a > b ? a : b) +
                  2)
              .toDouble(),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= list.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      (list[idx]['title'] as String?)
                              ?.split(' ')
                              .take(2)
                              .join(' ') ??
                          '-',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
                reservedSize: 60,
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(list.length, (i) {
            final qty = (list[i]['qty'] as num?) ?? 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: qty.toDouble(),
                  color: Colors.blue,
                  width: 24,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
