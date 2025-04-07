import 'package:aadi/utils/colors.dart';
import 'package:flutter/material.dart';

class FeatureContainer extends StatelessWidget {
  const FeatureContainer({
    super.key,
    required this.width,
    required this.text,
    required this.page,
    required this.image,
  });

  final double width;
  final String text;
  final Widget page;
  final String image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        width: width,
        height: 180,
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          color: primaryDark,
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage('assets/$image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(width * 0.0225),
        margin: EdgeInsets.all(width * 0.0125),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.asset(
              'assets/$image.jpg',
              fit: BoxFit.cover,
              width: width,
              height: 180,
            ),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: width * 0.05,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
