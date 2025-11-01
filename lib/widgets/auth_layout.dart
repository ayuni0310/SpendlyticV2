import 'package:flutter/material.dart';
import 'package:huawei_account/huawei_account.dart';

class AuthLayout extends StatefulWidget {
  const AuthLayout({super.key});

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  String? userName;
  bool isLoggedIn = false;

  // Huawei ID login
  Future<void> _signInWithHuaweiID() async {
    try {
      final helper =
          AccountAuthParamsHelper()
            ..setIdToken()
            ..setAccessToken();

      final authParams = helper.createParams();
      final authService = AccountAuthManager.getService(authParams);

      final result = await authService.signIn();
      setState(() {
        userName = result.displayName;
        isLoggedIn = true;
      });
    } catch (e) {
      debugPrint("Huawei ID login failed: $e");
    }
  }

  // Email/Phone login
  Future<void> _signInWithEmailPhone() async {
    try {
      final authParams =
          AccountAuthParamsHelper()
            ..setEmail()
            ..setMobileNumber()
            ..setIdToken()
            ..setAccessToken();

      final authService = AccountAuthManager.getService(
        authParams.createParams(),
      );

      final result = await authService.signIn();
      setState(() {
        userName = result.email ?? result.displayName;
        isLoggedIn = true;
      });
    } catch (e) {
      debugPrint("Email/Phone login failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _signInWithHuaweiID,
                child: const Text("Login with Huawei ID"),
              ),
              ElevatedButton(
                onPressed: _signInWithEmailPhone,
                child: const Text("Login with Email/Phone"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Welcome $userName")),
      body: const Center(child: Text("Main App Content")),
    );
  }
}
