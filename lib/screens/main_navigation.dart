import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_dashboard_screen.dart';
import 'settings_screen.dart';
import 'distribution_screen.dart';
import 'sales_history_screen.dart';
import 'pos_payments_screen.dart';
// Added import for ProfileScreen
import 'returns_screen.dart'; // Added import for ReturnsScreen
import 'reports_screen.dart'; // Added import for ReportsScreen
import 'book_list_tab.dart';
import 'financial_overview_screen.dart';

// Anda boleh tambah import untuk SearchScreen dan LibraryScreen jika ada

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _bottomNavIndex = 0;
  int _drawerIndex = -1;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Untuk bottom navbar
  late final List<Widget> _bottomNavScreens;

  @override
  void initState() {
    super.initState();
    _bottomNavScreens = [
      HomeDashboardScreen(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      const BookListTab(), // Gantikan StockChartScreen dengan BookListTab
      const SalesHistoryScreen(),
      const PosPaymentsScreen(),
      const FinancialOverviewScreen(), // Ganti ProfileScreen dengan FinancialOverviewScreen
    ];
    _drawerScreens = [
      DistributionScreen(onBack: () => setState(() => _drawerIndex = -1)),
      PosPaymentsScreen(
          onBack: () => setState(() => _drawerIndex = -1),
          initialTab: 'payment'),
      SalesHistoryScreen(
          onBack: () => setState(() => _drawerIndex = -1)), // Payment History
      ReturnsScreen(onBack: () => setState(() => _drawerIndex = -1)),
      ReportsScreen(onBack: () => setState(() => _drawerIndex = -1)),
    ];
  }

  // Untuk sidebar
  late List<Widget> _drawerScreens;

  void _onDrawerTapped(int index) {
    setState(() {
      _drawerIndex = index;
    });
    Navigator.pop(context);
  }

  // Placeholder for logout function
  void _logout() {
    // Implement actual logout logic here
    // For now, just pop the drawer
    Navigator.pop(context);
    // Example: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      drawer: _bottomNavIndex == 0
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.only(
                        top: 16, left: 16, right: 16, bottom: 7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/logo_mrj.jpg',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Ruwaq Jawi',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: Text('Distribution', style: GoogleFonts.poppins()),
                    selected: _drawerIndex == 0,
                    onTap: () => _onDrawerTapped(0),
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: Text('POS', style: GoogleFonts.poppins()),
                    selected: _drawerIndex == 1,
                    onTap: () => _onDrawerTapped(1),
                  ),
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title:
                        Text('Payment History', style: GoogleFonts.poppins()),
                    selected: _drawerIndex == 2,
                    onTap: () => _onDrawerTapped(2),
                  ),
                  ListTile(
                    leading: const Icon(Icons.replay),
                    title: Text('Returns', style: GoogleFonts.poppins()),
                    selected: _drawerIndex == 3,
                    onTap: () => _onDrawerTapped(3),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: Text('Reports', style: GoogleFonts.poppins()),
                    selected: _drawerIndex == 4,
                    onTap: () => _onDrawerTapped(4),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text('Settings', style: GoogleFonts.poppins()),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text('Logout', style: GoogleFonts.poppins()),
                    onTap: _logout,
                  ),
                ],
              ),
            )
          : null,
      body: _drawerIndex == -1
          ? _bottomNavScreens[_bottomNavIndex]
          : _drawerScreens[_drawerIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
            _drawerIndex = -1;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).iconTheme.color?.withAlpha((0.6 * 255).toInt()),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Sales'),
          BottomNavigationBarItem(icon: Icon(Icons.tablet), label: 'POS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: 'Finance'),
        ],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
