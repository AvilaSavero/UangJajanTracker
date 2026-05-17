import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const UangJajanTrackerApp());
}

class UangJajanTrackerApp extends StatelessWidget {
  const UangJajanTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uang Jajan Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        AddTransactionScreen.routeName: (context) => const AddTransactionScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        StatisticsScreen.routeName: (context) => const StatisticsScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
      },
    );
  }
}
