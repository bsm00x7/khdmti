import 'package:flutter/material.dart';
import 'package:khdmti_project/controller/message_controller.dart';
import 'package:khdmti_project/models/chat_model.dart';
import 'package:khdmti_project/models/message_model.dart';
import 'package:khdmti_project/models/profile_model.dart';
import 'package:khdmti_project/views/message/message_screen.dart';
import 'package:provider/provider.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessageController(),
      child: const _ChatsListView(),
    );
  }
}

class _ChatsListView extends StatelessWidget {
  const _ChatsListView();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MessageController>();

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<ChatModel>>(
          stream: controller.chatsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final chats = snapshot.data ?? [];

            if (chats.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No conversations yet',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final otherUserId = controller.getOtherUserId(chat);

                return _ChatTile(
                  chat: chat,
                  otherUserId: otherUserId!,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => MessageController(),
                        child: MessageScreen(
                          idChat: chat.idChat.toString(),
                          otherUserId: otherUserId,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Chat Tile ──
class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String otherUserId;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.otherUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MessageController>();

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        controller.fetchProfile(otherUserId),
        controller.fetchLastMessage(chat.idChat.toString()),
      ]),
      builder: (context, snapshot) {
        final profile =
            snapshot.hasData ? snapshot.data![0] as UserProfileModel : null;
        final lastMessage =
            snapshot.hasData ? snapshot.data![1] as MessageModel? : null;

        final jobTitle = profile?.jobTitle ?? '...';
        final lastContent = lastMessage?.content ?? 'No messages yet';
        final lastTime = lastMessage != null
            ? controller.formatTime(lastMessage.createdAt.toIso8601String())
            : '';

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              jobTitle.isNotEmpty ? jobTitle[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 18,
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  jobTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (lastTime.isNotEmpty)
                Text(
                  lastTime,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              lastContent,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          onTap: onTap,
        );
      },
    );
  }
}
