import 'package:flutter/cupertino.dart';
import '../theme/apple_colors.dart';
import 'apple_burger_icon.dart';

class TactileTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onOpenDrawer;
  final Widget? leading;
  final Widget? rightAction;
  final bool isDark;

  const TactileTopBar({
    super.key,
    required this.title,
    this.onOpenDrawer,
    this.leading,
    this.rightAction,
    required this.isDark,
  });

  /// Factory helper for creating standard 40x40 circular top-bar back buttons
  static Widget backButton({
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppleColors.card(isDark),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppleColors.cardBorder(isDark),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x22000000) : const Color(0x06000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.chevron_back,
            size: 20,
            color: AppleColors.systemBlue,
          ),
        ),
      ),
    );
  }

  /// Factory helper for creating standard 40x40 circular top-bar action buttons
  static Widget actionButton({
    required Widget icon,
    required VoidCallback onPressed,
    required bool isDark,
    Color? bgColor,
    Color? borderColor,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor ?? AppleColors.card(isDark),
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? AppleColors.cardBorder(isDark),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x22000000) : const Color(0x06000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Custom Leading or Burger Drawer Button
          leading ??
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: onOpenDrawer,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppleColors.card(isDark),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppleColors.cardBorder(isDark),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0x22000000) : const Color(0x06000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AppleBurgerIcon(
                      color: AppleColors.textPrimary(isDark),
                      size: 18,
                    ),
                  ),
                ),
              ),

          // Center: Screen Title
          Expanded(
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppleColors.textPrimary(isDark),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),

          // Right: Action Button or Spacer for symmetry
          rightAction != null
              ? rightAction!
              : const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}
