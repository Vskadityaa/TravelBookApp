import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/discover_page.dart';
import 'pages/plan_trip_page.dart';

import 'pages/journal_entry_page.dart';
import 'pages/photo_gallery_page.dart';
import 'pages/budget_tracker_page.dart';
import 'pages/settings_page.dart';
import 'pages/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TravelBook',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashPage(), // 👈 Splash is shown first
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/discover': (context) => const DiscoverPage(),
        '/plan': (context) => const PlanTripPage(),
        '/journal': (context) => JournalEntryPage(),
        '/gallery': (context) => const PhotoGalleryPage(),
        '/budget': (context) => const BudgetTrackerPage(),
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
