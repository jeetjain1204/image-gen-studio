import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:aadi/widgets/my_button.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageGeneratedPage extends StatefulWidget {
  final Uint8List image;
  static const platform = MethodChannel('com.infinitylab.aadi/image_saver');

  const ImageGeneratedPage({Key? key, required this.image}) : super(key: key);

  @override
  State<ImageGeneratedPage> createState() => _ImageGeneratedPageState();
}

class _ImageGeneratedPageState extends State<ImageGeneratedPage> {
  final store = FirebaseFirestore.instance;

  Future<void> _saveImage(BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/aadi_generated_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(widget.image);

      final result = await ImageGeneratedPage.platform.invokeMethod<bool>(
        'saveImageToGallery',
        {'imagePath': tempFile.path},
      );

      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/aadi_shared_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(widget.image);

      // await Share.shareXFiles([
      //   XFile(tempFile.path),
      // ], text: 'Generated with Aadi App');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing image: $e')));
    }
  }

  Future<void> _contributeToGallery(BuildContext context) async {
    try {} catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error contributing to gallery: $e')),
      );
    }
  }

  void _goToNext(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Image'),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                Center(child: Image.memory(widget.image, fit: BoxFit.contain)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(text: 'SAVE', onTap: () => _saveImage(context)),
                MyButton(text: 'SHARE', onTap: () => _shareImage(context)),
                MyButton(
                  text: 'CONTRIBUTE TO GALLERY',
                  onTap: () => _contributeToGallery(context),
                ),
                MyButton(text: 'NEXT', onTap: () => _goToNext(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
