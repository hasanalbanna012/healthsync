import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final resp = await AuthService.instance
        .login(_emailController.text.trim(), _passwordController.text);

    setState(() => _loading = false);

    if (resp['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
      // Close the whole auth flow and return to home (pop root route)
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      final err = resp['error'] ?? 'invalid_credentials';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $err')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Close the auth flow and return to the previous screen (home)
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter email';
                  if (!v.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                obscureText: _obscure,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter password';
                  if (v.length < 6) return 'Password too short';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/forgot'),
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed('/register'),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final r =
                          await AuthService.instance.socialLogin('google');
                      if (r['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google login OK')));
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    },
                    icon: const Icon(Icons.account_circle),
                    label: const Text('Google'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final r =
                          await AuthService.instance.socialLogin('facebook');
                      if (r['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Facebook login OK')));
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    },
                    icon: const Icon(Icons.facebook),
                    label: const Text('Facebook'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
