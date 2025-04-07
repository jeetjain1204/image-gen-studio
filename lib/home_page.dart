import 'package:aadi/image_input_page.dart';
import 'package:aadi/image_text_input_page.dart';
import 'package:aadi/text_input_page.dart';
import 'package:aadi/utils/colors.dart';
import 'package:aadi/widgets/feature_container.dart';
import 'package:aadi/widgets/snack_bar.dart';
import 'package:aadi/widgets/text_field.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final promptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Aadi')),
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
                          width: width * 0.8,
                          child: MyTextField(
                            hintText: 'Prompt',
                            controller: promptController,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (promptController.text.isEmpty) {
                              return mySnackBar(context, 'Enter Prompt');
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => TextInputPage(
                                        styles: [
                                          'Classic Oil Painting',
                                          'Ghibli',
                                          '8-Bit Pixel Art',
                                          'Sci - Fi',
                                          '3D Cartoon',
                                          'Anime',
                                          'Geometric',
                                          'Watercolor',
                                          'Epic & Grand',
                                          'Simple & Clean',
                                          'Fun',
                                          'Claymation',
                                          'Professional',
                                        ],
                                        prompt: promptController.text.trim(),
                                      ),
                                ),
                              );
                            }
                          },
                          icon: Icon(Icons.send, color: primaryDark),
                          color: primaryDark,
                          tooltip: 'Send',
                        ),
                      ],
                    ),
                    Divider(),
                    FeatureContainer(
                      width: width,
                      text: 'Convert To Ghibli',
                      page: ImageInputPage(
                        featureName: 'Convert to Ghibli',
                        styles: [
                          'Ghibli',
                          'Brush Painting',
                          'Sketch',
                          'Watercolor',
                          'Neon Retro',
                          'Comic Book',
                          'Color Splash',
                          'Graffiti',
                          'Paper Cut Collage',
                          'Cyberpunk',
                        ],
                      ),
                      image: 'ghibli',
                    ),
                    FeatureContainer(
                      width: width,
                      text: 'Profile Avatar Maker',
                      page: ImageInputPage(
                        featureName: 'Profile Avatar Maker',
                        styles: [
                          'Ghibli',
                          'Passport Photo',
                          '3D Cartoon',
                          'Anime',
                          'Watercolor',
                          'Minecraft Avatar',
                          'Cyberpunk',
                          'Epic & Grand',
                          'Simple & Clean',
                          'Fun',
                          'Claymation',
                          'Professional',
                          'Geometric',
                          '8-Bit Pixel Art',
                        ],
                      ),
                      image: 'avatar',
                    ),
                    SizedBox(
                      width: width,
                      child: GridView(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),

                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                        ),
                        children: [
                          FeatureContainer(
                            width: width,
                            text: 'Teleport Me',
                            page: ImageTextInputPage(
                              featureName: 'Teleport Me',
                              styles: [
                                'Ghibli',
                                'Realistic',
                                'Golden Hour',
                                '3D Toy World',
                                'Adventure Poster',
                                'Magic World',
                                'Cyberpunk',
                              ],
                              featureText: 'Location',
                            ),
                            image: 'travel',
                          ),
                          FeatureContainer(
                            width: width,
                            text: 'StarSnap',
                            page: ImageTextInputPage(
                              featureName: 'StarSnap',
                              styles: [
                                'Ghibli',
                                'Realistic',
                                'Red Carpet',
                                'Candid Cafe',
                                'Podcast',
                                'Magazine Cover',
                                'Cyberpunk',
                              ],
                              featureText: 'Celebrity Name',
                            ),
                            image: 'celebrity',
                          ),
                        ],
                      ),
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
