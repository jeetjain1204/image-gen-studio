import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  final _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null;
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null;
  }
}
