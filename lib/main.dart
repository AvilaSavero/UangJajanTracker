import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/security_screen.dart';
import 'screens/help_center_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences with error handling
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    print('SharedPreferences init error (non-critical): $e');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    // Suppress non-critical Windows errors
    if (!details.exception.toString().contains('Application not found')) {
      print('FLUTTER ERROR: ${details.exception}');
      print('${details.stack}');
    }
  };

  runApp(const UangJajanTrackerApp());
}

class UangJajanTrackerApp extends StatelessWidget {
  const UangJajanTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Uang Jajan Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
          primaryColor: Colors.green.shade700,
          scaffoldBackgroundColor: Colors.grey.shade50,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0.6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: EdgeInsets.zero,
          ),
          useMaterial3: true,
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
          RegisterScreen.routeName: (context) => const RegisterScreen(),
          HomeScreen.routeName: (context) => const HomeScreen(),
          AddTransactionScreen.routeName: (context) =>
              const AddTransactionScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
          StatisticsScreen.routeName: (context) => const StatisticsScreen(),
          ProfileScreen.routeName: (context) => const ProfileScreen(),
          EditProfileScreen.routeName: (context) => const EditProfileScreen(),
          SecurityScreen.routeName: (context) => const SecurityScreen(),
          HelpCenterScreen.routeName: (context) => const HelpCenterScreen(),
        },
      ),
    );
  }
}
