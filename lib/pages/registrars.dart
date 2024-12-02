import 'package:enrollease_web/paginated_table/table/registrars_table.dart';
import 'package:enrollease_web/utils/bottom_credits.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';
import 'package:enrollease_web/widgets/custom_loading_dialog.dart';
import 'package:enrollease_web/widgets/registrar_dialog.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:enrollease_web/widgets/custom_button.dart';
import 'package:enrollease_web/widgets/custom_header.dart';
import 'package:flutter/material.dart';

class Registrars extends StatefulWidget {
  const Registrars({super.key, this.userId});
  final String? userId;

  @override
  State<Registrars> createState() => _RegistrarsState();
}

class _RegistrarsState extends State<Registrars> {
  FirebaseAuthProvider firebaseAuthProvider = FirebaseAuthProvider();

  @override
  Widget build(BuildContext context) {
    final isSmallOrMediumScreen = ResponsiveWidget.isMediumScreen(context) || ResponsiveWidget.isLargeScreen(context);
    return Scaffold(
      backgroundColor: CustomColors.appBarColor,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomDrawerHeader(
              headerName: 'registrars',
              userId: widget.userId,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: SizedBox(
                  width: 200,
                  child: CustomBtn(
                    vertical: 10,
                    colorBg: CustomColors.color1,
                    colorTxt: Colors.white,
                    txtSize: 18,
                    onTap: () async {
                      showLoadingDialog(context, 'Loading');
                      final idNumber = await firebaseAuthProvider.generateNewIdentification();
                      if (context.mounted) {
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: (context) => RegistrarDialog(
                                  id: idNumber,
                                  editMode: false,
                                ));
                      }
                    },
                    btnTxt: 'Add Registrar',
                    btnIcon: Icons.add,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: RegistrarsTable(),
            ),
          ],
        ),
      )),
      bottomNavigationBar: isSmallOrMediumScreen ? bottomCredits() : const SizedBox.shrink(),
    );
  }
}
