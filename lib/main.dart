import 'package:enrollease_web/landing_page/sign_in.dart';
import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SignIn(),
        ),
      );
}
