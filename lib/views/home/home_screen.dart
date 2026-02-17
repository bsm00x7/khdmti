import 'package:flutter/material.dart';
import 'package:khdmti_project/comme_widget/responsive_avatar.dart';
import 'package:khdmti_project/controller/home_controller.dart';
import 'package:khdmti_project/utils/responsive/responsive_helper.dart';
import 'package:khdmti_project/views/home/screen/notification_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ── Categories Data ────────────────────────────────────────
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

  // ── Nearby Opportunities Data ──────────────────────────────
  static const List<_NearbyItem> _nearbyItems = [
    _NearbyItem(
      title: "سباك محترف مطلوب",
      location: "أريانة، ح النصر",
      timeAgo: "منذ 2س",
      price: "50 د.ت",
      category: "صيانة",
      categoryColor: Color(0xffF97316),
      icon: Icons.plumbing,
    ),
    _NearbyItem(
      title: "تركيب أثاث مكتبي",
      location: "تونس، ح الشرقية",
      timeAgo: "منذ 5س",
      price: "120 د.ت",
      category: "تجارة",
      categoryColor: Color(0xff22C55E),
      icon: Icons.chair_outlined,
    ),
    _NearbyItem(
      title: "دروس تقوية رياضيات",
      location: "المرسى، تونس",
      timeAgo: "منذ يوم",
      price: "40 د.ت/س",
      category: "تعليم",
      categoryColor: Color(0xff3B82F6),
      icon: Icons.calculate_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (context) => HomeController()..init(),
      child: Scaffold(
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────────────────
                  Consumer<HomeController>(
                    builder: (context, controller, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ResponsiveAvatar(
                                imageFile: controller.imageFile,
                                imgPath: controller.imageUrl,
                                showBadge: false,
                                badgeFactor: 0.12,
                                sizeFactor: context.responsive(
                                  mobile: 0.12,
                                  tablet: 0.09,
                                  desktop: 0.07,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "مرحباً بك 👋",
                                    style:
                                        theme.textTheme.titleMedium!.copyWith(
                                      fontSize: context.adaptiveFontSize(14),
                                    ),
                                  ),
                                  Text(
                                    controller.userName,
                                    style:
                                        theme.textTheme.displayMedium!.copyWith(
                                      fontSize: context.adaptiveFontSize(20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Search Bar ─────────────────────────────────────
                  SearchBar(
                    shape: const WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    leading: const Icon(Icons.search),
                    hintText: "ابحث عن خدمة، وظيفة...",
                    keyboardType: TextInputType.name,
                    elevation: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.focused) ? 2 : 0,
                    ),
                    backgroundColor: WidgetStateColor.resolveWith(
                      (states) => states.contains(WidgetState.pressed)
                          ? Colors.green
                          : Colors.grey.shade300,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Categories Section ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "التصنيفات",
                        style: theme.textTheme.displayMedium!.copyWith(
                          fontSize: context.adaptiveFontSize(20),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "عرض الكل",
                          style: theme.textTheme.displayMedium!.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: context.adaptiveFontSize(16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Categories Grid ────────────────────────────────
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.responsive(
                        mobile: 4,
                        tablet: 6,
                        desktop: 8,
                      ),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) =>
                        _CategoryCard(item: _categories[index]),
                  ),

                  const SizedBox(height: 24),

                  // ── Featured Jobs Section ──────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "وظائف مميزة",
                        style: theme.textTheme.displayMedium!.copyWith(
                          fontSize: context.adaptiveFontSize(20),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "عرض الكل",
                          style: theme.textTheme.displayMedium!.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: context.adaptiveFontSize(16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Horizontal Scrolling Job Cards ─────────────────
                  SizedBox(
                    height: context.responsive(
                      mobile: 200,
                      tablet: 220,
                      desktop: 240,
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) => _JobCard(theme: theme),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Nearby Opportunities Section ───────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "فرص قريبة منك",
                        style: theme.textTheme.displayMedium!.copyWith(
                          fontSize: context.adaptiveFontSize(20),
                        ),
                      ),
                      // ── Location chip ──
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "تونس العاصمة",
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: Colors.blue,
                              fontSize: context.adaptiveFontSize(13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Nearby List ────────────────────────────────────
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _nearbyItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _NearbyCard(
                      item: _nearbyItems[index],
                      isSelected: index == 0,
                    ),
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

// ── Category Item Model ──────────────────────────────────────────────────────

class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

// ── Category Card Widget ─────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item});
  final _CategoryItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {},
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
            child: Icon(
              item.icon,
              color: item.color,
              size: context.responsive(mobile: 28, tablet: 30, desktop: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: context.adaptiveFontSize(12),
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Nearby Item Model ────────────────────────────────────────────────────────

class _NearbyItem {
  final String title;
  final String location;
  final String timeAgo;
  final String price;
  final String category;
  final Color categoryColor;
  final IconData icon;

  const _NearbyItem({
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.price,
    required this.category,
    required this.categoryColor,
    required this.icon,
  });
}

// ── Nearby Card Widget ───────────────────────────────────────────────────────

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({required this.item, this.isSelected = false});

  final _NearbyItem item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : const Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(14),
        // ✅ Blue border for selected card
        border: isSelected
            ? Border.all(color: const Color(0xff1173D4), width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time ago
                  Text(
                    item.timeAgo,
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: context.adaptiveFontSize(11),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    item.title,
                    style: theme.textTheme.displayMedium!.copyWith(
                      fontSize: context.adaptiveFontSize(18),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: theme.textTheme.bodySmall!.color,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item.location,
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontSize: context.adaptiveFontSize(12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Category badge + price row
                  Row(
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.categoryColor.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.category,
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: item.categoryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: context.adaptiveFontSize(11),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Price
                      Text(
                        item.price,
                        style: theme.textTheme.displayMedium!.copyWith(
                          color: const Color(0xff1173D4),
                          fontWeight: FontWeight.bold,
                          fontSize: context.adaptiveFontSize(15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Image / Icon Box ──
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xff0F172A) : const Color(0xffF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                size: 38,
                color: item.categoryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Job Card Widget ──────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  const _JobCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.responsive(
        mobile: 260,
        tablet: 300,
        desktop: 340,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.ac_unit_rounded),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        "عاجل",
                        style: theme.textTheme.displayMedium!.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w400,
                          fontSize: context.adaptiveFontSize(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "تصميم شعار لشركة ناشئة",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge!
                    .copyWith(fontSize: context.adaptiveFontSize(18)),
              ),
              const SizedBox(height: 4),
              Text(
                "شركة الإبداع الرقمي · عن بُعد",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "200 د.ت",
                    style: theme.textTheme.displayMedium!.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: context.adaptiveFontSize(16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "تقدّم الآن",
                      style: TextStyle(fontSize: context.adaptiveFontSize(13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
