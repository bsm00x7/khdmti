import 'package:flutter/material.dart';
import 'package:khdmti_project/views/home/screen/search_results_screen.dart';
import 'package:khdmti_project/views/services/post_apply_buttom.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khdmti_project/comme_widget/responsive_avatar.dart';
import 'package:khdmti_project/controller/home_controller.dart';
import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/models/user_post_model.dart';
import 'package:khdmti_project/utils/responsive/responsive_helper.dart';
import 'package:khdmti_project/views/home/screen/notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_CategoryItem> _categories = [
    _CategoryItem(
        icon: Icons.school_outlined, label: "تعليم", color: Color(0xff22C55E)),
    _CategoryItem(
        icon: Icons.build_outlined, label: "صيانة", color: Color(0xffF97316)),
    _CategoryItem(
        icon: Icons.brush_outlined, label: "تصميم", color: Color(0xffA855F7)),
    _CategoryItem(icon: Icons.code, label: "برمجة", color: Color(0xff06B6D4)),
    _CategoryItem(
        icon: Icons.more_horiz, label: "المزيد", color: Color(0xff94A3B8)),
    _CategoryItem(
        icon: Icons.camera_alt_outlined,
        label: "تصوير",
        color: Color(0xffEAB308)),
    _CategoryItem(
        icon: Icons.translate, label: "ترجمة", color: Color(0xff3B82F6)),
    _CategoryItem(
        icon: Icons.local_shipping_outlined,
        label: "نقل",
        color: Color(0xffEC4899)),
  ];

  void _goToSearch(BuildContext context, String query) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SearchResultsScreen(initialQuery: query)),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUserId = Auth.user?.id;

    return ChangeNotifierProvider(
      create: (_) => HomeController()..init(),
      child: Scaffold(
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────
                  Consumer<HomeController>(
                    builder: (_, ctrl, __) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          ResponsiveAvatar(
                            imageFile: ctrl.imageFile,
                            imgPath: ctrl.imageUrl,
                            showBadge: false,
                            badgeFactor: 0.12,
                            sizeFactor: context.responsive(
                                mobile: 0.12, tablet: 0.09, desktop: 0.07),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("مرحباً بك 👋",
                                  style: theme.textTheme.titleMedium!.copyWith(
                                      fontSize: context.adaptiveFontSize(14))),
                              Text(ctrl.userName,
                                  style: theme.textTheme.displayMedium!
                                      .copyWith(
                                          fontSize:
                                              context.adaptiveFontSize(20))),
                            ],
                          ),
                        ]),
                        DecoratedBox(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              shape: BoxShape.circle),
                          child: IconButton(
                            icon: Icon(Icons.notifications_outlined,
                                color: isDark ? Colors.white : Colors.black),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const NotificationScreen())),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Search Bar ───────────────────────────
                  GestureDetector(
                    onTap: () => _goToSearch(context, ''),
                    child: AbsorbPointer(
                      child: SearchBar(
                        shape: const WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        leading: const Icon(Icons.search),
                        hintText: "ابحث عن خدمة، وظيفة...",
                        elevation: WidgetStateProperty.resolveWith((_) => 0),
                        backgroundColor: WidgetStateColor.resolveWith((_) =>
                            isDark
                                ? const Color(0xff1E293B)
                                : Colors.grey.shade200),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Categories ───────────────────────────
                  _SectionHeader(
                      title: "التصنيفات", theme: theme, onViewAll: () {}),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          context.responsive(mobile: 4, tablet: 6, desktop: 8),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (_, i) => _CategoryCard(
                      item: _categories[i],
                      onTap: () => _goToSearch(context, _categories[i].label),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─────────────────────────────────────────────────────────
                  // وظائف مميزة — posts from OTHER users  (horizontal cards)
                  // ─────────────────────────────────────────────────────────
                  _SectionHeader(
                    title: "وظائف مميزة",
                    theme: theme,
                    onViewAll: () => _goToSearch(context, ''),
                  ),
                  const SizedBox(height: 16),

                  _StreamSection<UserPostModel>(
                    height: context.responsive(
                        mobile: 200, tablet: 220, desktop: 240),
                    stream: currentUserId == null
                        ? const Stream.empty()
                        : Supabase.instance.client
                            .from('userPost')
                            .stream(primaryKey: ['id'])
                            .eq('isEnable', true)
                            .order('created_at', ascending: false)
                            .limit(20)
                            .map((rows) => rows
                                .where((r) =>
                                    r['isAvailable'] == true &&
                                    r['id_user'] != currentUserId)
                                .map(UserPostModel.fromJson)
                                .toList()),
                    emptyMessage: 'لا توجد وظائف متاحة حالياً',
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (post) => _FeaturedPostCard(post: post),
                    separatorWidth: 16,
                  ),

                  const SizedBox(height: 28),

                  // ─────────────────────────────────────────────────────────
                  // خدماتي المنشورة — CURRENT user's own posts (vertical list)
                  // ─────────────────────────────────────────────────────────
                  _SectionHeader(
                    title: "خدماتي المنشورة",
                    theme: theme,
                    onViewAll: () => _goToSearch(context, ''),
                  ),
                  const SizedBox(height: 16),

                  _StreamSection<UserPostModel>(
                    stream: currentUserId == null
                        ? const Stream.empty()
                        : Supabase.instance.client
                            .from('userPost')
                            .stream(primaryKey: ['id'])
                            .eq('id_user', currentUserId)
                            .order('created_at', ascending: false)
                            .limit(10)
                            .map((rows) =>
                                rows.map(UserPostModel.fromJson).toList()),
                    emptyMessage: 'لم تنشر أي خدمة بعد',
                    scrollDirection: Axis.vertical,
                    itemBuilder: (post) =>
                        _MyPostCard(post: post, isDark: isDark, theme: theme),
                    separatorHeight: 12,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Generic Stream Section ────────────────────────────────────────────────────
// Handles loading / error / empty / list for any stream of List<T>

class _StreamSection<T> extends StatelessWidget {
  const _StreamSection({
    required this.stream,
    required this.itemBuilder,
    required this.emptyMessage,
    required this.scrollDirection,
    this.height,
    this.separatorWidth = 0,
    this.separatorHeight = 0,
  });

  final Stream<List<T>> stream;
  final Widget Function(T item) itemBuilder;
  final String emptyMessage;
  final Axis scrollDirection;
  final double? height; // needed for horizontal
  final double separatorWidth;
  final double separatorHeight;

  @override
  Widget build(BuildContext context) {
    Widget content = StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xff1173D4)));
        }
        if (snap.hasError) {
          return Center(
            child: Text('تعذّر التحميل',
                style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    color: Colors.grey.shade500)),
          );
        }

        final items = snap.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_off_outlined,
                    size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(emptyMessage,
                    style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        color: Colors.grey.shade500,
                        fontSize: 13)),
              ],
            ),
          );
        }

        return ListView.separated(
          scrollDirection: scrollDirection,
          shrinkWrap: scrollDirection == Axis.vertical,
          physics: scrollDirection == Axis.vertical
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          padding: scrollDirection == Axis.horizontal
              ? const EdgeInsets.symmetric(horizontal: 4)
              : EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(
            width: separatorWidth,
            height: separatorHeight,
          ),
          itemBuilder: (_, i) => itemBuilder(items[i]),
        );
      },
    );

    if (scrollDirection == Axis.horizontal && height != null) {
      return SizedBox(height: height, child: content);
    }
    return content;
  }
}

