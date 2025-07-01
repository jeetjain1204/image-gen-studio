import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class StylesCarouselSlider extends StatefulWidget {
  const StylesCarouselSlider({
    super.key,
    required this.items,
    this.onItemSelected,
    required this.width,
  });

  final double width;
  final Map<String, Map<String, String>> items;
  final ValueChanged<String>? onItemSelected;

  @override
  _StylesCarouselSliderState createState() => _StylesCarouselSliderState();
}

class _StylesCarouselSliderState extends State<StylesCarouselSlider> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.width * 0.75,
      child: Center(
        child: CarouselSlider.builder(
          itemCount: widget.items.length,
          options: CarouselOptions(
            height: widget.width * 0.75,
            enlargeCenterPage: true,
            // viewportFraction: 0.8,
            enableInfiniteScroll: false,
            autoPlay: false,
          ),
          itemBuilder: (context, index, realIdx) {
            final styleName = widget.items.keys.elementAt(index);
            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                  widget.onItemSelected?.call(styleName);
                });
              },
              child: Container(
                width: widget.width * 0.75,
                height: widget.width * 0.75,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    widget.items[styleName]!['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('error: $error');
                      return Center(child: Icon(Icons.error));
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
