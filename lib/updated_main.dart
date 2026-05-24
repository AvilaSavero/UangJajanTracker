import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uang_jajan_tracker/screens/login_screen.dart';
import 'package:uang_jajan_tracker/screens/home_screen.dart';
import 'package:uang_jajan_tracker/screens/add_transaction_screen.dart';
import 'package:uang_jajan_tracker/screens/settings_screen.dart';
import 'package:uang_jajan_tracker/screens/statistics_screen.dart';
import 'package:uang_jajan_tracker/screens/profile_screen.dart';
import 'package:uang_jajan_tracker/transaction_service.dart';

void main() {
  runApp(const UangJajanTrackerApp());
}

class UangJajanTrackerApp extends StatelessWidget {
  const UangJajanTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionService()..loadSampleData(),
        ),
      ],
      child: MaterialApp(
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
          AddTransactionScreen.routeName: (context) =>
              const AddTransactionScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
          StatisticsScreen.routeName: (context) => const StatisticsScreen(),
          ProfileScreen.routeName: (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
