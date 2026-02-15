import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ResponsiveAvatar extends StatelessWidget {
  final IconData icon;
  final String? imgPath;
  final File? imageFile;
  final double sizeFactor;
  final bool showBadge;
  final Color badgeColor;
  final double badgeFactor;

  const ResponsiveAvatar({
    this.imgPath,
    this.imageFile,
    super.key,
    this.icon = Icons.person,
    this.sizeFactor = 0.35,
    this.showBadge = true,
    this.badgeColor = Colors.green,
    this.badgeFactor = 0.18,
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
          child: ClipOval(
            child: _buildImage(avatarSize),
          ),
        ),
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

  /// Priority: local file → cached network image → icon fallback
  Widget _buildImage(double avatarSize) {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
        width: avatarSize,
        height: avatarSize,
      );
    }

    if (imgPath != null && imgPath!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imgPath!,
        fit: BoxFit.cover,
        width: avatarSize,
        height: avatarSize,
        placeholder: (context, url) => Center(
          child: SizedBox(
            width: avatarSize * 0.3,
            height: avatarSize * 0.3,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Icon(
          icon,
          size: avatarSize * 0.45,
        ),
      );
    }

    return Icon(
      icon,
      size: avatarSize * 0.45,
    );
  }
}
