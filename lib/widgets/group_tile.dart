import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/group_model.dart';

class GroupTile extends StatelessWidget {
  final GroupModel group;
  final bool isMember;
  final VoidCallback onTap;
  final VoidCallback? onJoinLeave;

  const GroupTile({
    super.key,
    required this.group,
    required this.isMember,
    required this.onTap,
    this.onJoinLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: ListTile(
        onTap: onTap,
        leading: group.coverUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: group.coverUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.group),
              ),
        title: Text(group.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${group.members.length} member${group.members.length == 1 ? '' : 's'} • ${group.isPrivate ? "🔒 Private" : "🌐 Public"}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: onJoinLeave != null
            ? TextButton(
                onPressed: onJoinLeave,
                style: TextButton.styleFrom(
                  foregroundColor: isMember ? Colors.red : Theme.of(context).colorScheme.primary,
                ),
                child: Text(isMember ? 'Leave' : 'Join',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              )
            : null,
      ),
    );
  }
}




