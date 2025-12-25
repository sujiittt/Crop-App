import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String _verificationId = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // 📌 STEP 1: Send OTP
  Future<void> sendOTP() async {
    final phone = _phoneController.text.trim();

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-login on some devices
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _otpSent = true;
          _verificationId = verificationId;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Sent")),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // 📌 STEP 2: Verify OTP
  Future<void> verifyOTP() async {
    final otp = _otpController.text.trim();

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: otp,
    );

    try {
      await _auth.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Success!")),
      );

      //  FIX: remove all temporary routes
      Navigator.of(context).popUntil((route) => route.isFirst);

      //  Move user to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard-screen');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                if (!_otpSent) {
                  await sendOTP();
                } else {
                  await verifyOTP();
                }
              },
              child: Text(
                _otpSent ? 'Verify OTP' : 'Send OTP',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
