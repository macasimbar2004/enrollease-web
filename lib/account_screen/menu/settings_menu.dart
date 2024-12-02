import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final userID = context.read<AccountDataController>().currentRegistrar!.id;

    if (kDebugMode) {
      print('userID: $userID');
    }
    return Center(
      child: Column(
        children: [
          _buildMenuItem(
            text: 'Account Setting',
            onTap: () {
              context.read<SideMenuIndexController>().setSelectedIndex(6);
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            text: 'Logout',
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AccountDataController>().setLoggedIn(false);
                context.read<SideMenuIndexController>().setSelectedIndex(0);
                GoRouter.of(context).go('/');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem({required String text, required VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
