import 'package:flutter/material.dart';
import 'package:khdmti_project/utils/responsive/responsive_helper.dart';
import 'package:khdmti_project/views/home/home_screen.dart';
import 'package:khdmti_project/views/message/chat_list_screen.dart';
import 'package:khdmti_project/views/services/post_service_screen.dart';
import 'package:khdmti_project/views/profile/profile_screen.dart';
import 'package:khdmti_project/views/requestScreen/requset_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RequestScreen(),
    ChatsListScreen(),
    ProfileScreen(),
  ];

  // ── Nav destinations data ──────────────────────────────────
  static const List<_NavDestination> _destinations = [
    _NavDestination(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: "الرئيسية",
    ),
    _NavDestination(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: "طلباتي",
    ),
    _NavDestination(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: "رسائل",
    ),
    _NavDestination(
      icon: Icons.person,
      activeIcon: Icons.person_2,
      label: "حسابي",
    ),
  ];

  void _onFabTap() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ──
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Text(
                "ماذا تريد أن تضيف؟",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  // ── نشر خدمة ──
                  Expanded(
                    child: _AddOption(
                      icon: Icons.work_outline,
                      label: "نشر خدمة",
                      color: const Color(0xff1173D4),
                      onTap: () {
                        Navigator.pop(context); // close sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PostServiceScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ── طلب خدمة ──
                  Expanded(
                    child: _AddOption(
                      icon: Icons.search,
                      label: "طلب خدمة",
                      color: const Color(0xff22C55E),
                      onTap: () => Navigator.pop(context), // wire later
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = ResponsiveHelper.isLargeScreen(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: isWeb
            ? _WebLayout(
                currentIndex: _currentIndex,
                destinations: _destinations,
                isDark: isDark,
                screen: _screens[_currentIndex],
                onTap: (i) => setState(() => _currentIndex = i),
                onFabTap: _onFabTap,
              )
            : _MobileLayout(
                currentIndex: _currentIndex,
                destinations: _destinations,
                isDark: isDark,
                screen: _screens[_currentIndex],
                onTap: (i) => setState(() => _currentIndex = i),
                onFabTap: _onFabTap,
              ),
      ),
    );
  }
}

// ── Web Layout (vertical nav rail on right) ───────────────────────────────────

class _WebLayout extends StatelessWidget {
  const _WebLayout({
    required this.currentIndex,
    required this.destinations,
    required this.isDark,
    required this.screen,
    required this.onTap,
    required this.onFabTap,
  });

  final int currentIndex;
  final List<_NavDestination> destinations;
  final bool isDark;
  final Widget screen;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Main Content (left side) ──
        Expanded(child: screen),

        // ── Vertical Divider ──
        Container(
          width: 1,
          color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
        ),

        // ── Right Vertical Nav ──
        Container(
          width: 100,
          color: isDark ? const Color(0xff1E293B) : const Color(0xffFFFFFF),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ── Logo / App Icon ──
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xff1173D4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.work_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(height: 32),

                // ── FAB (Add button) ──
                GestureDetector(
                  onTap: onFabTap,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xff1173D4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "أضف",
                  style: TextStyle(
                    fontFamily: "IBMPlexSansArabic",
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xff64748B)
                        : const Color(0xff9CA3AF),
                  ),
                ),

                const SizedBox(height: 24),

                Divider(
                  color: isDark
                      ? const Color(0xff334155)
                      : const Color(0xffE2E8F0),
                  indent: 16,
                  endIndent: 16,
                ),

                const SizedBox(height: 8),

                // ── Nav Items ──
                Expanded(
                  child: ListView.separated(
                    itemCount: destinations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final dest = destinations[index];
                      final isSelected = index == currentIndex;
                      const activeColor = Color(0xff1173D4);
                      final inactiveColor = isDark
                          ? const Color(0xff64748B)
                          : const Color(0xff9CA3AF);

                      return GestureDetector(
                        onTap: () => onTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xff1173D4).withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isSelected ? dest.activeIcon : dest.icon,
                                color: isSelected ? activeColor : inactiveColor,
                                size: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                dest.label,
                                style: TextStyle(
                                  fontFamily: "IBMPlexSansArabic",
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color:
                                      isSelected ? activeColor : inactiveColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mobile Layout (bottom nav with FAB) ──────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.currentIndex,
    required this.destinations,
    required this.isDark,
    required this.screen,
    required this.onTap,
    required this.onFabTap,
  });

  final int currentIndex;
  final List<_NavDestination> destinations;
  final bool isDark;
  final Widget screen;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen,

      // ── FAB ──
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: onFabTap,
          backgroundColor: const Color(0xff1173D4),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom App Bar ──
      bottomNavigationBar: BottomAppBar(
        color: isDark ? const Color(0xff1E293B) : const Color(0xffFFFFFF),
        elevation: 8,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // الرئيسية
              _NavItem(
                dest: destinations[0],
                index: 0,
                currentIndex: currentIndex,
                isDark: isDark,
                onTap: () => onTap(0),
              ),

              // طلباتي
              _NavItem(
                dest: destinations[1],
                index: 1,
                currentIndex: currentIndex,
                isDark: isDark,
                onTap: () => onTap(1),
              ),

              // Empty space for FAB
              const SizedBox(width: 60),

              // رسائل
              _NavItem(
                dest: destinations[2],
                index: 2,
                currentIndex: currentIndex,
                isDark: isDark,
                onTap: () => onTap(2),
              ),

              // حسابي
              _NavItem(
                dest: destinations[3],
                index: 3,
                currentIndex: currentIndex,
                isDark: isDark,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav Destination Model ─────────────────────────────────────────────────────

class _NavDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ── Nav Item (mobile) ─────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.dest,
    required this.index,
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  final _NavDestination dest;
  final int index;
  final int currentIndex;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    const activeColor = Color(0xff1173D4);
    final inactiveColor =
        isDark ? const Color(0xff64748B) : const Color(0xff9CA3AF);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? dest.activeIcon : dest.icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              dest.label,
              style: TextStyle(
                fontFamily: "IBMPlexSansArabic",
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Option Sheet ──────────────────────────────────────────────────────────

class _AddOption extends StatelessWidget {
  const _AddOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1E293B) : const Color(0xffF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: "IBMPlexSansArabic",
                color:
                    isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
