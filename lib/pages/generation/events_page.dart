import 'dart:io';

import 'package:aadi/utils/colors.dart';
import 'package:aadi/widgets/image_picker.dart';
import 'package:aadi/widgets/my_button.dart';
import 'package:aadi/widgets/snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final store = FirebaseFirestore.instance;
  Map<String, dynamic> festivalData = {};
  Map<String, dynamic> cardsData = {};
  File? image;
  bool isLoading = true;
  bool isFestivals = true;
  bool isCards = true;
  int? selectedFestivalIndex;
  int? selectedCardIndex;

  // INIT STATE
  @override
  void initState() {
    getEvents();
    super.initState();
  }

  // GET EVENTS
  Future<void> getEvents() async {
    final festivals = await store.collection('Events').doc('festivals').get();
    final cards = await store.collection('Events').doc('cards').get();

    final myFestivalData = festivals.data()!;
    final myCardData = cards.data()!;

    festivalData.addAll(myFestivalData);
    cardsData.addAll(myCardData);

    setState(() {
      isLoading = false;
    });
  }

  // GENERATE
  Future<void> generate() async {
    if (selectedFestivalIndex == null && selectedCardIndex == null) {
      return mySnackBar(context, 'Select Festival or Card');
    }
    if (image == null) {
      return mySnackBar(context, 'Select an Image');
    }

    if (selectedFestivalIndex != null) {
      final name = festivalData.keys.elementAt(selectedFestivalIndex!);
      final imageUrl = festivalData[name]['image'];
    } else if (selectedCardIndex != null) {
      final name = cardsData.keys.elementAt(selectedCardIndex!);
      final imageUrl = cardsData[name]['image'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePicker = ImagePickerHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  return Padding(
                    padding: EdgeInsets.all(width * 0.0225),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isFestivals = !isFestivals;
                              });
                            },
                            child: ExpansionTile(
                              onExpansionChanged: (value) {
                                setState(() {
                                  isFestivals = value;
                                });
                              },
                              initiallyExpanded: true,
                              tilePadding: EdgeInsets.symmetric(
                                horizontal: width * 0.0225,
                              ),
                              backgroundColor: white,
                              collapsedBackgroundColor: white,
                              textColor: primaryDark.withOpacity(0.9),
                              collapsedTextColor: primaryDark,
                              collapsedIconColor: primaryDark2,
                              shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                                borderSide: BorderSide(
                                  color: primaryDark.withOpacity(0.1),
                                ),
                              ),
                              collapsedShape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                                borderSide: BorderSide(
                                  color: primaryDark.withOpacity(0.33),
                                ),
                              ),
                              title: Text(
                                'Festivals',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: width * 0.05,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(width * 0.0125),
                                  child: SizedBox(
                                    width: width,
                                    height: 133,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      physics: ClampingScrollPhysics(),
                                      itemCount: festivalData.length,
                                      itemBuilder: (context, index) {
                                        final festivalName =
                                            festivalData.keys.elementAt(index);

                                        final festivalImage =
                                            festivalData[festivalName]['image'];

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedFestivalIndex = index;
                                              selectedCardIndex = null;
                                            });
                                          },
                                          child: Container(
                                            width: width * 0.4,
                                            decoration: BoxDecoration(
                                              color:
                                                  selectedFestivalIndex == index
                                                      ? primaryDark
                                                      : white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                12 - width * 0.0125,
                                              ),
                                              border: Border.all(
                                                color: primaryDark,
                                              ),
                                            ),
                                            padding: EdgeInsets.all(
                                              width * 0.0225,
                                            ),
                                            margin: EdgeInsets.only(
                                              right: width * 0.0225,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    2,
                                                  ),
                                                  child: Image.network(
                                                    festivalImage,
                                                    width: width * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Text(
                                                  festivalName,
                                                  style: TextStyle(
                                                    color:
                                                        selectedFestivalIndex ==
                                                                index
                                                            ? white
                                                            : primaryDark,
                                                    fontSize: width * 0.03,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isCards = !isCards;
                              });
                            },
                            child: ExpansionTile(
                              onExpansionChanged: (value) {
                                setState(() {
                                  isCards = value;
                                });
                              },
                              initiallyExpanded: true,
                              tilePadding: EdgeInsets.symmetric(
                                horizontal: width * 0.0225,
                              ),
                              backgroundColor: white,
                              collapsedBackgroundColor: white,
                              textColor: primaryDark.withOpacity(0.9),
                              collapsedTextColor: primaryDark,
                              collapsedIconColor: primaryDark2,
                              shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                                borderSide: BorderSide(
                                  color: primaryDark.withOpacity(0.1),
                                ),
                              ),
                              collapsedShape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                                borderSide: BorderSide(
                                  color: primaryDark.withOpacity(0.33),
                                ),
                              ),
                              title: Text(
                                'Cards',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: width * 0.05,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(width * 0.0125),
                                  child: SizedBox(
                                    width: width,
                                    height: 133,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      physics: ClampingScrollPhysics(),
                                      itemCount: cardsData.length,
                                      itemBuilder: (context, index) {
                                        final cardName =
                                            cardsData.keys.elementAt(index);

                                        final cardImage =
                                            cardsData[cardName]['image'];

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedCardIndex = index;
                                              selectedFestivalIndex = null;
                                            });
                                          },
                                          child: Container(
                                            width: width * 0.4,
                                            decoration: BoxDecoration(
                                              color: selectedCardIndex == index
                                                  ? primaryDark
                                                  : white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                12 - width * 0.0125,
                                              ),
                                              border: Border.all(
                                                color: primaryDark,
                                              ),
                                            ),
                                            padding: EdgeInsets.all(
                                              width * 0.0225,
                                            ),
                                            margin: EdgeInsets.only(
                                              right: width * 0.0225,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    2,
                                                  ),
                                                  child: Image.network(
                                                    cardImage,
                                                    width: width * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Text(
                                                  cardName,
                                                  style: TextStyle(
                                                    color: selectedCardIndex ==
                                                            index
                                                        ? white
                                                        : primaryDark,
                                                    fontSize: width * 0.03,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
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
                                        context,
                                        'Select an Image',
                                      );
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
                                    border: Border.all(
                                        color: primaryDark, width: 1.5),
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
                          SizedBox(height: 12),
                          MyButton(
                            text: 'GENERATE',
                            onTap: () async {},
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
