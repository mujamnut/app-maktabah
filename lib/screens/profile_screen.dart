import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            backgroundColor: Color(0xFFF8F9FA),
            elevation: 0,
            floating: true,
            snap: true,
            pinned: false,
            centerTitle: true,
            title: Text(
              'Profile',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            automaticallyImplyLeading: false, // tiada arrow back
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          const AssetImage('assets/profile_placeholder.png'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text('Muhammad Amir',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text('amir@syarikatbuku.my',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text('Admin · Aktif',
                        style: TextStyle(fontSize: 15, color: Colors.green)),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Registration',
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 15)),
                      Text('12 Jan 2024', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Last Login',
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 15)),
                      Text('10 Jul 2025, 10:05AM',
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F3F6),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Access Rights',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  _accessRightTile(Icons.add, 'Tambah Buku'),
                  _accessRightTile(Icons.show_chart, 'Lihat Jualan'),
                  _accessRightTile(Icons.people, 'Urus Akaun Staff'),
                  const SizedBox(height: 32),
                  const Text('Recent Activity',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  _activityTile(Icons.menu_book,
                      'Changed status of book "XYZ" on Jul ...'),
                  _activityTile(
                      Icons.inventory, 'Added stock for "ABC" on Jul 9'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accessRightTile(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          const Icon(Icons.circle, color: Colors.green, size: 16),
        ],
      ),
    );
  }

  Widget _activityTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
