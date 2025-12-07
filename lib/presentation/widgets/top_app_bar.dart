// lib/presentation/widgets/top_app_bar.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/profile_action_icon.dart';

/// Reusable top app bar for the Dashboard
/// - Uses AppTheme colors
/// - Shows connectivity + GPS + "Last updated"
/// - Has a "+" quick actions button (you moved FAB to top)
/// - Bell icon with optional badge
/// - Profile icon (your existing ProfileActionIcon)
class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({
    super.key,
    required this.title,
    required this.lastUpdatedText,
    required this.isOnline,
    required this.onAddPressed,
    required this.onNotificationsPressed,
    this.notificationCount = 0,
  });

  final String title;
  final String lastUpdatedText;
  final bool isOnline;

  /// Callback for the "+" quick actions button.
  final VoidCallback onAddPressed;

  /// Callback for the notifications bell.
  final VoidCallback onNotificationsPressed;

  /// If > 0, shows a small red badge on the bell.
  final int notificationCount;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final appBarTheme = theme.appBarTheme;

    // Background/foreground colors pulled from your theme
    final Color bg = appBarTheme.backgroundColor ?? theme.primaryColor;
    final Color fg = appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;

    return Material(
      color: bg,
      elevation: appBarTheme.elevation ?? 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          // subtle gradient sheen over your green
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                bg.withOpacity(0.98),
                bg.withOpacity(0.94),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.fromLTRB(4.w, 1.0.h, 2.w, 1.0.h),
          child: Row(
            children: [
              // Title + status line
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.terrain_rounded,
                            size: 18, color: fg.withOpacity(0.9)),
                      ],
                    ),
                    SizedBox(height: 0.6.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: isOnline ? 'wifi' : 'wifi_off',
                          color: isOnline ? fg : theme.colorScheme.error,
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        CustomIconWidget(
                          iconName: 'gps_fixed',
                          color: fg,
                          size: 4.w,
                        ),
                        SizedBox(width: 3.w),
                        Flexible(
                          child: Text(
                            'Last updated: $lastUpdatedText',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: fg.withOpacity(0.92),
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // "+" quick actions (you moved FAB actions up here)
              IconButton(
                tooltip: 'Quick actions',
                onPressed: onAddPressed,
                icon: const Icon(Icons.add_circle_outline, size: 24),
                color: fg,
              ),
              SizedBox(width: 1.w),

              // Bell with optional badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: onNotificationsPressed,
                    icon: const Icon(Icons.notifications_none, size: 24),
                    color: fg,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          notificationCount > 99 ? '99+' : '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 1.w),

              // Profile action (you already have this widget wired)
              const ProfileActionIcon(),
            ],
          ),
        ),
      ),
    );
  }
}
