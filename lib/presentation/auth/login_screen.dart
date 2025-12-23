import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // 📱 Phone Number
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                hintText: '+91XXXXXXXXXX',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // 🔐 OTP (only after sent)
            if (_otpSent)
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                if (!_otpSent) {
                  // Step 5.4 mein yahan Firebase call aayega
                  setState(() {
                    _otpSent = true;
                  });
                } else {
                  // Step 5.5 mein OTP verify logic aayega
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP submitted (demo)')),
                  );
                }
              },
              child: Text(_otpSent ? 'Verify OTP' : 'Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
