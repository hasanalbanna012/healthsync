import 'package:flutter/material.dart';
import 'auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final target = _controller.text.trim();
    if (target.isEmpty) return;
    setState(() => _loading = true);
    final resp = await AuthService.instance.sendOtp(target);
    setState(() => _loading = false);

    if (resp['success'] == true) {
      final otp = resp['otp'] ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent — $otp')),
      );
      Navigator.of(context).pushNamed('/otp', arguments: {
        'target': target,
        'purpose': 'reset',
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: ${resp['error']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Email or phone',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _send,
              child: _loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send reset OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
