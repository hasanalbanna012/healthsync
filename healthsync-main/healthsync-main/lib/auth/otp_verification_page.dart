import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_service.dart';

class OTPVerificationPage extends StatefulWidget {
  final String target;
  final String purpose; // 'signup' or 'reset'

  const OTPVerificationPage(
      {super.key, required this.target, required this.purpose});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _codeController = TextEditingController();
  bool _loading = false;
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    final resp = await AuthService.instance.sendOtp(widget.target);
    if (resp['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resent OTP: ${resp['otp']}')),
      );
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resend failed: ${resp['error']}')),
      );
    }
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() => _loading = true);
    final resp = await AuthService.instance
        .verifyOtp(widget.target, code, widget.purpose);
    setState(() => _loading = false);

    if (resp['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verified')),
      );
      if (widget.purpose == 'signup') {
        Navigator.of(context).pushNamed('/profile');
      } else if (widget.purpose == 'reset') {
        Navigator.of(context)
            .pushNamed('/reset', arguments: {'target': widget.target});
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP error: ${resp['error']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter the 4-digit code sent to ${widget.target}'),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'OTP code'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _verify,
              child: _loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Verify'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_secondsLeft > 0
                    ? 'Resend in $_secondsLeft s'
                    : 'Didn\'t receive?'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _secondsLeft > 0 ? null : _resend,
                  child: const Text('Resend'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
