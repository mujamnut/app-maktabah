// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:book_app/screens/manage_staff_screen.dart';
import 'package:provider/provider.dart' as flutter_provider;
import 'package:easy_localization/easy_localization.dart';
import '../../theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? displayName;
  String? email;
  String? avatarUrl;
  String? lastSignIn;
  String? userRole; // Tambah state untuk role
  bool isLoading = true;
  bool _disposed = false;
  bool isDarkMode = false;
  String language = 'ms'; // 'ms' untuk BM, 'en' untuk English

  @override
  void initState() {
    super.initState();
    fetchAuthProfile();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchAuthProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!_disposed) {
        setState(() {
          isLoading = false;
          displayName = null;
          email = null;
          avatarUrl = null;
          lastSignIn = null;
          userRole = null;
        });
      }
      return;
    }
    // Format last sign in: yyyy-MM-dd hh:mm
    String? formattedLastSignIn;
    if (user.lastSignInAt != null) {
      final dt = DateTime.tryParse(user.lastSignInAt!);
      if (dt != null) {
        final date =
            "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
        final time =
            "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
        formattedLastSignIn = "$date $time";
      } else {
        formattedLastSignIn = '-';
      }
    } else {
      formattedLastSignIn = '-';
    }
    // Dapatkan role dari table profiles
    String? role;
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      role = profile?['role'] ?? 'staff';
    } catch (e) {
      role = 'staff';
    }
    if (!_disposed) {
      setState(() {
        displayName = user.userMetadata?['name'] ??
            user.userMetadata?['full_name'] ??
            '-';
        email = user.email;
        avatarUrl = user.userMetadata?['avatar_url'] ?? '';
        lastSignIn = formattedLastSignIn;
        userRole = role;
        isLoading = false;
      });
    }
  }

  // Edit profile dialog masih boleh kekalkan, tapi hanya untuk display name & avatar url (jika mahu)
  Future<void> showEditProfileDialog() async {
    final nameController = TextEditingController(text: displayName);
    final avatarController = TextEditingController(text: avatarUrl);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            TextField(
              controller: avatarController,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result == true) {
      // Untuk update display name/avatar url di auth, perlu guna updateUser
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'name': nameController.text,
            'avatar_url': avatarController.text,
          },
        ),
      );
      if (!_disposed) {
        setState(() {
          displayName = nameController.text;
          avatarUrl = avatarController.text;
        });
      }
    }
  }

  void _showPrivacySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final themeProvider =
            flutter_provider.Provider.of<ThemeProvider>(context, listen: false);
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('privacy'.tr(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('dark_mode'.tr(), style: const TextStyle(fontSize: 16)),
                  Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (val) {
                      themeProvider.toggleTheme(val);
                      Navigator.pop(context);
                      _showPrivacySheet();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('language'.tr(), style: const TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: context.locale.languageCode,
                    items: const [
                      DropdownMenuItem(value: 'ms', child: Text('BM')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (val) {
                      if (val != null) context.setLocale(Locale(val));
                      Navigator.pop(context);
                      _showPrivacySheet();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    flutter_provider.Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('settings'.tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Profile Card
                Container(
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
                    // Tiada border
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              backgroundImage:
                                  avatarUrl != null && avatarUrl!.isNotEmpty
                                      ? NetworkImage(avatarUrl!)
                                      : null,
                              child: avatarUrl == null || avatarUrl!.isEmpty
                                  ? Icon(Icons.person,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      size: 40)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.edit,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                onPressed: showEditProfileDialog,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(displayName ?? '-',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text(email ?? '-',
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color)),
                      const SizedBox(height: 4),
                      Text('Role: ${userRole ?? '-'}',
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 4),
                      Text('Last sign in: ${lastSignIn ?? '-'}',
                          style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Menu List
                ...[
                  _SettingsMenuItem(
                    icon: Icons.person_outline,
                    title: 'account'.tr(),
                    onTap: () {},
                  ),
                  _SettingsMenuItem(
                    icon: Icons.shield_outlined,
                    title: 'security'.tr(),
                    onTap: () {},
                  ),
                  _SettingsMenuItem(
                    icon: Icons.notifications_none,
                    title: 'notifications'.tr(),
                    onTap: () {},
                  ),
                  if (userRole == 'admin')
                    _SettingsMenuItem(
                      icon: Icons.groups_outlined,
                      title: 'manage_staff'.tr(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ManageStaffScreen()),
                        );
                      },
                    ),
                  _SettingsMenuItem(
                    icon: Icons.event_note_outlined,
                    title: 'privacy'.tr(),
                    onTap: _showPrivacySheet,
                  ),
                  _SettingsMenuItem(
                    icon: Icons.help_outline,
                    title: 'help_faq'.tr(),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Bantuan & FAQ'),
                          content: const SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bagaimana cara menambah buku?'),
                                Text(
                                    'Pergi ke Dashboard dan tekan butang tambah.'),
                                SizedBox(height: 12),
                                Text('Bagaimana untuk reset kata laluan?'),
                                Text(
                                    'Pergi ke menu Security dan pilih reset password.'),
                                SizedBox(height: 12),
                                Text(
                                    'Ada masalah lain? Hubungi admin di admin@email.com.'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tutup'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _SettingsMenuItem(
                    icon: Icons.description_outlined,
                    title: 'terms'.tr(),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Terma Perkhidmatan'),
                          content: const SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '1. Anda bersetuju untuk menggunakan aplikasi ini secara bertanggungjawab.'),
                                SizedBox(height: 8),
                                Text(
                                    '2. Data buku dan pengguna adalah hak milik syarikat.'),
                                SizedBox(height: 8),
                                Text(
                                    '3. Syarikat tidak bertanggungjawab atas kehilangan data akibat kecuaian pengguna.'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tutup'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _SettingsMenuItem(
                    icon: Icons.info_outline,
                    title: 'app_version'.tr(),
                    trailing: const Text('1.2.3',
                        style: TextStyle(color: Colors.grey)),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Book App',
                        applicationVersion: '1.2.3',
                        applicationLegalese: '© 2024 Syarikat Buku',
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                              'Aplikasi pengurusan buku untuk syarikat dan individu.'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Log out
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text('logout'.tr(),
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }
                    },
                  ),
                ],
              ],
            ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title,
          style: TextStyle(
              fontSize: 17,
              color: Theme.of(context).textTheme.bodyLarge?.color)),
      trailing: trailing ??
          Icon(Icons.arrow_forward_ios,
              size: 18, color: Theme.of(context).iconTheme.color),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Theme.of(context).colorScheme.surface,
      dense: true,
      minLeadingWidth: 32,
    );
  }
}
