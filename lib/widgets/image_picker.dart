import 'package:enrollease_web/widgets/custom_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Future<Uint8List?> pickImage(ImageSource source) async {
//   final ImagePicker imagePicker = ImagePicker();
//   XFile? file = await imagePicker.pickImage(source: source);

//   if (file != null) {
//     return await file.readAsBytes();
//   }
//   print('No Selected Image');
//   return null;
// }

class ImageService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<Uint8List?> pickImage(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Uploading Image...'),
            ],
          ),
        );
      },
    );

    XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (context.mounted) {
      Navigator.pop(context); // Close the loading dialog
    }

    if (file != null) {
      final bytes = await file.readAsBytes();
      final sizeInMB = bytes.lengthInBytes / (1024 * 1024);
      if (sizeInMB <= 1) {
        return bytes;
      } else {
        if (kDebugMode) {
          print('Image size is larger than 1MB');
        }
        if (context.mounted) {
          DelightfulToast.showInfo(
              context, 'Info', 'Image size should be less than 1MB!');
        }
        return null;
      }
    } else {
      if (kDebugMode) print('No image selected');
      return null;
    }
  }
}
