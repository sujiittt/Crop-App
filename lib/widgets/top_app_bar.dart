// lib/presentation/widgets/top_app_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TopAppBar - fade green appbar with subtle field watermark,
/// notification bell with badge, profile icon, and last-updated row.
///
/// This widget is intentionally self-contained and accepts simple inputs:
/// - [unreadNotifications] : number to show in badge (0 hides badge)
/// - [lastUpdatedText] : small status line
/// - [onNotificationTap] and [onProfileTap] callbacks
class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int unreadNotifications;
  final String lastUpdatedText;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const TopAppBar({
    Key? key,
    this.unreadNotifications = 0,
    this.lastUpdatedText = '',
    this.onNotificationTap,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(92);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // gentle fade green background color
    const Color barGreen = Color(0xFF2E7D32);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // background with watermark image and green overlay
          Container(
            height: preferredSize.height,
            decoration: BoxDecoration(
              color: barGreen,
              image: DecorationImage(
                // path: assets/images/field_watermark.png (add to pubspec)
                image: const AssetImage('assets/images/field_watermark.png'),
                fit: BoxFit.cover,
                opacity: 0.06, // very subtle watermark
                alignment: Alignment.centerLeft,
              ),
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF60A260)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
          ),

          // content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: title + icons
                  Row(
                    children: [
                      // menu / leading optional: you can remove if you use a drawer
                      // Text title
                      Text('CropWise',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(width: 8),
                      // small connectivity/status icons (static placeholders)
                      const Icon(Icons.wifi, color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      const Icon(Icons.circle, color: Colors.white70, size: 10),
                      const Spacer(),

                      // notification bell with badge
                      GestureDetector(
                        onTap: onNotificationTap,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              child: Icon(Icons.notifications_none, color: Colors.white, size: 26),
                            ),
                            if (unreadNotifications > 0)
                              Positioned(
                                right: -2,
                                top: -6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
                                  ),
                                  child: Center(
                                    child: Text(
                                      unreadNotifications > 99 ? '99+' : '$unreadNotifications',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // profile icon
                      IconButton(
                        onPressed: onProfileTap,
                        icon: const Icon(Icons.person_outline, color: Colors.white),
                        tooltip: 'Profile',
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // second row: small status line (last updated)
                  Row(
                    children: [
                      Icon(Icons.update, size: 14, color: Colors.white70),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          lastUpdatedText,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.openSans(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
