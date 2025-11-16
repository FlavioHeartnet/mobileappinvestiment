import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/src/presentation/screens/confirmation_signup_screen.dart';
import 'package:mobile/src/presentation/screens/forgot_password_confirmation_screen.dart';
import 'package:mobile/src/presentation/screens/forgot_password_screen.dart';
import 'package:mobile/src/presentation/screens/login_screen.dart';
import 'package:mobile/src/presentation/screens/profile_screen.dart';
import 'package:mobile/src/presentation/screens/results_details_screen.dart';
import 'package:mobile/src/presentation/screens/retirement_calculator_screen.dart';
import 'package:mobile/src/presentation/screens/signup_screen.dart';
import 'package:mobile/src/presentation/screens/subscription_plan_screen.dart';
import 'package:mobile/src/providers/auth_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: AppRoot()));
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    if (authState.isAuthenticated) {
      return const RetirementCalculatorScreen();
    } else {
      return const LoginScreen();
    }
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color.fromRGBO(93, 135, 255, 1);
    final lightScheme = ColorScheme.fromSeed(seedColor: seed);
    final darkScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        fontFamily: 'Manrope',
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(lightScheme.primary),
            foregroundColor: WidgetStatePropertyAll(lightScheme.onPrimary),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        fontFamily: 'Manrope',
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(darkScheme.primary),
            foregroundColor: WidgetStatePropertyAll(darkScheme.onPrimary),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('pt', 'BR'),
        Locale('en'),
      ],
      locale: const Locale('pt', 'BR'),
      home: const AuthWrapper(),
      routes: {
        '/calculator': (context) => const RetirementCalculatorScreen(),
        '/results': (context) => const ResultsDetailsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/plans': (context) => const SubscriptionPlanScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/forgot-password-confirmation': (context) => const ForgotPasswordConfirmationScreen(),
        '/signup': (context) => const SignupScreen(),
        '/confirmation-signup': (context) => const ConfirmationSignupScreen(),
      },
    );
  }
}
