import 'package:flutter/material.dart';

class ResponsiveAvatar extends StatelessWidget {
  final IconData icon;
  final double sizeFactor; // % de la largeur écran
  final bool showBadge;
  final Color badgeColor;
  final double badgeFactor; // taille du badge relative à l’avatar

  const ResponsiveAvatar({
    super.key,
    this.icon = Icons.person,
    this.sizeFactor = 0.35, // 35% de l’écran
    this.showBadge = true,
    this.badgeColor = Colors.green,
    this.badgeFactor = 0.18, // 18% de l’avatar
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final avatarSize = screenWidth * sizeFactor;
    final badgeSize = avatarSize * badgeFactor;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: avatarSize,
          width: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: avatarSize * 0.04),
          ),
          child: Icon(
            icon,
            size: avatarSize * 0.45,
          ),
        ),

        // 🔴 Badge dynamique
        if (showBadge)
          Positioned(
            bottom: avatarSize * 0.05,
            right: avatarSize * 0.05,
            child: Container(
              height: badgeSize,
              width: badgeSize,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: badgeSize * 0.15,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
