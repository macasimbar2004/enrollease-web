import 'package:enrollease_web/account_screen/menu/settings_menu.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class AccountPopMenu extends StatefulWidget {
  const AccountPopMenu({super.key});

  @override
  State<AccountPopMenu> createState() => _AccountPopMenuState();
}

class _AccountPopMenuState extends State<AccountPopMenu> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: () => showPopover(
                context: context,
                bodyBuilder: (context) => const SettingsMenu(),
                width: 200,
                height: 101,
                barrierColor: Colors.transparent,
              ),
          child: const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          )),
    );
  }
}
