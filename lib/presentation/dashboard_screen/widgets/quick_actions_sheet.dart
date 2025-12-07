// lib/presentation/dashboard_screen/widgets/quick_actions_sheet.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionsSheet extends StatelessWidget {
  final void Function(String action)? onAction;

  const QuickActionsSheet({Key? key, this.onAction}) : super(key: key);

  Widget _tile(BuildContext ctx, IconData icon, String title, String subtitle, String actionKey) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.getAccentColor(false).withOpacity(0.12),
        child: Icon(icon, color: AppTheme.getAccentColor(false)),
      ),
      title: Text(title, style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.openSans(fontSize: 12)),
      onTap: () {
        Navigator.of(ctx).pop();
        if (onAction != null) onAction!(actionKey);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // sheet that matches app look; simple and accessible
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // small grabber
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            _tile(context, Icons.add_shopping_cart_outlined, 'New Task', 'Add a task for the farm', 'new_task'),
            _tile(context, Icons.bookmark_add_outlined, 'Add Reminder', 'Set a planting/harvest reminder', 'add_reminder'),
            _tile(context, Icons.photo_camera_outlined, 'Soil Photo', 'Capture soil for analysis', 'soil_photo'),
            _tile(context, Icons.info_outline, 'Crop Tips', 'Get quick tips for selected crop', 'crop_tips'),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
