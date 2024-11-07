import 'dart:typed_data';

import 'package:enrollease_web/account_screen/menu/settings_menu.dart';
import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:enrollease_web/widgets/account_pop_menu.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

class AdminAccountSetting extends StatefulWidget {
  const AdminAccountSetting({super.key});

  @override
  AdminAccountSettingState createState() => AdminAccountSettingState();
}

class AdminAccountSettingState extends State<AdminAccountSetting> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 80,
      decoration: const BoxDecoration(
        color: CustomColors.contentColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 5),
          Flexible(
            fit: FlexFit.tight,
            child: Consumer<AccountDataController>(
              builder: (context, userData, child) {
                return GestureDetector(
                  onTap: _showSettingsMenu,
                  child: Text(
                    userData.currentUserName ?? 'Welcome, User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          _buildProfileImage(),
          const AccountPopMenu(),
        ],
      ),
    );
  }

  Widget _buildProfileImage({Uint8List? image}) {
    return ClipOval(
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: image != null
                ? MemoryImage(image) // Use Uint8List directly
                : const AssetImage(CustomLogos.editProfileImage)
                    as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _showSettingsMenu() {
    showPopover(
      context: context,
      bodyBuilder: (context) => const SettingsMenu(),
      width: 200,
      height: 101,
    );
  }
}
