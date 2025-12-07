import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cropwise/routes/app_routes.dart';


class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _langCode = 'en'; // 'en' | 'hi' | 'pa'

  @override
  void dispose() {
    _nameCtrl.dispose();
    _villageCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    // TODO: persist to SharedPreferences / backend + trigger locale change later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved (demo).')),
    );
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.titleLarge;
    final body = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farmer details', style: title),
            SizedBox(height: 1.5.h),
            _LabeledField(label: 'Name', controller: _nameCtrl, keyboardType: TextInputType.name),
            SizedBox(height: 1.2.h),
            _LabeledField(label: 'Village', controller: _villageCtrl, keyboardType: TextInputType.streetAddress),
            SizedBox(height: 1.2.h),
            _LabeledField(label: 'Phone', controller: _phoneCtrl, keyboardType: TextInputType.phone),
            SizedBox(height: 3.h),
            Divider(height: 4.h),
            Text('Language', style: title),
            SizedBox(height: .5.h),
            Text('Choose your preferred language for the app.', style: body),
            SizedBox(height: 1.h),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _langCode,
              onChanged: (v) => setState(() => _langCode = v ?? 'en'),
            ),
            RadioListTile<String>(
              title: const Text('हिन्दी'),
              value: 'hi',
              groupValue: _langCode,
              onChanged: (v) => setState(() => _langCode = v ?? 'hi'),
            ),
            RadioListTile<String>(
              title: const Text('ਪੰਜਾਬੀ'),
              value: 'pa',
              groupValue: _langCode,
              onChanged: (v) => setState(() => _langCode = v ?? 'pa'),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save'),
              ),
            ),
            SizedBox(height: 4.h),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: EdgeInsets.all(3.5.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Later, saving language will switch the app locale (Hindi/Punjabi/English). '
                            'We’ll also add land details for better recommendations.',
                        style: body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.farmerRegistration);
                },
                icon: const Icon(Icons.manage_accounts_outlined),
                label: const Text('Edit farmer details'),
              ),
            ),

            SizedBox(height: 6.h),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _LabeledField({
    Key? key,
    required this.label,
    required this.controller,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        // Using labelText directly to match your app’s style & floating labels
        // You can theme this via app_theme if needed.
      ).copyWith(labelText: label),
    );
  }
}
