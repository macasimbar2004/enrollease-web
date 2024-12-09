import 'dart:typed_data';

import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/utils/logos.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePic extends StatefulWidget {
  final double size;
  const ProfilePic({this.size = 80, super.key});

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  final auth = FirebaseAuthProvider();
  late Future<Uint8List?> account;

  @override
  void initState() {
    super.initState();
    account = auth.getProfilePic(context);
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Container(
          color: Colors.blueGrey.shade200,
          padding: const EdgeInsets.all(5),
          child: Consumer<AccountDataController>(builder: (context, acc, child) {
            if (acc.profilePicChanged) {
              Future.microtask(() {
                if (context.mounted) {
                  setState(() {
                    account = auth.getProfilePic(context);
                  });
                }
                if (!context.mounted) return;
                context.read<AccountDataController>().toggleProfilePicChanged();
              });
            }
            return FutureBuilder(
              future: account,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const SizedBox.shrink();
                }
                final bytes = snapshot.data;
                // dPrint(snapshot.data);
                return Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image(
                      fit: BoxFit.cover,
                      image: bytes != null ? MemoryImage(bytes) : const AssetImage(CustomLogos.editProfileImage) as ImageProvider,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
