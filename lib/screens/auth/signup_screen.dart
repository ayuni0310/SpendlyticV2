import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final auth = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> signUpWithHuaweiID() async {
    setState(() => isLoading = true);
    try {
      final result = await auth.signInWithHuaweiID();
      if (result == null) throw Exception("Huawei ID sign-up failed");

      await DBService().saveUserData(
        email: result.email ?? '',
        name:
            nameController.text.trim().isEmpty
                ? (result.displayName ?? '')
                : nameController.text.trim(),
        provider: 'huawei_id',
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sign-up failed: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signUpWithEmailPhone() async {
    setState(() => isLoading = true);
    try {
      final result = await auth.signInWithEmailPhone();
      if (result == null) throw Exception("Email/Phone sign-up failed");

      await DBService().saveUserData(
        email: result.email ?? '',
        name: nameController.text.trim(),
        provider: 'huawei_email_phone',
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sign-up failed: $e")));
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
                  "Let’s get started!",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 32),

                /// Full Name
                TextFormField(
                  controller: nameController,
                  validator:
                      (val) => val!.trim().isEmpty ? 'Enter your name' : null,
                  decoration: _inputDecoration(
                    context,
                    hint: 'Full Name',
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(height: 16),

                /// Email (optional prefill for email/phone login)
                TextFormField(
                  controller: emailController,
                  validator:
                      (val) =>
                          val!.contains('@') ? null : 'Enter a valid email',
                  decoration: _inputDecoration(
                    context,
                    hint: 'Email',
                    icon: Icons.email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 24),

                // Huawei ID button
                ElevatedButton(
                  onPressed: isLoading ? null : signUpWithHuaweiID,
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
                            'SIGN UP WITH HUAWEI ID',
                            style: TextStyle(color: Colors.white),
                          ),
                ),

                const SizedBox(height: 16),

                // Email/Phone button
                ElevatedButton(
                  onPressed: isLoading ? null : signUpWithEmailPhone,
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
                            'SIGN UP WITH EMAIL/PHONE',
                            style: TextStyle(color: Colors.white),
                          ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Already have an account? Log In",
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

  /// Helper for consistent input styling
  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
