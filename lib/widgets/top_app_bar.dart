import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  // ✅ REQUIRED by Dashboard
  final String title;
  final String lastUpdatedText;
  final bool isOnline;
  final int notificationCount;

  // ✅ Actions
  final VoidCallback onAddPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onProfileTap;

  const TopAppBar({
    Key? key,
    required this.title,
    required this.lastUpdatedText,
    required this.isOnline,
    required this.notificationCount,
    required this.onAddPressed,
    required this.onNotificationsPressed,
    required this.onProfileTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(92);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: const Color(0xFF2E7D32),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔝 Top Row
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),

                  // ➕ Add
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    onPressed: onAddPressed,
                  ),

                  // 🔔 Notifications
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.white),
                        onPressed: onNotificationsPressed,
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.red,
                            child: Text(
                              notificationCount.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // 👤 Profile
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: onProfileTap,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ⏱ Status
              Row(
                children: [
                  Icon(
                    isOnline ? Icons.wifi : Icons.wifi_off,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    lastUpdatedText,
                    style: GoogleFonts.openSans(
                      color: Colors.white70,
                      fontSize: 12,
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
