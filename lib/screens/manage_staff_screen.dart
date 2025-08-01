import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/book_service.dart';

class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({Key? key}) : super(key: key);

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  List<Map<String, dynamic>> staffList = [];
  List<Map<String, dynamic>> filteredStaff = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    fetchStaff();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _disposed = true;
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchStaff() async {
    try {
      if (!_disposed) setState(() => isLoading = true);
      final data = await Supabase.instance.client
          .from('profiles')
          .select('id, name, role, avatar_url, email')
          .eq('is_deleted', false) // Tambah filter untuk soft delete
          .order('email');
      staffList = List<Map<String, dynamic>>.from(data ?? []);
      filteredStaff = staffList;
      if (!_disposed) setState(() => isLoading = false);
    } catch (e) {
      if (!_disposed) {
        setState(() {
          isLoading = false;
          staffList = [];
          filteredStaff = [];
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
      filteredStaff = staffList.where((staff) {
        final name = (staff['name'] ?? '').toString().toLowerCase();
        final role = (staff['role'] ?? '').toString().toLowerCase();
        return name.contains(searchQuery) || role.contains(searchQuery);
      }).toList();
    });
  }

  Future<void> _showAddStaffDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'staff';
    bool isLoading = false;
    String? errorMsg;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Staf'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedRole = value ?? 'staff');
                  },
                ),
                if (errorMsg != null) ...[
                  const SizedBox(height: 12),
                  Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      try {
                        final response =
                            await Supabase.instance.client.auth.signUp(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        final user = response.user;
                        if (user != null) {
                          // Insert ke table profiles dengan role yang dipilih
                          await Supabase.instance.client
                              .from('profiles')
                              .insert({
                            'id': user.id,
                            'email': user.email,
                            'role': selectedRole,
                          });
                          if (context.mounted) {
                            Navigator.pop(context, true);
                          }
                        } else {
                          setState(() => errorMsg = 'Pendaftaran gagal.');
                        }
                      } catch (e) {
                        setState(() => errorMsg = e.toString());
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      await fetchStaff();
    }
  }

  // Padam fungsi _showUpdateStaffDialog sepenuhnya

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Staff Management',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withAlpha((0.12 * 255).toInt())
                      : Theme.of(context).dividerColor,
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search for staff members...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search,
                      color: Theme.of(context).iconTheme.color),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'Staff Members',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStaff.isEmpty
                    ? const Center(child: Text('No staff found.'))
                    : ListView.separated(
                        itemCount: filteredStaff.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 0),
                        itemBuilder: (context, index) {
                          final staff = filteredStaff[index];
                          final avatarUrl = staff['avatar_url'] ?? '';
                          final name = staff['name'] ?? '';
                          final email = staff['email'] ?? '';
                          final role = staff['role'] ?? '';
                          String initials = '';
                          if (name.isNotEmpty) {
                            final parts = name.split(' ');
                            initials = parts.length > 1
                                ? parts[0][0] + parts[1][0]
                                : parts[0][0];
                          } else if (email.isNotEmpty) {
                            initials = email[0].toUpperCase();
                          }
                          return InkWell(
                            onTap: () async {
                              // Papar detail user dan senarai buku
                              await showDialog(
                                context: context,
                                builder: (context) =>
                                    _UserDetailDialog(user: staff),
                              );
                            },
                            borderRadius: BorderRadius.circular(14),
                            splashColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(40),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withAlpha((0.10 * 255).toInt()),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                  if (Theme.of(context).brightness ==
                                      Brightness.dark)
                                    BoxShadow(
                                      color: Colors.white
                                          .withAlpha((0.08 * 255).toInt()),
                                      blurRadius: 8,
                                      offset: const Offset(0, 0),
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  avatarUrl.isNotEmpty
                                      ? CircleAvatar(
                                          radius: 22,
                                          backgroundImage:
                                              NetworkImage(avatarUrl),
                                        )
                                      : CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          child: Text(
                                            initials,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(email,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface)),
                                        Text(role,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_horiz,
                                        color:
                                            Theme.of(context).iconTheme.color),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        await showDialog(
                                          context: context,
                                          builder: (context) => _EditUserDialog(
                                              user: staff,
                                              onUpdated: fetchStaff),
                                        );
                                      } else if (value == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Padam Staff'),
                                            content: const Text(
                                                'Anda pasti mahu padam staff ini?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('Batal'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('Padam',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          try {
                                            // Soft delete untuk profiles
                                            await Supabase.instance.client
                                                .from('profiles')
                                                .update({
                                              'is_deleted': true
                                            }).eq('id', staff['id']);
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Gagal padam staff: ${e.toString()}')),
                                              );
                                              return;
                                            }
                                          }
                                          try {
                                            // Padam dari admin_users
                                            await Supabase.instance.client
                                                .from('admin_users')
                                                .delete()
                                                .eq('id', staff['id']);
                                          } catch (e) {
                                            // Biarkan jika gagal, mungkin user bukan admin
                                          }
                                          await fetchStaff();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('Staff dipadam.')),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Padam'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 160,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _showAddStaffDialog,
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text('Add Staff',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF1F5FB),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // bottomNavigationBar dibuang supaya tiada navbar di skrin ini
    );
  }
}

