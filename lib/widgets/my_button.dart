import 'package:aadi/utils/colors.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width = double.infinity,
    this.verticalPadding,
    this.horizontalMargin,
    this.verticalMargin,
  });

  final String text;
  final double width;
  final double? verticalPadding;
  final double? horizontalMargin;
  final double? verticalMargin;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: primaryDark,
        ),
        padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 16),
        margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin ?? 0,
          vertical: verticalMargin ?? 12,
        ),
        alignment: Alignment.center,
        child: Text(
          text.toString().trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: primary),
        ),
      ),
    );
  }
}
