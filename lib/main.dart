import 'package:appwrite/appwrite.dart';
import 'package:enrollease_web/firebase_options.dart';
import 'package:enrollease_web/landing_page/sign_in.dart';
import 'package:enrollease_web/pages/main_screen.dart';
import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/states_management/statistics_model_data_controller.dart';
import 'package:enrollease_web/states_management/user_context_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Client client = Client();
  client
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('674982d000220a32a166');
  runApp(const EnrollEaseApp());
}

class EnrollEaseApp extends StatelessWidget {
  const EnrollEaseApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AccountDataController(),
          ),
          ChangeNotifierProvider(
            create: (context) => SideMenuDrawerController(),
          ),
          ChangeNotifierProvider(
            create: (context) => SideMenuIndexController(),
          ),
          ChangeNotifierProvider(
            create: (context) => StatisticsModelDataController(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserContextProvider(),
          ),
        ],
        child: MaterialApp.router(
          title: 'EnrollEase',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
        ),
      );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => const Scaffold(
    body: Center(
      child: Text('Page not found'),
    ),
  ),
  redirect: (context, state) {
    final currentPath = state.uri.path;
    final accountDataController = context.read<AccountDataController>();
    final isLoggedIn = accountDataController.isLoggedIn;

    // If accessing any examples pages, allow without login
    if (currentPath.startsWith('/examples')) {
      return null;
    }

    // If the user is not logged in and trying to access a protected route
    if (!isLoggedIn && currentPath != '/') {
      // Save the intended destination to redirect back after login
      if (currentPath != '/' && validPath(currentPath)) {
        // Only save valid paths
        accountDataController.setCurrentRoute(currentPath);
      }
      return '/'; // Redirect to login page
    }

    // If the user is logged in
    if (isLoggedIn) {
      // If they're on the login page, redirect to main app
      if (currentPath == '/') {
        final savedRoute = accountDataController.currentRoute;
        if (savedRoute != null && validPath(savedRoute) && savedRoute != '/') {
          return savedRoute; // Redirect to the saved route if it's valid
        }
        return '/admin'; // Default route for logged in users
      }

      // Otherwise let them continue to their requested page
      return null;
    }

    // Allow access to login page
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SignIn(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const MainScreen(),
    ),
  ],
);

bool validPath(String path) {
  final validPaths = [
    '/',
    '/admin',
  ];
  return validPaths.contains(path);
}
