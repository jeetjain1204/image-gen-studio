import 'dart:io';
import 'package:aadi/pages/generation/image_generated_page.dart';
import 'package:aadi/pages/generation/loading_page.dart';
import 'package:aadi/utils/colors.dart';
import 'package:aadi/utils/openai.dart';
import 'package:aadi/utils/style_map.dart';
import 'package:aadi/widgets/image_picker.dart';
import 'package:aadi/widgets/my_button.dart';
import 'package:aadi/widgets/snack_bar.dart';
import 'package:aadi/widgets/styles_carousel_slider.dart';
import 'package:flutter/material.dart';

class AvatarsPage extends StatefulWidget {
  const AvatarsPage({
    super.key,
    required this.featureName,
  });

  final String featureName;

  @override
  State<AvatarsPage> createState() => _AvatarsPageState();
}

class _AvatarsPageState extends State<AvatarsPage> {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: width * 0.45,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Image',
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Make sure to be in a well-lit background, clear photo',
                                style: TextStyle(
                                  fontSize: width * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                    return mySnackBar(
                                        context, 'Select an Image');
                                  }
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: width * 0.45,
                                  height: width * 0.45,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: primaryDark,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(Icons.upload_outlined),
                                ),
                              )
                            : Container(
                                width: width * 0.45,
                                height: width * 0.45,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryDark,
                                    width: 1.5,
                                  ),
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
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * 0.0125,
                        top: width * 0.045,
                        bottom: width * 0.0225,
                      ),
                      child: Text(
                        'Select Style',
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    StylesCarouselSlider(
                      width: width,
                      items: styleExplanations['profile']!,
                      onItemSelected: (value) {
                        setState(() {
                          selectedStyle = value;
                        });
                        print('selected style: $selectedStyle');
                      },
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
