import 'package:flutter/material.dart';
import 'package:khdmti_project/utils/responsive/responsive_helper.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // ── Mock Data ──────────────────────────────────────────────
  static final List<_NotificationGroup> _groups = [
    _NotificationGroup(
      label: "اليوم",
      items: [
        _NotificationItem(
          icon: Icons.check_circle_outline,
          iconColor: Color(0xff22C55E),
          title: "تم قبول طلبك",
          subtitle: "تم قبول طلب خدمة تصميم الشعار من قِبل المستقل أحمد.",
          time: "منذ 5 دقائق",
          isRead: false,
        ),
        _NotificationItem(
          icon: Icons.star_rounded,
          iconColor: Color(0xffEAB308),
          title: "تقييم جديد",
          subtitle: "أضاف محمد علي تقييمًا جديدًا على خدمتك.",
          time: "منذ 30 دقيقة",
          isRead: false,
        ),
        _NotificationItem(
          icon: Icons.payment_outlined,
          iconColor: Color(0xff1173D4),
          title: "تم الدفع بنجاح",
          subtitle: "استلمت دفعة بقيمة 200 د.ت مقابل خدمة تركيب الأثاث.",
          time: "منذ ساعة",
          isRead: false,
        ),
      ],
    ),
    _NotificationGroup(
      label: "أمس",
      items: [
        _NotificationItem(
          icon: Icons.message_outlined,
          iconColor: Color(0xffA855F7),
          title: "رسالة جديدة",
          subtitle: "أرسل إليك سامي بن علي رسالة جديدة بخصوص طلبك.",
          time: "أمس 14:30",
          isRead: true,
        ),
        _NotificationItem(
          icon: Icons.work_outline,
          iconColor: Color(0xffF97316),
          title: "طلب خدمة جديد",
          subtitle: "لديك طلب خدمة جديد: دروس تقوية في الرياضيات.",
          time: "أمس 10:00",
          isRead: true,
        ),
      ],
    ),
    _NotificationGroup(
      label: "هذا الأسبوع",
      items: [
        _NotificationItem(
          icon: Icons.campaign_outlined,
          iconColor: Color(0xff38BDF8),
          title: "عرض خاص",
          subtitle: "احصل على خصم 20% عند نشر أول خدمة لك هذا الأسبوع.",
          time: "الإثنين 09:15",
          isRead: true,
        ),
        _NotificationItem(
          icon: Icons.info_outline,
          iconColor: Color(0xff64748B),
          title: "تحديث الشروط",
          subtitle: "تم تحديث شروط الاستخدام وسياسة الخصوصية. راجعها الآن.",
          time: "الأحد 08:00",
          isRead: true,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Unread count
    final unreadCount =
        _groups.expand((g) => g.items).where((i) => !i.isRead).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: context.pagePadding.copyWith(bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
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
                                : const Color(0xffE2E8F0),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: isDark
                              ? const Color(0xffCBD5E1)
                              : const Color(0xff475569),
                        ),
                      ),
                    ),

                    // Title + badge
                    Row(
                      children: [
                        Text(
                          "الإشعارات",
                          style: theme.textTheme.displayMedium!.copyWith(
                            fontSize: context.adaptiveFontSize(22),
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xff1173D4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$unreadCount",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Mark all read
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "قراءة الكل",
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: const Color(0xff1173D4),
                          fontWeight: FontWeight.w600,
                          fontSize: context.adaptiveFontSize(13),
                        ),
                      ),
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

              // ── Notification List ───────────────────────────────────
              Expanded(
                child: _groups.isEmpty
                    ? _EmptyState(isDark: isDark)
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          right: context.pagePadding.right,
                          left: context.pagePadding.left,
                          bottom: 24,
                        ),
                        itemCount: _groups.length,
                        itemBuilder: (context, groupIndex) {
                          final group = _groups[groupIndex];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Group Label ──
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 10),
                                child: Text(
                                  group.label,
                                  style: theme.textTheme.labelMedium!.copyWith(
                                    fontSize: context.adaptiveFontSize(12),
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xff64748B)
                                        : const Color(0xff94A3B8),
                                  ),
                                ),
                              ),

                              // ── Group Cards ──
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xff1E293B)
                                      : const Color(0xffFFFFFF),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: .05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children:
                                      group.items.asMap().entries.map((e) {
                                    final index = e.key;
                                    final item = e.value;
                                    return Column(
                                      children: [
                                        _NotificationTile(
                                          item: item,
                                          isDark: isDark,
                                        ),
                                        if (index < group.items.length - 1)
                                          Divider(
                                            height: 1,
                                            color: isDark
                                                ? const Color(0xff334155)
                                                : const Color(0xffF1F5F9),
                                            indent: 64,
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
            ],
          ),
        ),
      ),
    );
  }
}

// ── Models ───────────────────────────────────────────────────────────────────

class _NotificationGroup {
  final String label;
  final List<_NotificationItem> items;
  const _NotificationGroup({required this.label, required this.items});
}

class _NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool isRead;

  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isRead,
  });
}

// ── Notification Tile ─────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.isDark,
  });

  final _NotificationItem item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          // Unread highlight
          color: item.isRead
              ? Colors.transparent
              : const Color(0xff1173D4).withValues(alpha: .06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon Box ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.iconColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 22),
            ),

            const SizedBox(width: 12),

            // ── Content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row + time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontSize: context.adaptiveFontSize(14),
                            fontWeight:
                                item.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: isDark
                                ? const Color(0xffF1F5F9)
                                : const Color(0xff1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontSize: context.adaptiveFontSize(11),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: context.adaptiveFontSize(12),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Unread dot ──
            if (!item.isRead)
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
            child: Icon(
              Icons.notifications_off_outlined,
              size: 44,
              color: isDark ? const Color(0xff334155) : const Color(0xffCBD5E1),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "لا توجد إشعارات",
            style: theme.textTheme.displaySmall!.copyWith(
              fontSize: context.adaptiveFontSize(18),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ستظهر هنا جميع الإشعارات المتعلقة بطلباتك وخدماتك",
            style: theme.textTheme.bodySmall!.copyWith(
              fontSize: context.adaptiveFontSize(13),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
