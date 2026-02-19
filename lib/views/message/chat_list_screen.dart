import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:khdmti_project/controller/message_controller.dart';
import 'package:khdmti_project/models/chat_model.dart';
import 'package:khdmti_project/models/message_model.dart';
import 'package:khdmti_project/models/profile_model.dart';
import 'package:khdmti_project/views/message/message_screen.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessageController(),
      child: const _ChatsListBody(),
    );
  }
}

class _ChatsListBody extends StatelessWidget {
  const _ChatsListBody();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.read<MessageController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xff1E293B) : Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'المحادثات',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: isDark ? Colors.white : const Color(0xff1E293B),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
            ),
          ),
        ),
        body: StreamBuilder<List<ChatModel>>(
          stream: controller.chatsStream,
          builder: (context, snapshot) {
            // ── Loading ──
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xff1173D4)),
              );
            }

            // ── Error ──
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text('حدث خطأ في تحميل المحادثات',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          color: isDark
                              ? const Color(0xff94A3B8)
                              : const Color(0xff64748B),
                        )),
                  ],
                ),
              );
            }

            final chats = snapshot.data ?? [];

            // ── Empty ──
            if (chats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xff1173D4).withValues(alpha: .08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chat_bubble_outline,
                          size: 40, color: Color(0xff1173D4)),
                    ),
                    const SizedBox(height: 16),
                    Text('لا توجد محادثات بعد',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xffF1F5F9)
                              : const Color(0xff1E293B),
                        )),
                    const SizedBox(height: 8),
                    Text('ستبدأ محادثاتك عند قبول أحد الطلبات',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xff64748B)
                              : const Color(0xff94A3B8),
                        )),
                  ],
                ),
              );
            }

            // ── List ──
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 76,
                color:
                    isDark ? const Color(0xff334155) : const Color(0xffF1F5F9),
              ),
              itemBuilder: (_, i) {
                final chat = chats[i];
                final otherUserId = controller.getOtherUserId(chat)!;
                return _ChatTile(
                  chat: chat,
                  otherUserId: otherUserId,
                  isDark: isDark,
                  controller: controller,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Chat Tile ─────────────────────────────────────────────────────────────────

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.otherUserId,
    required this.isDark,
    required this.controller,
  });

  final ChatModel chat;
  final String otherUserId;
  final bool isDark;
  final MessageController controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        controller.fetchProfile(otherUserId),
        controller.fetchLastMessage(chat.idChat.toString()),
      ]),
      builder: (context, snapshot) {
        final profile =
            snapshot.hasData ? snapshot.data![0] as UserProfileModel : null;
        final lastMsg =
            snapshot.hasData ? snapshot.data![1] as MessageModel? : null;

        final name = profile?.jobTitle ?? '...';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
        final preview = lastMsg?.content ?? 'لا توجد رسائل بعد';
        final time = lastMsg != null
            ? controller.formatTime(lastMsg.createdAt.toIso8601String())
            : '';

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xff1173D4).withValues(alpha: .12),
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontWeight: FontWeight.w700,
                color: Color(0xff1173D4),
                fontSize: 18,
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xffF1F5F9)
                        : const Color(0xff1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 11,
                    color: Color(0xff94A3B8),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 12,
                color:
                    isDark ? const Color(0xff64748B) : const Color(0xff94A3B8),
              ),
            ),
          ),
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
  }
}
