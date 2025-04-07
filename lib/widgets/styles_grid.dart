// import 'package:aadi/utils/colors.dart';
// import 'package:flutter/material.dart';

// class StylesGrid extends StatefulWidget {
//   const StylesGrid({
//     super.key,
//     required this.width,
//     required this.styles,
//     required this.selectedStyle,
//   });

//   final double width;
//   final List<String> styles;
//   final String? selectedStyle;

//   @override
//   State<StylesGrid> createState() => _StylesGridState();
// }

// class _StylesGridState extends State<StylesGrid> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: widget.width,
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: ClampingScrollPhysics(),
//         itemCount: widget.styles.length,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 16 / 9,
//         ),
//         itemBuilder: (context, index) {
//           final name = widget.styles[index];

//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 widget.selectedStyle = name;
//               });
//             },
//             child: Container(
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: widget.selectedStyle == name ? primaryDark : primary,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: EdgeInsets.all(widget.width * 0.0225),
//               margin: EdgeInsets.all(widget.width * 0.0225),
//               child: Text(
//                 name,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: widget.selectedStyle == name ? primary : primaryDark,
//                   fontSize: widget.width * 0.04,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
