import 'package:flutter/material.dart';
import 'package:khdmti_project/views/requestScreen/requset_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/utils/responsive/responsive_helper.dart';
import 'package:khdmti_project/views/message/message_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notification model (unified — messages + application updates)
// ─────────────────────────────────────────────────────────────────────────────

enum _NotifType {
  message,
  applicationAccepted,
  applicationRejected,
  newApplicant
}

class _Notif {
  final _NotifType type;
  final String title;
  final String subtitle;
  final DateTime createdAt;

  /// For message notifications: used to open MessageScreen
  final String? otherUserId;
  final String? idChat;

  const _Notif({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.otherUserId,
    this.idChat,
  });

  IconData get icon {
    switch (type) {
      case _NotifType.message:
        return Icons.chat_bubble_outline;
      case _NotifType.applicationAccepted:
        return Icons.check_circle_outline;
      case _NotifType.applicationRejected:
        return Icons.cancel_outlined;
      case _NotifType.newApplicant:
        return Icons.person_add_outlined;
    }
  }

  Color get color {
    switch (type) {
      case _NotifType.message:
        return const Color(0xffA855F7);
      case _NotifType.applicationAccepted:
        return const Color(0xff22C55E);
      case _NotifType.applicationRejected:
        return const Color(0xffEF4444);
      case _NotifType.newApplicant:
        return const Color(0xff1173D4);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _client = Supabase.instance.client;

  List<_Notif> _notifs = [];
  bool _loading = true;

  // IDs the user has "seen" this session (simulates read state in memory)
  final Set<String> _seenKeys = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Load all notification sources ─────────────────────────────────────────
  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final me = Auth.getUserId()!;
      final results = await Future.wait([
        _fetchMessageNotifs(me),
        _fetchApplicationNotifs(me),
        _fetchNewApplicantNotifs(me),
      ]);

      final all = [...results[0], ...results[1], ...results[2]];
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() => _notifs = all);
    } catch (e) {
      debugPrint('NotificationScreen._load: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Source 1: Unread messages (sent to me, not by me) ─────────────────────
  Future<List<_Notif>> _fetchMessageNotifs(String me) async {
    try {
      // My chats
      final chats = await _client
          .from('chats')
          .select('idChat, idUser1, idUser2')
          .or('idUser1.eq.$me,idUser2.eq.$me');

      if ((chats as List).isEmpty) return [];

      final chatIds = chats.map((c) => c['idChat'] as String).toList();

      // Latest message per chat not sent by me
      final List<_Notif> notifs = [];

      for (final chat in chats) {
        final idChat = chat['idChat'] as String;
        final otherUserId = chat['idUser1'] == me
            ? chat['idUser2'] as String
            : chat['idUser1'] as String;

        final msgs = await _client
            .from('message')
            .select('content, created_at, idSender')
            .eq('idChat', idChat)
            .eq('isDeleted', false)
            .neq('idSender', me)
            .order('created_at', ascending: false)
            .limit(1);

        if ((msgs as List).isEmpty) continue;

        final msg = msgs.first;

        // Fetch sender profile for name
        String senderName = 'مستخدم';
        try {
          final profile = await _client
              .from('userProfile')
              .select('jobTitle')
              .eq('id', otherUserId)
              .maybeSingle();
          if (profile != null) senderName = profile['jobTitle'] ?? senderName;
        } catch (_) {}

        notifs.add(_Notif(
          type: _NotifType.message,
          title: 'رسالة من $senderName',
          subtitle: msg['content'] as String,
          createdAt: DateTime.parse(msg['created_at']),
          otherUserId: otherUserId,
          idChat: idChat,
        ));
      }

      return notifs;
    } catch (e) {
      debugPrint('_fetchMessageNotifs: $e');
      return [];
    }
  }

  // ── Source 2: My application status updates ────────────────────────────────
  Future<List<_Notif>> _fetchApplicationNotifs(String me) async {
    try {
      final rows = await _client
          .from('job_applications')
          .select('status, created_at, post:post_id(postTitle)')
          .eq('applicant_id', me)
          .inFilter('status', [1, 2]) // 1=accepted 2=rejected
          .order('created_at', ascending: false)
          .limit(20);

      return (rows as List).map((r) {
        final status = r['status'] as int;
        final postTitle =
            (r['post'] as Map<String, dynamic>?)?['postTitle'] ?? 'خدمة';
        final isAccepted = status == 1;

        return _Notif(
          type: isAccepted
              ? _NotifType.applicationAccepted
              : _NotifType.applicationRejected,
          title: isAccepted ? 'تم قبول طلبك 🎉' : 'تم رفض طلبك',
          subtitle: isAccepted
              ? 'تم قبول تقديمك على خدمة "$postTitle". يمكنك التواصل الآن.'
              : 'لم يتم قبول تقديمك على خدمة "$postTitle" هذه المرة.',
          createdAt: DateTime.parse(r['created_at']),
        );
      }).toList();
    } catch (e) {
      debugPrint('_fetchApplicationNotifs: $e');
      return [];
    }
  }

  // ── Source 3: New applicants on MY posts ──────────────────────────────────
  Future<List<_Notif>> _fetchNewApplicantNotifs(String me) async {
    try {
      final rows = await _client
          .from('job_applications')
          .select('created_at, post:post_id(postTitle, id_user)')
          .eq('status', 0) // pending only
          .order('created_at', ascending: false)
          .limit(30);

      return (rows as List).where((r) {
        final post = r['post'] as Map<String, dynamic>?;
        return post != null && post['id_user'] == me;
      }).map((r) {
        final postTitle =
            (r['post'] as Map<String, dynamic>)['postTitle'] ?? 'خدمتك';
        return _Notif(
          type: _NotifType.newApplicant,
          title: 'متقدّم جديد',
          subtitle: 'تلقّيت طلب تقديم جديد على خدمة "$postTitle".',
          createdAt: DateTime.parse(r['created_at']),
        );
      }).toList();
    } catch (e) {
      debugPrint('_fetchNewApplicantNotifs: $e');
      return [];
    }
  }

  // ── Group by date ─────────────────────────────────────────────────────────
  Map<String, List<_Notif>> _grouped() {
    final now = DateTime.now();
    final Map<String, List<_Notif>> groups = {
      'اليوم': [],
      'أمس': [],
      'هذا الأسبوع': [],
      'أقدم': [],
    };

    for (final n in _notifs) {
      final diff = now.difference(n.createdAt);
      if (diff.inDays == 0) {
        groups['اليوم']!.add(n);
      } else if (diff.inDays == 1) {
        groups['أمس']!.add(n);
      } else if (diff.inDays <= 7) {
        groups['هذا الأسبوع']!.add(n);
      } else {
        groups['أقدم']!.add(n);
      }
    }

    // Remove empty groups
    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays == 1) return 'أمس';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _notifKey(_Notif n) =>
      '${n.type.name}_${n.createdAt.millisecondsSinceEpoch}';

  int get _unreadCount =>
      _notifs.where((n) => !_seenKeys.contains(_notifKey(n))).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) {
        _seenKeys.add(_notifKey(n));
      }
    });
  }

  // ── Navigate on tap ───────────────────────────────────────────────────────
  void _onTap(BuildContext context, _Notif n) {
    setState(() => _seenKeys.add(_notifKey(n)));

    switch (n.type) {
      case _NotifType.message:
        if (n.otherUserId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MessageScreen.fromUserId(otherUserId: n.otherUserId!),
            ),
          );
        }
        break;
      case _NotifType.applicationAccepted:
      case _NotifType.applicationRejected:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RequestScreen()),
        );
        break;
      case _NotifType.newApplicant:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RequestScreen()),
        );
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final grouped = _grouped();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────
              Padding(
                padding: context.pagePadding.copyWith(bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xff1E293B)
                              : const Color(0xffF1F5F9),
                          border: Border.all(
                              color: isDark
                                  ? const Color(0xff334155)
                                  : const Color(0xffE2E8F0)),
                        ),
                        child: Icon(Icons.arrow_forward_ios,
                            size: 18,
                            color: isDark
                                ? const Color(0xffCBD5E1)
                                : const Color(0xff475569)),
                      ),
                    ),

                    // Title + badge
                    Row(
                      children: [
                        Text('الإشعارات',
                            style: theme.textTheme.displayMedium!.copyWith(
                                fontSize: context.adaptiveFontSize(22))),
                        if (_unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xff1173D4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('$_unreadCount',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),

                    // Mark all read
                    GestureDetector(
                      onTap: _markAllRead,
                      child: Text('قراءة الكل',
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: const Color(0xff1173D4),
                            fontWeight: FontWeight.w600,
                            fontSize: context.adaptiveFontSize(13),
                          )),
                    ),
                  ],
                ),
              ),

              Divider(
                color:
                    isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
                thickness: 1,
                height: 24,
              ),

              // ── Body ──────────────────────────────────────────────
              Expanded(
                child: _loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xff1173D4)))
                    : _notifs.isEmpty
                        ? _EmptyState(isDark: isDark)
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: const Color(0xff1173D4),
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                right: context.pagePadding.right,
                                left: context.pagePadding.left,
                                bottom: 24,
                              ),
                              itemCount: grouped.length,
                              itemBuilder: (context, gi) {
                                final label = grouped.keys.elementAt(gi);
                                final items = grouped[label]!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Group label
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, bottom: 10),
                                      child: Text(label,
                                          style: theme.textTheme.labelMedium!
                                              .copyWith(
                                            fontSize:
                                                context.adaptiveFontSize(12),
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? const Color(0xff64748B)
                                                : const Color(0xff94A3B8),
                                          )),
                                    ),

                                    // Cards group
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xff1E293B)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children:
                                            items.asMap().entries.map((e) {
                                          final idx = e.key;
                                          final notif = e.value;
                                          final isRead = _seenKeys
                                              .contains(_notifKey(notif));

                                          return Column(
                                            children: [
                                              _NotifTile(
                                                notif: notif,
                                                isRead: isRead,
                                                isDark: isDark,
                                                timeLabel:
                                                    _timeAgo(notif.createdAt),
                                                onTap: () =>
                                                    _onTap(context, notif),
                                              ),
                                              if (idx < items.length - 1)
                                                Divider(
                                                  height: 1,
                                                  indent: 64,
                                                  color: isDark
                                                      ? const Color(0xff334155)
                                                      : const Color(0xffF1F5F9),
                                                ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Notification Tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.notif,
    required this.isRead,
    required this.isDark,
    required this.timeLabel,
    required this.onTap,
  });

  final _Notif notif;
  final bool isRead;
  final bool isDark;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.transparent
              : const Color(0xff1173D4).withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon box
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notif.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notif.icon, color: notif.color, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(notif.title,
                            style: theme.textTheme.titleSmall!.copyWith(
                              fontSize: context.adaptiveFontSize(14),
                              fontWeight:
                                  isRead ? FontWeight.w500 : FontWeight.w700,
                              color: isDark
                                  ? const Color(0xffF1F5F9)
                                  : const Color(0xff1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text(timeLabel,
                          style: theme.textTheme.bodySmall!.copyWith(
                              fontSize: context.adaptiveFontSize(11))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notif.subtitle,
                      style: theme.textTheme.bodySmall!.copyWith(
                          fontSize: context.adaptiveFontSize(12), height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),

            // Unread dot
            if (!isRead)
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xff1173D4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xff1E293B) : const Color(0xffF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_outlined,
                size: 44,
                color:
                    isDark ? const Color(0xff334155) : const Color(0xffCBD5E1)),
          ),
          const SizedBox(height: 20),
          Text('لا توجد إشعارات',
              style: theme.textTheme.displaySmall!
                  .copyWith(fontSize: context.adaptiveFontSize(18))),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا الرسائل وتحديثات الطلبات وخدماتك',
            style: theme.textTheme.bodySmall!
                .copyWith(fontSize: context.adaptiveFontSize(13)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
