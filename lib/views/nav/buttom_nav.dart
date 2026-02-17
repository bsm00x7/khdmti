import 'package:flutter/material.dart';
import 'package:khdmti_project/views/home/home_screen.dart';
import 'package:khdmti_project/views/message/chat_list_screen.dart';
import 'package:khdmti_project/views/profile/profile_screen.dart';
import 'package:khdmti_project/views/search/search_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  // ── 4 real screens (center FAB has no screen) ─────────────
  final List<Widget> _screens = const [
    HomeScreen(), // 0 → الرئيسية
    SearchScreen(), // 1 → طلباتي
    ChatsListScreen(), // 2 → رسائل
    ProfileScreen(), // 3 → المحفظة (placeholder)
  ];

  void _onFabTap() {
    // TODO: open add service / post sheet
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
                  Expanded(
                    child: _AddOption(
                      icon: Icons.work_outline,
                      label: "نشر خدمة",
                      color: const Color(0xff1173D4),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _AddOption(
                      icon: Icons.search,
                      label: "طلب خدمة",
                      color: const Color(0xff22C55E),
                      onTap: () => Navigator.pop(context),
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

    return Scaffold(
      body: _screens[_currentIndex],

      // ── Floating Action Button (center +) ──────────────────
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: _onFabTap,
          backgroundColor: const Color(0xff1173D4),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom Nav ─────────────────────────────────────────
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: BottomAppBar(
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
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: "الرئيسية",
                  index: 0,
                  currentIndex: _currentIndex,
                  isDark: isDark,
                  onTap: () => setState(() => _currentIndex = 0),
                ),

                // طلباتي
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: "طلباتي",
                  index: 1,
                  currentIndex: _currentIndex,
                  isDark: isDark,
                  onTap: () => setState(() => _currentIndex = 1),
                ),

                // ── Empty space for FAB ──
                const SizedBox(width: 60),

                // رسائل
                _NavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: "رسائل",
                  index: 2,
                  currentIndex: _currentIndex,
                  isDark: isDark,
                  onTap: () => setState(() => _currentIndex = 2),
                ),

                // المحفظة
                _NavItem(
                  icon: Icons.person,
                  activeIcon: Icons.account_balance_wallet,
                  label: "حسابي",
                  index: 3,
                  currentIndex: _currentIndex,
                  isDark: isDark,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
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
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
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

// ── Add Option (FAB sheet) ────────────────────────────────────────────────────

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
          border: Border.all(
            color: color.withValues(alpha: .3),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
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
