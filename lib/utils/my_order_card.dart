import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/maps/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:google_fonts/google_fonts.dart';

class MyOrderCard extends StatelessWidget {
  const MyOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status and More button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Payed",
                style: GoogleFonts.nunitoSans(
                  color: MyColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                  decorationColor: MyColors.primaryColor,
                ),
              ),
              Row(
                children: [
                  Text(
                    "more",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 5),
                  ImageIcon(
                    AssetImage("assets/icons/see_all_icon.png"),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Order details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: "Order Number  ",
                  style: GoogleFonts.nunitoSans(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(
                      text: "#123665",
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    "250.00 DA",
                    style: GoogleFonts.nunitoSans(
                      color: MyColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("|"),
                  SizedBox(width: 10),
                  Text(
                    "5 items",
                    style: GoogleFonts.nunitoSans(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Delivery info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: "Delivering By :  ",
                  style: GoogleFonts.nunitoSans(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Abdelouaheb benazzi",
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    "See Profile",
                    style: GoogleFonts.nunitoSans(
                      color: MyColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 5),
                  ImageIcon(
                    AssetImage("assets/icons/see_all_icon.png"),
                    color: MyColors.primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Payment and Date/Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Payment By Card",
                style: GoogleFonts.nunitoSans(color: Colors.black),
              ),
              Text(
                "05-03-2025   13:30 pm",
                style: GoogleFonts.nunitoSans(color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Modify your track button to check location services before navigation
                  onPressed: () async {
                    // Check services and permissions before navigating
                    bool serviceEnabled =
                        await gl.Geolocator.isLocationServiceEnabled();
                    if (!serviceEnabled) {
                      // Show dialog to enable location services
                      return;
                    }

                    gl.LocationPermission permission =
                        await gl.Geolocator.checkPermission();
                    if (permission == gl.LocationPermission.denied) {
                      permission = await gl.Geolocator.requestPermission();
                    }

                    if (permission == gl.LocationPermission.denied ||
                        permission == gl.LocationPermission.deniedForever) {
                      // Show dialog about needing permissions
                      return;
                    }

                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (context) => MapScreen()),
                    );
                  },
                  child: Text(
                    "Track",
                    style: GoogleFonts.nunitoSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 25),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.nunitoSans(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
