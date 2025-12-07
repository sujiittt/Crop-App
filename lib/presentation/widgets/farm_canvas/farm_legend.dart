import 'package:flutter/material.dart';

class FarmLegend extends StatelessWidget {
  const FarmLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).textTheme.labelSmall;

    Widget dot(Color c, String t) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: c.withOpacity(.3), blurRadius: 4)],
          ),
        ),
        const SizedBox(width: 6),
        Text(t, style: s),
      ],
    );

    Widget badge(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Text('×2', style: s?.copyWith(fontWeight: FontWeight.w700)),
    );

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        dot(Colors.amber.shade700, 'Sown'),
        dot(Colors.lightBlue.shade600, 'Growing'),
        dot(Colors.green.shade600, 'Harvest'),
        Row(mainAxisSize: MainAxisSize.min, children: [
          badge('×2'),
          const SizedBox(width: 6),
          Text('Dense', style: s),
        ]),
      ],
    );
  }
}
