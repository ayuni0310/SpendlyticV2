import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../widgets/auth_layout.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final auth = AuthService();

  final emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  /// Huawei ID login flow
  Future<void> loginWithHuaweiID() async {
    setState(() => isLoading = true);
    try {
      final result = await auth.signInWithHuaweiID();
      if (result == null) throw Exception("Huawei ID login failed");

      await DBService().saveUserData(
        email: result.email ?? '',
        name: result.displayName ?? '',
        provider: 'huawei_id',
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthLayout()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Huawei ID login failed: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Huawei Email/Phone login flow
  Future<void> loginWithEmailPhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final result = await auth.signInWithEmailPhone();
      if (result == null) throw Exception("Email/Phone login failed");

      await DBService().saveUserData(
        email: result.email ?? emailController.text.trim(),
        name: result.displayName ?? '',
        provider: 'huawei_email_phone',
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthLayout()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Email/Phone login failed: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/spendlytic_logo.png',
                  height: 120,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  "Welcome back!",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 32),

                /// Email field (for email/phone login)
                TextFormField(
                  controller: emailController,
                  validator:
                      (val) => val!.contains('@') ? null : 'Enter valid email',
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    context,
                    hint: 'Email',
                    icon: Icons.email,
                  ),
                ),
                const SizedBox(height: 24),

                /// Huawei ID login button
                ElevatedButton(
                  onPressed: isLoading ? null : loginWithHuaweiID,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'LOGIN WITH HUAWEI ID',
                            style: TextStyle(color: Colors.white),
                          ),
                ),

                const SizedBox(height: 16),

                /// Huawei Email/Phone login button
                ElevatedButton(
                  onPressed: isLoading ? null : loginWithEmailPhone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'LOGIN WITH EMAIL/PHONE',
                            style: TextStyle(color: Colors.white),
                          ),
                ),

                const SizedBox(height: 16),

                /// Sign up link
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: Text(
                    "Don’t have an account? Sign Up",
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: colorScheme.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
    );
  }
}
