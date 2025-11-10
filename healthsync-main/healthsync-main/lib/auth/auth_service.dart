import 'dart:async';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  // In-memory stores for demo purposes
  final Map<String, Map<String, dynamic>> _users = {};
  final Map<String, String> _otps = {};
  String? _token;

  Future<void> _simulateNetworkLatency() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    await _simulateNetworkLatency();

    if (_users.containsKey(email)) {
      return {'success': false, 'error': 'duplicate_email'};
    }

    // Very basic password policy for demo
    if (password.length < 8) {
      return {'success': false, 'error': 'weak_password'};
    }

    _users[email] = {
      'name': name,
      'email': email,
      'password': password, // NOTE: In real app hash this!
      'verified': false,
    };

    // Generate OTP and store
    final otp = _generateOtp();
    _otps[email] = otp;

    return {'success': true, 'otp': otp};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await _simulateNetworkLatency();
    final user = _users[email];
    if (user == null) return {'success': false, 'error': 'invalid_credentials'};
    if (user['password'] != password) {
      return {'success': false, 'error': 'invalid_credentials'};
    }

    // Issue a fake JWT token
    _token = 'token_${DateTime.now().millisecondsSinceEpoch}';
    return {'success': true, 'token': _token};
  }

  Future<Map<String, dynamic>> sendOtp(String emailOrPhone) async {
    await _simulateNetworkLatency();

    // For demo: accept if user exists or if looks like email allow sending OTP
    final isEmail = emailOrPhone.contains('@');

    if (isEmail && !_users.containsKey(emailOrPhone)) {
      return {'success': false, 'error': 'not_found'};
    }

    final otp = _generateOtp();
    _otps[emailOrPhone] = otp;

    // In a real app you'd send the OTP via SMS/Email. We return it so the demo can show it.
    return {'success': true, 'otp': otp};
  }

  Future<Map<String, dynamic>> verifyOtp(
      String target, String code, String purpose) async {
    await _simulateNetworkLatency();

    final expected = _otps[target];
    if (expected == null) return {'success': false, 'error': 'no_otp_sent'};
    if (expected != code) return {'success': false, 'error': 'invalid_otp'};

    // OTP valid: if verifying registration mark user verified
    if (_users.containsKey(target)) {
      _users[target]!['verified'] = true;
    }

    // remove used otp
    _otps.remove(target);

    // if purpose is login/registration, issue token
    _token = 'token_${DateTime.now().millisecondsSinceEpoch}';

    return {'success': true, 'token': _token};
  }

  Future<Map<String, dynamic>> resetPassword(
      String email, String newPassword) async {
    await _simulateNetworkLatency();
    final user = _users[email];
    if (user == null) return {'success': false, 'error': 'not_found'};
    if (newPassword.length < 8)
      return {'success': false, 'error': 'weak_password'};

    user['password'] = newPassword;
    return {'success': true};
  }

  Future<Map<String, dynamic>> socialLogin(String provider) async {
    await _simulateNetworkLatency();
    // Demo: always succeed and issue token
    _token = 'social_${provider}_${DateTime.now().millisecondsSinceEpoch}';
    return {'success': true, 'token': _token};
  }

  String _generateOtp() {
    final r = DateTime.now().millisecondsSinceEpoch % 1000000;
    return r.toString().padLeft(4, '0').substring(0, 4);
  }

  String? get token => _token;
}
