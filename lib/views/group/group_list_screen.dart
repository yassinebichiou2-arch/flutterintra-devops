import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../widgets/group_tile.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final groupProv = context.read<GroupProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'All Groups'), Tab(text: 'My Groups')],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // All groups
          StreamBuilder<List<GroupModel>>(
            stream: groupProv.getAllGroups(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final groups = snap.data ?? [];
              if (groups.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No groups yet',
                          style: TextStyle(color: Colors.grey, fontSize: 15)),
                      SizedBox(height: 4),
                      Text('Be the first to create one!',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (_, i) {
                  final g = groups[i];
                  final isMember =
                      auth.user != null && g.members.contains(auth.user!.id);
                  return GroupTile(
                    group: g,
                    isMember: isMember,
                    onTap: () => _openGroup(context, g),
                    onJoinLeave: auth.user == null
                        ? null
                        : () => isMember
                            ? groupProv.leaveGroup(g.id, auth.user!.id)
                            : groupProv.joinGroup(g.id, auth.user!.id),
                  );
                },
              );
            },
          ),
          // My groups
          auth.user == null
              ? const Center(child: Text('Login to see your groups'))
              : StreamBuilder<List<GroupModel>>(
                  stream: groupProv.getUserGroups(auth.user!.id),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final groups = snap.data ?? [];
                    if (groups.isEmpty) {
                      return const Center(
                          child: Text('You have not joined any groups'));
                    }
                    return ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (_, i) => GroupTile(
                        group: groups[i],
                        isMember: true,
                        onTap: () => _openGroup(context, groups[i]),
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openGroup(BuildContext context, GroupModel g) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => GroupDetailScreen(group: g)));
  }
}




