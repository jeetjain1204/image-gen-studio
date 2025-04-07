import 'package:aadi/pages/generation/image_generated_page.dart';
import 'package:aadi/pages/generation/loading_page.dart';
import 'package:aadi/utils/colors.dart';
import 'package:aadi/utils/openai.dart';
import 'package:aadi/utils/style_map.dart';
import 'package:aadi/widgets/my_button.dart';
import 'package:aadi/widgets/text_field.dart';
import 'package:flutter/material.dart';

class TextInputPage extends StatefulWidget {
  const TextInputPage({super.key, required this.styles, required this.prompt});

  final String prompt;
  final List<String> styles;

  @override
  State<TextInputPage> createState() => _TextInputPageState();
}

class _TextInputPageState extends State<TextInputPage> {
  final textController = TextEditingController();
  String? selectedStyle;

  @override
  void initState() {
    super.initState();
    setState(() {
      textController.text = widget.prompt;
    });
  }

  Future<void> generate() async {
    final prompt = textController.text.trim();
    if (prompt.isEmpty || selectedStyle == null) {    
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

      final explanation =
          styleExplanations['text']![selectedStyle] ?? selectedStyle;

      // Use the new method for text-to-image generation
      final generatedImage = await OpenAIService.instance.generateImageFromText(
        prompt:
            'Convert the provided image to a $selectedStyle style. $explanation',
        model: 'dall-e-2',
        size: '512x512',
        quality: 'standard',
        style: 'vivid',
        n: 1,
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Turn Imagination into ART')),
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
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: width * 0.0225),
                      child: MyTextField(
                        hintText: 'Enter Prompt',
                        controller: textController,
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
                                color:
                                    selectedStyle == name
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
                                  color:
                                      selectedStyle == name
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
