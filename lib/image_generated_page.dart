import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:aadi/widgets/my_button.dart';

class ImageGeneratedPage extends StatelessWidget {
  final Uint8List image;

  const ImageGeneratedPage({Key? key, required this.image}) : super(key: key);

  Future<void> _saveImage(BuildContext context) async {
    try {
      final result = await ImageGallerySaver.saveImage(
        image,
        quality: 100,
        name: "aadi_generated_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image saved to gallery')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save image')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/aadi_shared_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(image);

      // Share the file
      await Share.shareXFiles([
        XFile(tempFile.path),
      ], text: 'Generated with Aadi App');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing image: $e')));
    }
  }

  void _goToNext(BuildContext context) {
    // Navigate back to the main screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveImage(context),
            tooltip: 'Save to Gallery',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareImage(context),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(child: Image.memory(image, fit: BoxFit.contain)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(text: 'SAVE', onTap: () => _saveImage(context)),
                MyButton(text: 'SHARE', onTap: () => _shareImage(context)),
                MyButton(text: 'NEXT', onTap: () => _goToNext(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
