import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final color = isMe
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = isMe ? Colors.white : null;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(message.senderName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary)),
            if (message.content.isNotEmpty)
              Text(message.content,
                  style: TextStyle(color: textColor, fontSize: 15)),
            if (message.fileUrl != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.attach_file,
                      size: 16, color: isMe ? Colors.white70 : Colors.blue),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      message.fileName ?? 'File',
                      style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.blue,
                          fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  timeago.format(message.createdAt),
                  style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white60 : Colors.grey.shade500),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all,
                      size: 12,
                      color: Colors.white60),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}




