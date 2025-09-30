import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/states_management/side_menu_index_controller.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
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
            text: 'Profile',
            onTap: () {
              context.read<SideMenuIndexController>().setSelectedIndex(10);
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
        return const LogoutDialog();
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

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: loading ? const Text('Logging out ...') : const Text('Logout'),
      content: loading
          ? const SizedBox(
              width: 50,
              height: 50,
              child: Center(child: CircularProgressIndicator()))
          : const Text('Are you sure you want to logout?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            setState(() {
              loading = !loading;
            });
            final registrar =
                Provider.of<AccountDataController>(context, listen: false)
                    .currentRegistrar!;
            await FirebaseAuthProvider().addNotification(
              content:
                  'Registrar ${registrar.firstName} ${registrar.lastName} has logged out.\nRegistration Number: ${registrar.id}',
              type: 'registrar',
              uid: '',
              targetType: 'registrar',
            );
            if (!context.mounted) return;

            // Clear session cache and logout
            await FirebaseAuthProvider().signOut();
            context.read<AccountDataController>().setLoggedIn(false);
            context.read<SideMenuIndexController>().setSelectedIndex(0);
            GoRouter.of(context).go('/');
            Navigator.of(context).pop();
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