// ── Featured Post Card (other users' posts — horizontal) ──────────────────────

class _FeaturedPostCard extends StatelessWidget {
  const _FeaturedPostCard({required this.post});
  final UserPostModel post;

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return 'منذ ${d.inMinutes} د';
    if (d.inHours < 24) return 'منذ ${d.inHours} س';
    return 'منذ ${d.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: context.responsive(mobile: 260, tablet: 300, desktop: 340),
      child: Card(
        elevation: 2,
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
              color:
                  isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon + متاح badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xff1173D4).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.work_outline,
                        color: Color(0xff1173D4), size: 22),
                  ),
                  if (post.isAvailable == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff22C55E).withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('متاح',
                          style: theme.textTheme.bodySmall!.copyWith(
                              color: const Color(0xff22C55E),
                              fontWeight: FontWeight.w600,
                              fontSize: context.adaptiveFontSize(12))),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Text(post.postTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium!.copyWith(
                      fontSize: context.adaptiveFontSize(15),
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xffF1F5F9)
                          : const Color(0xff1E293B))),

              if (post.description != null) ...[
                const SizedBox(height: 4),
                Text(post.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.copyWith(
                        fontSize: context.adaptiveFontSize(12),
                        color: isDark
                            ? const Color(0xff94A3B8)
                            : const Color(0xff64748B))),
              ],

              const Spacer(),

              // Footer: time + PDF indicator + "تقدّم الآن"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.access_time_outlined,
                        size: 13,
                        color: isDark
                            ? const Color(0xff64748B)
                            : const Color(0xff94A3B8)),
                    const SizedBox(width: 4),
                    Text(_timeAgo(post.createdAt),
                        style: theme.textTheme.bodySmall!
                            .copyWith(fontSize: context.adaptiveFontSize(11))),
                    if (post.sourceId != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.picture_as_pdf,
                          color: Color(0xffEF4444), size: 14),
                    ],
                  ]),
                  PostApplyButton(post: post),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── My Post Card (owner's posts — vertical, shows المتقدّمون) ─────────────────

class _MyPostCard extends StatelessWidget {
  const _MyPostCard({
    required this.post,
    required this.isDark,
    required this.theme,
  });

  final UserPostModel post;
  final bool isDark;
  final ThemeData theme;

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return 'منذ ${d.inMinutes} د';
    if (d.inHours < 24) return 'منذ ${d.inHours} س';
    return 'منذ ${d.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final active = post.isEnable && (post.isAvailable ?? false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xff1173D4).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_outline,
                color: Color(0xff1173D4), size: 24),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + status badge
                Row(
                  children: [
                    Expanded(
                      child: Text(post.postTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall!.copyWith(
                              fontSize: context.adaptiveFontSize(14),
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xffF1F5F9)
                                  : const Color(0xff1E293B))),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xff22C55E).withValues(alpha: .12)
                            : Colors.grey.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        active ? 'مفعّلة' : 'معطّلة',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: active ? const Color(0xff22C55E) : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                if (post.description != null) ...[
                  const SizedBox(height: 4),
                  Text(post.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall!.copyWith(
                          fontSize: context.adaptiveFontSize(12),
                          color: isDark
                              ? const Color(0xff94A3B8)
                              : const Color(0xff64748B))),
                ],

                const SizedBox(height: 10),

                // Footer: time + PDF + المتقدّمون button
                Row(
                  children: [
                    Icon(Icons.access_time_outlined,
                        size: 12,
                        color: isDark
                            ? const Color(0xff64748B)
                            : const Color(0xff94A3B8)),
                    const SizedBox(width: 4),
                    Text(_timeAgo(post.createdAt),
                        style: theme.textTheme.bodySmall!
                            .copyWith(fontSize: context.adaptiveFontSize(11))),
                    if (post.sourceId != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.picture_as_pdf,
                          color: Color(0xffEF4444), size: 13),
                    ],
                    const Spacer(),
                    // PostApplyButton detects owner → shows "المتقدّمون"
                    PostApplyButton(post: post),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.theme,
    required this.onViewAll,
  });
  final String title;
  final ThemeData theme;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: theme.textTheme.displayMedium!
                .copyWith(fontSize: context.adaptiveFontSize(20))),
        GestureDetector(
          onTap: onViewAll,
          child: Text('عرض الكل',
              style: theme.textTheme.displayMedium!.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: context.adaptiveFontSize(16))),
        ),
      ],
    );
  }
}

// ── Category Model & Card ─────────────────────────────────────────────────────

class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  const _CategoryItem(
      {required this.icon, required this.label, required this.color});
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item, required this.onTap});
  final _CategoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xff1E293B) : const Color(0xffF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon,
                color: item.color,
                size: context.responsive(mobile: 28, tablet: 30, desktop: 32)),
          ),
          const SizedBox(height: 8),
          Text(item.label,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: context.adaptiveFontSize(12),
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
