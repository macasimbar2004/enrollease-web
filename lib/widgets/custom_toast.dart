import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:enrollease_web/utils/app_size.dart';
import 'package:enrollease_web/utils/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:delightful_toast/delight_toast.dart';

class DelightfulToast {
  static void removeToast() {
    DelightToastBar.removeAll();
  }

  // Success notification
  static void showSuccess(BuildContext context, String? title, String subTitle,
      {dynamic Function()? onTap}) {
    removeToast();

    AppSizes().init(context);

    final sizeWid = ResponsiveWidget.isLargeScreen(context) ||
            ResponsiveWidget.isMediumScreen(context)
        ? AppSizes.screenWidth * 0.4
        : AppSizes.screenWidth;

    DelightToastBar(
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: SizedBox(
              width: sizeWid,
              child: ToastCard(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Enable horizontal scroll
                  child: Text(
                    title ?? 'Success',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ),
                subtitle: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Enable horizontal scroll
                  child: Text(
                    subTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ),
                onTap: onTap ?? removeToast,
                trailing: const IconButton(
                  onPressed: DelightToastBar.removeAll,
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      autoDismiss: true,
      snackbarDuration: const Duration(milliseconds: 3000),
      position: DelightSnackbarPosition.top,
    ).show(context);
  }

  // Info notification
  static void showInfo(BuildContext context, String? title, String subTitle,
      {dynamic Function()? onTap}) {
    removeToast();
    AppSizes().init(context);

    final sizeWid = ResponsiveWidget.isLargeScreen(context) ||
            ResponsiveWidget.isMediumScreen(context)
        ? AppSizes.screenWidth * 0.4
        : AppSizes.screenWidth;

    DelightToastBar(
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: SizedBox(
              width: sizeWid,
              child: ToastCard(
                leading: const Icon(
                  Icons.info,
                  color: Colors.blue,
                ),
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    title ?? 'Info',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
                subtitle: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    subTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
                onTap: onTap ?? removeToast,
                trailing: const IconButton(
                  onPressed: DelightToastBar.removeAll,
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      autoDismiss: true,
      snackbarDuration: const Duration(milliseconds: 3000),
      position: DelightSnackbarPosition.top,
    ).show(context);
  }

  // Error notification
  static void showError(BuildContext context, String? title, String subTitle,
      {dynamic Function()? onTap}) {
    removeToast();
    AppSizes().init(context);

    final sizeWid = ResponsiveWidget.isLargeScreen(context) ||
            ResponsiveWidget.isMediumScreen(context)
        ? AppSizes.screenWidth * 0.4
        : AppSizes.screenWidth;

    DelightToastBar(
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: SizedBox(
              width: sizeWid,
              child: ToastCard(
                leading: const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    title ?? 'Error',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ),
                subtitle: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    subTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ),
                onTap: onTap ?? removeToast,
                trailing: const IconButton(
                  onPressed: DelightToastBar.removeAll,
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      autoDismiss: true,
      snackbarDuration: const Duration(milliseconds: 3000),
      position: DelightSnackbarPosition.top,
    ).show(context);
  }
}
