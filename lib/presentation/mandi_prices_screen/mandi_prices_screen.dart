import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cropwise/widgets/profile_action_icon.dart';

class MandiPricesScreen extends StatefulWidget {
  static const String routeName = '/mandi-prices';

  const MandiPricesScreen({Key? key}) : super(key: key);

  @override
  State<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends State<MandiPricesScreen> {
  final List<_MandiRow> _rows = const [
    _MandiRow(commodity: 'Wheat', mandi: 'Ludhiana (PB)', min: 2100, max: 2250, unit: '₹/quintal'),
    _MandiRow(commodity: 'Paddy', mandi: 'Karnal (HR)', min: 2150, max: 2350, unit: '₹/quintal'),
    _MandiRow(commodity: 'Cotton', mandi: 'Rajkot (GJ)', min: 6200, max: 6650, unit: '₹/quintal'),
    _MandiRow(commodity: 'Potato', mandi: 'Agra (UP)', min: 900, max: 1200, unit: '₹/quintal'),
  ];

  bool _loading = false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _loading = false);
  }

  void _connectWithDealer(_MandiRow row) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connect with dealer', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 1.h),
            Text('${row.commodity} • ${row.mandi}', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 4.w,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dialling dealer (demo)...')),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening WhatsApp (demo)...')),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                  label: const Text('WhatsApp'),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Tip: Verified local dealers will show here once location & preferences are enabled.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandi Prices'),
        actions: const [
          ProfileActionIcon(), // ✅ add this here — top-right profile button
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: EdgeInsets.all(3.5.w),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Swipe down to refresh. Location-based prices will appear when enabled.',
                        style: body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 1.5.h),
            if (_loading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ..._rows.map((row) => _MandiCard(row: row, onConnect: () => _connectWithDealer(row))),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _MandiCard extends StatelessWidget {
  final _MandiRow row;
  final VoidCallback onConnect;

  const _MandiCard({Key? key, required this.row, required this.onConnect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.titleLarge;
    final body = Theme.of(context).textTheme.bodyMedium;

    return Card(
      margin: EdgeInsets.only(bottom: 1.2.h),
      child: Padding(
        padding: EdgeInsets.all(3.5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(row.commodity, style: headline),
            SizedBox(height: .8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(row.mandi, style: body),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .8.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text('₹/quintal', style: Theme.of(context).textTheme.labelMedium),
                )
              ],
            ),
            SizedBox(height: .6.h),
            Row(
              children: [
                Text('Min: ₹${row.min.toStringAsFixed(0)}', style: body),
                SizedBox(width: 4.w),
                Text('Max: ₹${row.max.toStringAsFixed(0)}', style: body),
              ],
            ),
            SizedBox(height: 1.2.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onConnect,
                icon: const Icon(Icons.store_mall_directory_outlined),
                label: const Text('Connect with dealer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MandiRow {
  final String commodity;
  final String mandi;
  final double min;
  final double max;
  final String unit;

  const _MandiRow({
    required this.commodity,
    required this.mandi,
    required this.min,
    required this.max,
    required this.unit,
  });
}
