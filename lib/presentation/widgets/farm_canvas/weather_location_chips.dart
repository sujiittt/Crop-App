import 'package:flutter/material.dart';

class WeatherLocationChips extends StatelessWidget {
  const WeatherLocationChips({
    super.key,
    this.location = 'Your farm',
    this.temperature, // like "25°C"
    this.condition,   // like "Cloudy"
    this.onTapWeather,
    this.onTapLocation,
  });

  final String location;
  final String? temperature;
  final String? condition;
  final VoidCallback? onTapWeather;
  final VoidCallback? onTapLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Row(
      children: [
        // Weather chip
        Expanded(
          child: _ChipCard(
            onTap: onTapWeather,
            background: primary.withOpacity(.10),
            border: primary.withOpacity(.18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wb_cloudy_outlined, size: 18),
                const SizedBox(width: 6),
                Text(
                  temperature ?? '--°C',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
                if (condition != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    condition!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: onSurface.withOpacity(.75),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Location chip
        Expanded(
          child: _ChipCard(
            onTap: onTapLocation,
            background: Colors.brown.withOpacity(.08), // subtle “field soil” hint
            border: Colors.brown.withOpacity(.18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    location,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChipCard extends StatelessWidget {
  const _ChipCard({
    required this.child,
    this.onTap,
    required this.background,
    required this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
