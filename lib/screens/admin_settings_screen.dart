import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'System Settings',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // to balance the back button
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('General System Settings'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              title: 'Company Name',
              value: 'Acme Corp',
              onTap: () {},
            ),
            _buildSettingsTile(
              title: 'Logo & Branding',
              value: 'Current Logo',
              onTap: () {},
            ),
            _buildSettingsTile(
              title: 'Timezone & Date Format',
              value: 'GMT+8, DD/MM/YYYY',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Account & Role Settings'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              title: 'Manage Roles',
              value: 'Admin, Sales Staff, Warehouse, Accountant',
              onTap: () {},
            ),
            _buildSettingsTile(
              title: 'Role Permissions',
              value: 'View & Edit Permissions',
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Add New Role', style: TextStyle(fontSize: 17)),
              trailing: const Icon(Icons.add, size: 28),
              onTap: () {},
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Tax / Pricing Settings'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              title: 'SST / GST Rates',
              value: '6% SST, 0% GST',
              onTap: () {},
            ),
            _buildSettingsTile(
              title: 'Price Markup Formulas',
              value: 'Markup Formula',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Inventory Settings'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              title: 'Default Storage Location',
              value: 'Main Warehouse',
              onTap: () {},
            ),
            _buildSettingsTile(
              title: 'Low Stock Notifications',
              value: 'Notify at 10 units',
              onTap: () {},
            ),
            _buildSettingsTile(
              title: 'Auto Reorder Triggers',
              value: 'Reorder at 5 units',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 17)),
      subtitle:
          Text(value, style: const TextStyle(fontSize: 15, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 20),
      onTap: onTap,
    );
  }
}
