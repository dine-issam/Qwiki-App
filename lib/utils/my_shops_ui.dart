import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/shop/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyShopsUi extends StatelessWidget {
  final String id;
  final String title;
  final String image;
  final String description;
  final String phone;
  final Map<String, dynamic> address;
  final List<Map<String, dynamic>> catalogues;

  const MyShopsUi({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.phone,
    required this.address,
    required this.catalogues,
  });

  @override
  Widget build(BuildContext context) {
    String addressText = address['name'] ?? '';

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                image.startsWith('http')
                    ? Image.network(
                      image,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Image.asset(
                            "assets/images/image2.png",
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                    )
                    : Image.asset(
                      "assets/images/image2.png",
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
          ),
          const SizedBox(width: 10),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                // Description
                Text(
                  description,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 15),

                // Bottom Row (Address & More Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Address
                    Expanded(
                      child: Text(
                        "Address: $addressText",
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // "More" Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ShopScreen(
                                  id: id,
                                  name: title,
                                  image: image,
                                  description: description,
                                  phone: phone,
                                  address: addressText,
                                  catalogues: catalogues,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "See Shop",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
