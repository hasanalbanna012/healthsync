import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'otp_verification_page.dart';
import 'reset_password_page.dart';
import 'profile_setup_page.dart';

class AuthFlow extends StatelessWidget {
  const AuthFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/login':
            page = const LoginPage();
            break;
          case '/register':
            page = const RegisterPage();
            break;
          case '/forgot':
            page = const ForgotPasswordPage();
            break;
          case '/otp':
            final args = settings.arguments as Map<String, dynamic>?;
            page = OTPVerificationPage(
              target: args?['target'] ?? '',
              purpose: args?['purpose'] ?? 'signup',
            );
            break;
          case '/reset':
            final args = settings.arguments as Map<String, dynamic>?;
            page = ResetPasswordPage(target: args?['target'] ?? '');
            break;
          case '/profile':
            page = const ProfileSetupPage();
            break;
          default:
            page = const LoginPage();
        }

        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}
