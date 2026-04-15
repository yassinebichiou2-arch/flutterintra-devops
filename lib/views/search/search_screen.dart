import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../providers/group_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/group_tile.dart';
import '../../widgets/user_avatar.dart';
import '../group/group_detail_screen.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  late TabController _tab;

  List<UserModel> _users = [];
  List<GroupModel> _groups = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tab.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        _users = [];
        _groups = [];
      });
      return;
    }
    setState(() => _loading = true);
    final query = q.trim().toLowerCase();
    final userProv = context.read<UserProvider>();
    final groupProv = context.read<GroupProvider>();

    final users = await userProv.searchUsers(query);
    final allGroups = await groupProv.getAllGroups().first;
    final groups = allGroups
        .where((g) =>
            g.name.toLowerCase().contains(query) ||
            g.description.toLowerCase().contains(query))
        .toList();

    if (!mounted) return;
    setState(() {
      _users = users;
      _groups = groups;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search users, groups...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            filled: false,
            isDense: true,
          ),
          onChanged: _search,
        ),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Users (${_users.length})'),
            Tab(text: 'Groups (${_groups.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _ctrl.text.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Search for users, groups or posts',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tab,
                  children: [                    // Users tab
                    _users.isEmpty
                        ? const Center(
                            child: Text('No users found',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (_, i) {
                              final u = _users[i];
                              return ListTile(
                                leading: UserAvatar(
                                    photoUrl: u.photoUrl,
                                    name: u.name,
                                    radius: 22),
                                title: Text(u.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle:
                                    Text(u.position ?? u.email),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: u.role == 'admin'
                                        ? Colors.orange.withValues(alpha: 0.15)
                                        : Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    u.role == 'admin' ? 'Admin' : 'Employee',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: u.role == 'admin'
                                            ? Colors.orange
                                            : Colors.blue),
                                  ),
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ProfileScreen(userId: u.id)),
                                ),
                              );
                            },
                          ),

                    // Groups tab
                    _groups.isEmpty
                        ? const Center(
                            child: Text('No groups found',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _groups.length,
                            itemBuilder: (_, i) => GroupTile(
                              group: _groups[i],
                              isMember: false,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => GroupDetailScreen(
                                        group: _groups[i])),
                              ),
                            ),
                          ),
                  ],
                ),
    );
  }
}
