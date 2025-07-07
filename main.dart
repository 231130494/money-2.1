import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:money/auth/auth_provider.dart';
import 'package:money/controller/category_provider.dart';
import 'package:money/controller/transaction_provider.dart';
import 'package:money/view/login_screen.dart';
import 'package:money/view/home_screen.dart'; 

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>(
          create: (_) => AppAuthProvider(),
        ),
        ChangeNotifierProxyProvider<AppAuthProvider, TransactionProvider>(
          create: (context) => TransactionProvider(
            Provider.of<AppAuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, previousTransactionProvider) {
            return previousTransactionProvider ??
                TransactionProvider(authProvider);
          },
        ),
        ChangeNotifierProxyProvider<AppAuthProvider, CategoryProvider>(
          create: (context) => CategoryProvider(
            Provider.of<AppAuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, previousCategoryProvider) {
            return previousCategoryProvider ??
                CategoryProvider(authProvider);
          },
        ),
      ],
      child: MaterialApp(
        title: 'CJLS Wallet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AppAuthProvider>(
          builder: (context, authProvider, _) {
            return StreamBuilder<User?>(
              stream: authProvider.authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return const HomeScreen();
                }
                return const LoginScreen();
              },
            );
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const HomeScreen(),
        },
      ),
    );
  }
}