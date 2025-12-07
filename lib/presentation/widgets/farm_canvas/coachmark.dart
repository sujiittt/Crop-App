import 'package:flutter/material.dart';

class Coachmark {
  static OverlayEntry show({
    required BuildContext context,
    required Rect target,
    String message = 'Tap + to plant',
    VoidCallback? onDismiss,
  }) {
    final theme = Theme.of(context);

    // Declare first, assign later so the builder can reference it.
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            // Dim background that also dismisses on tap
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  entry.remove();
                  onDismiss?.call();
                },
                child: Container(color: Colors.black.withOpacity(0.45)),
              ),
            ),

            // Highlight ring around target
            Positioned(
              left: target.left - 8,
              top: target.top - 8,
              width: target.width + 16,
              height: target.height + 16,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(.9),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bubble message (placed below target; adjust if it would overflow)
            Builder(
              builder: (context) {
                const bubblePadding = 8.0;
                final media = MediaQuery.of(context);
                final bubbleLeft = target.left.clamp(
                  8.0,
                  media.size.width - 8.0,
                );
                final bubbleTop = (target.bottom + bubblePadding)
                    .clamp(8.0, media.size.height - 64.0);

                return Positioned(
                  left: bubbleLeft,
                  top: bubbleTop,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.25),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            message,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(entry);
    return entry;
  }
}
