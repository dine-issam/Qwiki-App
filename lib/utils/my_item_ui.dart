import 'package:delivery_app/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyItemUi extends StatelessWidget {
  const MyItemUi({super.key, required this.title, required this.image, required this.isSelected});

  final String title;
  final String image;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? MyColors.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.primaryColor),
      ),
      child: Column(
        children: [
          ImageIcon(
            AssetImage(image),
            color: isSelected ? Colors.white : MyColors.primaryColor,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : MyColors.primaryColor,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
