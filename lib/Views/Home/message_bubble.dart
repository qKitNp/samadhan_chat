import 'package:flutter/material.dart';
import 'package:samadhan_chat/chat/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isBot) _buildBotAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: message.isBot 
                    ? Colors.grey[200] 
                    : Theme.of(context).primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(message.isBot ? 4 : 20),
                  topRight: Radius.circular(message.isBot ? 20 : 4),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: message.isBot 
                      ? CrossAxisAlignment.start 
                      : CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        color: message.isBot ? Colors.black87 : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.messageTime,
                          style: TextStyle(
                            color: message.isBot 
                                ? Colors.black45 
                                : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        if (!message.isBot) ...[
                          const SizedBox(width: 4),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (!message.isBot) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.android,
        size: 18,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 18,
        color: Colors.blue,
      ),
    );
  }

  // Widget _buildMessageStatus(MessageStatus status) {
  //   IconData icon;
  //   Color color;

  //   switch (status) {
  //     case MessageStatus.sending:
  //       icon = Icons.access_time;
  //       color = Colors.white70;
  //       break;
  //     case MessageStatus.sent:
  //       icon = Icons.check;
  //       color = Colors.white70;
  //       break;
  //     case MessageStatus.delivered:
  //       icon = Icons.done_all;
  //       color = Colors.white70;
  //       break;
  //     case MessageStatus.read:
  //       icon = Icons.done_all;
  //       color = Colors.blue[300]!;
  //       break;
  //     case MessageStatus.failed:
  //       icon = Icons.error_outline;
  //       color = Colors.red[300]!;
  //       break;
  //   }

  //   return Icon(
  //     icon,
  //     size: 14,
  //     color: color,
  //   );
  // }
}