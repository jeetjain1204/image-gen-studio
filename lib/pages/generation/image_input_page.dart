import 'dart:io';
import 'package:aadi/pages/generation/image_generated_page.dart';
import 'package:aadi/pages/generation/loading_page.dart';
import 'package:aadi/utils/colors.dart';
import 'package:aadi/utils/openai.dart';
import 'package:aadi/utils/style_map.dart';
import 'package:aadi/widgets/image_picker.dart';
import 'package:aadi/widgets/my_button.dart';
import 'package:aadi/widgets/snack_bar.dart';
import 'package:flutter/material.dart';

class ImageInputPage extends StatefulWidget {
  const ImageInputPage({
    super.key,
    required this.featureName,
    required this.styles,
  });

  final String featureName;
  final List<String> styles;

  @override
  State<ImageInputPage> createState() => _ImageInputPageState();
}

class _ImageInputPageState extends State<ImageInputPage> {
  File? image;
  String? selectedStyle;

  Future<void> generate() async {
    if (selectedStyle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter prompt and select a style')),
      );
      return;
    }

    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoadingPage()),
      );

      String feature =
          widget.featureName.toLowerCase() == 'avatars' ? 'profile' : 'convert';

      final explanation =
          styleExplanations[feature]![selectedStyle] ?? selectedStyle;

      // Use the new method for image+text generation
      final generatedImage =
          await OpenAIService.instance.generateImageFromImageAndText(
        imageFile: image!,
        prompt:
            'Convert the provided image to a $selectedStyle style. $explanation',
        model: 'dall-e-2',
        size: '512x512',
        n: 1,
        isVariation: false,
      );

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ImageGeneratedPage(image: generatedImage),
        ),
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePicker = ImagePickerHelper();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.featureName)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return Padding(
              padding: EdgeInsets.all(width * 0.0225),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    image == null
                        ? InkWell(
                            onTap: () async {
                              final selectedImage =
                                  await imagePicker.pickImageFromCamera();
                              if (selectedImage != null) {
                                setState(() {
                                  image = selectedImage;
                                });
                              } else {
                                return mySnackBar(context, 'Select an Image');
                              }
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: width,
                              height: width,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: primaryDark,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text('Select Image'),
                            ),
                          )
                        : Container(
                            width: width,
                            height: width,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: primaryDark, width: 1.5),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Image.file(
                                  image!,
                                  width: width,
                                  height: width,
                                  fit: BoxFit.contain,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      image = null;
                                    });
                                  },
                                  icon: Icon(Icons.cancel_outlined),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(
                      width: width,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: widget.styles.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 16 / 9,
                        ),
                        itemBuilder: (context, index) {
                          final name = widget.styles[index];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedStyle = name;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selectedStyle == name
                                    ? primaryDark
                                    : primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(width * 0.0225),
                              margin: EdgeInsets.all(width * 0.0225),
                              child: Text(
                                name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selectedStyle == name
                                      ? primary
                                      : primaryDark,
                                  fontSize: width * 0.04,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    MyButton(
                      text: 'GENERATE',
                      onTap: () async {
                        await generate();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
