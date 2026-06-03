import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

class QyzmetAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? titleColor;
  final VoidCallback? onBackPressed;

  const QyzmetAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
    this.titleColor,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      foregroundColor: titleColor ?? AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      leading: showBackButton
          ? (leading ??
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              ))
          : null,
      actions: actions,
      automaticallyImplyLeading: showBackButton,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
