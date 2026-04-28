import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../services/group_service.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/user_avatar.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _userService = UserService();
  final _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();

    // Block non-admins
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text('Access denied — Admins only',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.group), text: 'Groups'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _UsersTab(userService: _userService),
          _GroupsTab(groupService: _groupService),
          _StatsTab(userService: _userService, groupService: _groupService),
        ],
      ),
    );
  }
}

// ── Users Tab ──────────────────────────────────────────────────────────────
class _UsersTab extends StatefulWidget {
  final UserService userService;
  const _UsersTab({required this.userService});

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<UserModel> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await widget.userService.getAllUsers();
    if (mounted) setState(() { _users = users; _loading = false; });
  }

  Future<void> _toggleRole(UserModel user) async {
    final newRole = user.role == 'admin' ? 'employee' : 'admin';
    await widget.userService.updateUserRole(user.id, newRole);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${user.name} is now $newRole'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete User'),
        content: Text('Delete ${user.name}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error, minimumSize: Size.zero),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.userService.deleteUser(user.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final u = _users[i];
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: ListTile(
              leading: UserAvatar(photoUrl: u.photoUrl, name: u.name, radius: 22),
              title: Text(u.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(u.email, style: const TextStyle(fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Role badge
                  GestureDetector(
                    onTap: () => _toggleRole(u),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: u.role == 'admin'
                            ? Colors.orange.withValues(alpha: 0.15)
                            : AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        u.role == 'admin' ? 'Admin' : 'Employee',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: u.role == 'admin'
                              ? Colors.orange
                              : AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppTheme.error, size: 20),
                    onPressed: () => _deleteUser(u),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Groups Tab ─────────────────────────────────────────────────────────────
class _GroupsTab extends StatelessWidget {
  final GroupService groupService;
  const _GroupsTab({required this.groupService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: groupService.getAllGroups(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final groups = snap.data ?? [];
        if (groups.isEmpty) {
          return const Center(child: Text('No groups yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final g = groups[i];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      AppTheme.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.group, color: AppTheme.primary),
                ),
                title: Text(g.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                    '${g.members.length} members • ${g.isPrivate ? "Private" : "Public"}',
                    style: const TextStyle(fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.error, size: 20),
                  onPressed: () async {
                    await groupService.deleteGroup(g.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Group "${g.name}" deleted'),
                        backgroundColor: AppTheme.error,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Stats Tab ──────────────────────────────────────────────────────────────
class _StatsTab extends StatefulWidget {
  final UserService userService;
  final GroupService groupService;
  const _StatsTab(
      {required this.userService, required this.groupService});

  @override
  State<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  int _userCount = 0;
  int _groupCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await widget.userService.getAllUsers();
    final groups = await widget.groupService.getAllGroups().first;
    if (mounted) {
      setState(() {
        _userCount = users.length;
        _groupCount = groups.length;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _StatCard(
            icon: Icons.people_rounded,
            label: 'Total Users',
            value: '$_userCount',
            color: AppTheme.primary,
          ),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.group_rounded,
            label: 'Total Groups',
            value: '$_groupCount',
            color: AppTheme.success,
          ),
          const SizedBox(height: 12),
          const _StatCard(
            icon: Icons.admin_panel_settings_rounded,
            label: 'Admins',
            value: '1',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13)),
              Text(value,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
