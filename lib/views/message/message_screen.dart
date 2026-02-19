import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:khdmti_project/controller/message_controller.dart';
import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/models/message_model.dart';
import 'package:khdmti_project/models/profile_model.dart';

/// Standard usage — you already have the idChat (from ChatsListScreen):
///   MessageScreen(idChat: '...', otherUserId: '...')
///
/// From RequestScreen (accepted application) — only otherUserId known:
///   MessageScreen.fromUserId(otherUserId: '...')
///   The screen will resolve / create the chat automatically.
class MessageScreen extends StatelessWidget {
  final String? idChat;
  final String otherUserId;

  const MessageScreen({
    super.key,
    this.idChat,
    required this.otherUserId,
  });

  /// Named constructor used when navigating from RequestScreen.
  /// idChat is null → resolved in state.
  const MessageScreen.fromUserId({
    super.key,
    required this.otherUserId,
  }) : idChat = null;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessageController(),
      child: _MessageBody(
        initialIdChat: idChat,
        otherUserId: otherUserId,
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _MessageBody extends StatefulWidget {
  final String? initialIdChat;
  final String otherUserId;

  const _MessageBody({
    required this.initialIdChat,
    required this.otherUserId,
  });

  @override
  State<_MessageBody> createState() => _MessageBodyState();
}

class _MessageBodyState extends State<_MessageBody> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  String? _idChat;
  bool _resolving = false;
  UserProfileModel? _otherProfile;

  @override
  void initState() {
    super.initState();
    _idChat = widget.initialIdChat;
    _init();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final ctrl = context.read<MessageController>();

    // Load other user's profile for the AppBar
    _otherProfile = await ctrl.fetchProfile(widget.otherUserId);

    // If no idChat provided, resolve it from the DB
    if (_idChat == null) {
      setState(() => _resolving = true);
      try {
        _idChat = await ctrl.getOrCreateChat(widget.otherUserId);
      } catch (e) {
        debugPrint('MessageScreen: getOrCreateChat error – $e');
      } finally {
        if (mounted) setState(() => _resolving = false);
      }
    } else {
      if (mounted) setState(() {});
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final content = _inputCtrl.text.trim();
    if (content.isEmpty) return;
    _inputCtrl.clear();
    await context.read<MessageController>().sendMessage(
          userId2: widget.otherUserId,
          content: content,
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = Auth.getUserId();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC),
        appBar: _buildAppBar(isDark),
        body: _resolving || _idChat == null
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xff1173D4)))
            : Column(
                children: [
                  // ── Messages ─────────────────────────────
                  Expanded(
                    child: StreamBuilder<List<MessageModel>>(
                      stream: context
                          .read<MessageController>()
                          .messagesStream(_idChat!),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xff1173D4)),
                          );
                        }
                        if (snap.hasError) {
                          return Center(
                            child: Text('حدث خطأ في تحميل الرسائل',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: Colors.grey.shade500,
                                )),
                          );
                        }

                        final msgs = snap.data ?? [];

                        if (msgs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.waving_hand_outlined,
                                    size: 48,
                                    color: isDark
                                        ? const Color(0xff334155)
                                        : const Color(0xffE2E8F0)),
                                const SizedBox(height: 12),
                                Text('لا توجد رسائل بعد، ابدأ المحادثة! 👋',
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexSansArabic',
                                      color: isDark
                                          ? const Color(0xff64748B)
                                          : const Color(0xff94A3B8),
                                    )),
                              ],
                            ),
                          );
                        }

                        _scrollToBottom();

                        return ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: msgs.length,
                          itemBuilder: (_, i) {
                            final msg = msgs[i];
                            final isMe = msg.idSender == currentUserId;
                            final ctrl = context.read<MessageController>();

                            // Show date separator when day changes
                            final showDate = i == 0 ||
                                !_sameDay(msgs[i - 1].createdAt, msg.createdAt);

                            return Column(
                              children: [
                                if (showDate)
                                  _DateSeparator(
                                    date: msg.createdAt,
                                    isDark: isDark,
                                  ),
                                _MessageBubble(
                                  content: msg.content,
                                  time: ctrl.formatTime(
                                      msg.createdAt.toIso8601String()),
                                  isMe: isMe,
                                  isDark: isDark,
                                  onDelete: isMe && msg.id != null
                                      ? () =>
                                          _confirmDelete(context, ctrl, msg.id!)
                                      : null,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ── Input Bar ─────────────────────────────
                  _InputBar(
                    controller: _inputCtrl,
                    isDark: isDark,
                    onSend: _send,
                  ),
                ],
              ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    final name = _otherProfile?.jobTitle ?? '...';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return AppBar(
      backgroundColor: isDark ? const Color(0xff1E293B) : Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,
            color: isDark ? Colors.white : const Color(0xff1E293B), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xff1173D4).withValues(alpha: .12),
            child: Text(initial,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1173D4),
                  fontSize: 15,
                )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDark ? Colors.white : const Color(0xff1E293B),
                    ),
                    overflow: TextOverflow.ellipsis),
                Text('متصل',
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 11,
                      color: Color(0xff22C55E),
                    )),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _confirmDelete(BuildContext context, MessageController ctrl, int id) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف الرسالة؟',
              style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.w700)),
          content: const Text('سيتم إخفاء هذه الرسالة.',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ctrl.deleteMessage(id);
              },
              child: const Text('حذف',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.content,
    required this.time,
    required this.isMe,
    required this.isDark,
    this.onDelete,
  });

  final String content;
  final String time;
  final bool isMe;
  final bool isDark;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: GestureDetector(
        onLongPress: onDelete,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? const Color(0xff1173D4)
                : isDark
                    ? const Color(0xff1E293B)
                    : const Color(0xffF1F5F9),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 4 : 16),
              bottomRight: Radius.circular(isMe ? 16 : 4),
            ),
            border: isMe
                ? null
                : Border.all(
                    color: isDark
                        ? const Color(0xff334155)
                        : const Color(0xffE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                content,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  color: isMe
                      ? Colors.white
                      : isDark
                          ? const Color(0xffF1F5F9)
                          : const Color(0xff1E293B),
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 10,
                  color: isMe
                      ? Colors.white60
                      : isDark
                          ? const Color(0xff64748B)
                          : const Color(0xff94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Date Separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date, required this.isDark});
  final DateTime date;
  final bool isDark;

  String get _label {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _label,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 11,
                color:
                    isDark ? const Color(0xff64748B) : const Color(0xff94A3B8),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isDark,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: 12,
        left: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              textDirection: TextDirection.rtl,
              minLines: 1,
              maxLines: 4,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14,
                color:
                    isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
              ),
              decoration: InputDecoration(
                hintText: 'اكتب رسالة...',
                hintTextDirection: TextDirection.rtl,
                hintStyle: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xff475569)
                      : const Color(0xff94A3B8),
                ),
                filled: true,
                fillColor:
                    isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xff1173D4),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
