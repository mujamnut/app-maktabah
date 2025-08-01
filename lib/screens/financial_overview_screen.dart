import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancialOverviewScreen extends StatefulWidget {
  const FinancialOverviewScreen({Key? key}) : super(key: key);

  @override
  State<FinancialOverviewScreen> createState() =>
      _FinancialOverviewScreenState();
}

class _FinancialOverviewScreenState extends State<FinancialOverviewScreen> {
  int selectedPeriod = 0; // 0: This Month, 1: This Year
  int selectedCountry = 0; // 0: Malaysia, 1: Egypt

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('Financial Overview',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurface)),
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Key Metrics',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.onSurface)),
              Row(
                children: [
                  _periodButton('This Month', 0),
                  const SizedBox(width: 8),
                  _periodButton('This Year', 1),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _metricCard(
                icon: Icons.wb_sunny_outlined,
                iconColor: Colors.blue,
                title: 'Total Sales',
                value: ' 24,500',
                subtitle: '+10.2% vs last month',
                subtitleColor: Colors.green,
                onTap: () => _showDetailModal('Total Sales'),
              ),
              _metricCard(
                icon: Icons.check_circle_outline,
                iconColor: Colors.green,
                title: 'Net Profit',
                value: ' 4,800',
                subtitle: 'Healthy',
                subtitleColor: Colors.green,
                onTap: () => _showDetailModal('Net Profit'),
              ),
              _metricCard(
                icon: Icons.bookmark_outline,
                iconColor: Colors.amber,
                title: 'COGS',
                value: ' 7,700',
                subtitle: 'Stable',
                subtitleColor: Colors.blueGrey,
                onTap: () => _showDetailModal('COGS'),
              ),
              _metricCard(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: Colors.indigo,
                title: 'Current Assets',
                value: ' 25,120',
                subtitle: 'Stock Value',
                subtitleColor: Colors.blueGrey,
                onTap: () => _showDetailModal('Current Assets'),
              ),
              _metricCard(
                icon: Icons.remove_circle_outline,
                iconColor: Colors.red,
                title: 'Liabilities',
                value: ' 3,450',
                subtitle: 'Supplier Debts',
                subtitleColor: Colors.red,
                onTap: () => _showDetailModal('Liabilities'),
              ),
              _metricCard(
                icon: Icons.trending_up,
                iconColor: Colors.teal,
                title: 'Cash Flow',
                value: ' 1,350',
                subtitle: 'Inflow',
                subtitleColor: Colors.green,
                onTap: () => _showDetailModal('Cash Flow'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('More Data'),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sales Trends',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.onSurface)),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
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
                ),
                child: Row(
                  children: [
                    _countryButton('Malaysia', 0),
                    _countryButton('Egypt', 1),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _salesTrendCard(),
        ],
      ),
    );
  }

  Widget _periodButton(String label, int idx) {
    final bool selected = selectedPeriod == idx;
    return GestureDetector(
      onTap: () => setState(() => selectedPeriod = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withAlpha(210)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha((0.7 * 255).toInt()),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _countryButton(String label, int idx) {
    final bool selected = selectedCountry == idx;
    return GestureDetector(
      onTap: () => setState(() => selectedCountry = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha((0.7 * 255).toInt()),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 28,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 32),
                const SizedBox(width: 12),
                Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: subtitleColor,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _salesTrendCard() {
    // Dummy data
    final List<double> sales = [300, 400, 500, 600, 7000, 800, 900];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily Revenue',
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.blueGrey)),
              Text(' 416.67',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text('+5% vs yesterday',
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(sales.length, (i) {
                return Flexible(
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: i != sales.length - 1 ? 8.0 : 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: sales[i] / 6 > 90 ? 90 : sales[i] / 6,
                          width: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1978E5)
                                .withAlpha(((0.18 + i * 0.06) * 255).toInt()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(days[i],
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailModal(String metric) {
    if (metric == 'Current Assets') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => const _CurrentAssetsDetailSheet(),
      );
      return;
    }
    if (metric == 'Liabilities') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => const _LiabilitiesDetailSheet(),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('$metric details coming soon...',
              style: GoogleFonts.poppins(fontSize: 20)),
        ),
      ),
    );
  }
}

typedef _AssetData = Map<String, dynamic>;

class _CurrentAssetsDetailSheet extends StatelessWidget {
  final List<_AssetData> assets = const [
    {'label': 'Cash', 'value': 5000.0, 'color': Color(0xFF1978E5)},
    {
      'label': 'Accounts Receivable',
      'value': 3500.0,
      'color': Color(0xFF3DD598)
    },
    {'label': 'Inventory', 'value': 4000.0, 'color': Color(0xFFFFC542)},
  ];
  final double total = 12500.0;

  const _CurrentAssetsDetailSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Text('Current Assets',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Current Assets',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.blueGrey)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE8F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('As of today',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF1978E5),
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(' ${total.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                      fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: _DonutChart(assets: assets, total: total),
              ),
              const SizedBox(height: 16),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: assets
                    .map((a) => Row(
                          children: [
                            Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                    color: a['color'], shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(a['label'],
                                style: GoogleFonts.poppins(fontSize: 15)),
                            const SizedBox(width: 2),
                            Text(
                                '${((a['value'] as double) / total * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.poppins(
                                    fontSize: 15, color: Colors.blueGrey)),
                          ],
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                    Text('Asset Breakdown',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    ...assets.map((a) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a['label'],
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  Text(
                                      '${((a['value'] as double) / total * 100).toStringAsFixed(0)}% of total',
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.blueGrey)),
                                ],
                              ),
                              Text(
                                '\$${(a['value'] as double).toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: a['label'] == 'Accounts Receivable'
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final List<_AssetData> assets;
  final double total;
  const _DonutChart({required this.assets, required this.total});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(180, 180),
      painter: _DonutChartPainter(assets: assets, total: total),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<_AssetData> assets;
  final double total;
  _DonutChartPainter({required this.assets, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 24;
    final double radius = (size.width / 2) - strokeWidth / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    double startAngle = -3.14 / 2;
    for (final a in assets) {
      final sweepAngle = ((a['value'] as double) / total) * 3.14 * 2;
      final paint = Paint()
        ..color = a['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Tambah widget untuk detail liabilities
class _LiabilitiesDetailSheet extends StatelessWidget {
  final List<Map<String, dynamic>> liabilities = const [
    {
      'label': 'Accounts Payable',
      'value': 10200.0,
      'due': '2024-08-15',
      'interest': 'N/A',
      'color': Colors.black,
      'highlight': false,
    },
    {
      'label': 'Short-term Loan',
      'value': 6375.0,
      'due': '2024-09-01',
      'interest': '5.25%',
      'color': Colors.red,
      'highlight': true,
    },
    {
      'label': 'Other Liabilities',
      'value': 8925.0,
      'due': '-',
      'interest': '-',
      'color': Colors.black,
      'highlight': false,
    },
  ];
  final double total = 25500.0;

  const _LiabilitiesDetailSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Text('Liabilities',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Liabilities',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.blueGrey)),
                    Row(
                      children: [
                        Text('+12%',
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Text('vs last month',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.blueGrey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(' ${total.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                      fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: _LiabilitiesDonutChart(total: total),
              ),
              const SizedBox(height: 16),
              // List breakdown
              ...liabilities.map((l) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l['label'],
                            style: GoogleFonts.poppins(fontSize: 16)),
                        Text(
                          '\$${(l['value'] as double).toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: l['color']),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Liability Details',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 12),
              ...liabilities.map((l) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l['label'],
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            Text(
                              '\$${(l['value'] as double).toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: l['highlight'] == true
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Due Date',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14, color: Colors.blueGrey)),
                                Text(l['due'],
                                    style: GoogleFonts.poppins(fontSize: 15)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Interest Rate',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14, color: Colors.blueGrey)),
                                Text(l['interest'],
                                    style: GoogleFonts.poppins(fontSize: 15)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiabilitiesDonutChart extends StatelessWidget {
  final double total;
  const _LiabilitiesDonutChart({required this.total});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(180, 180),
      painter: _LiabilitiesDonutChartPainter(total: total),
    );
  }
}

class _LiabilitiesDonutChartPainter extends CustomPainter {
  final double total;
  _LiabilitiesDonutChartPainter({required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 18;
    final double radius = (size.width / 2) - strokeWidth / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0, 3.14 * 2,
        false, paint);
    // Center text
    final textSpan = TextSpan(
      text: ' ${total.toStringAsFixed(1)}k',
      style: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    final offset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, offset);
    // Subtitle
    final subSpan = TextSpan(
      text: 'Total',
      style: GoogleFonts.poppins(
          fontSize: 16, color: Colors.white.withAlpha((0.7 * 255).toInt())),
    );
    final subPainter = TextPainter(
      text: subSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    subPainter.layout(minWidth: 0, maxWidth: size.width);
    final subOffset = Offset(
      center.dx - subPainter.width / 2,
      center.dy + textPainter.height / 2 - 2,
    );
    subPainter.paint(canvas, subOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