// Tambah widget dialog detail user di bawah
class _UserDetailDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  const _UserDetailDialog({required this.user});

  @override
  State<_UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends State<_UserDetailDialog> {
  List books = [];
  bool isLoading = true;
  bool _disposed = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchBooks() async {
    try {
      final bookService = BookService();
      final author = widget.user['email'] ?? '-';
      final result = await bookService.fetchBooksByUser(author);
      if (!_disposed) {
        setState(() {
          books = result;
          isLoading = false;
          hasError = false;
        });
      }
    } catch (e) {
      if (!_disposed) {
        setState(() {
          books = [];
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return AlertDialog(
      title: const Text('Detail Staff'),
      content: SizedBox(
        width: 350,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  user['avatar_url'] != null && user['avatar_url'].isNotEmpty
                      ? CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(user['avatar_url']),
                        )
                      : CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            (() {
                              final str = (user['name'] ?? user['email'] ?? '-')
                                  .toString();
                              return str.isNotEmpty
                                  ? str[0].toUpperCase()
                                  : '-';
                            })(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['name'] ?? '-',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(user['email'] ?? '-',
                            style: const TextStyle(fontSize: 15)),
                        Text('Role: ${user['role'] ?? '-'}',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Senarai Buku Dimuat Naik:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (hasError)
                const Text('Ralat memuat data buku.')
              else if (books.isEmpty)
                const Text('Tiada buku dimasukkan oleh staff ini.')
              else
                Column(
                  children: books.map<Widget>((b) {
                    String title = '-';
                    String stock = '-';
                    String location = '-';
                    try {
                      if (b == null) {
                        // skip
                      } else if (b is Map) {
                        title = (b['title'] ?? '-').toString();
                        stock = (b['copies'] ?? '-').toString();
                        location = (b['location'] ?? '-').toString();
                      } else {
                        title = b.title != null ? b.title.toString() : '-';
                        stock = b.copies != null ? b.copies.toString() : '-';
                        location =
                            b.location != null ? b.location.toString() : '-';
                      }
                    } catch (_) {
                      title = '-';
                      stock = '-';
                      location = '-';
                    }
                    return ListTile(
                      title: Text(title),
                      subtitle: Text('Stok: $stock | Lokasi: $location'),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

// Tambah widget dialog edit user di bawah
class _EditUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUpdated;
  const _EditUserDialog({required this.user, required this.onUpdated});

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late TextEditingController emailController;
  String selectedRole = 'staff';
  bool isLoading = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.user['email'] ?? '');
    selectedRole = widget.user['role'] ?? 'staff';
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      await Supabase.instance.client.from('profiles').update({
        'email': emailController.text.trim(),
        'role': selectedRole,
      }).eq('id', widget.user['id']);
      // Kemas kini table admin_users
      if (selectedRole == 'admin') {
        // Masukkan ke admin_users jika belum ada
        await Supabase.instance.client
            .from('admin_users')
            .upsert({'id': widget.user['id']});
      } else {
        // Padam dari admin_users jika bukan admin
        await Supabase.instance.client
            .from('admin_users')
            .delete()
            .eq('id', widget.user['id']);
      }
      widget.onUpdated();
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Staff'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: const InputDecoration(labelText: 'Role'),
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'staff', child: Text('Staff')),
            ],
            onChanged: (val) => setState(() => selectedRole = val ?? 'staff'),
          ),
          if (errorMsg != null) ...[
            const SizedBox(height: 12),
            Text(errorMsg!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _save,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
