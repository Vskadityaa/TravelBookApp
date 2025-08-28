// lib/pages/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import 'dashboard_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show splash/loading screen while checking auth state
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is logged in, go to Dashboard
          return const DashboardPage();
        } else {
          // User is NOT logged in, go to Login
          return const LoginPage();
        }
      },
    );
  }
}
