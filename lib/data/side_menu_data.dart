import 'package:enrollease_web/model/menu_model.dart';
import 'package:flutter/material.dart';

class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.space_dashboard, title: 'Dashboard'),
    MenuModel(icon: Icons.account_balance, title: 'Registrars'),
    MenuModel(icon: Icons.school, title: 'Enrollments'),
    MenuModel(icon: Icons.account_balance_wallet, title: 'Statement of Account'),
    MenuModel(icon: Icons.calendar_month, title: 'Academic Calendar'),
  ];
}
