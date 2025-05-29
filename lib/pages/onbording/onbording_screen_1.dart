import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/onbording/onbording_screen_2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnbordingScreen1 extends StatelessWidget {
  const OnbordingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage('assets/images/onbording_1.png')),
              const SizedBox(height: 40),
              Text(
                'Get your Commande\n to fast and ship',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                    color: MyColors.blackColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "You can set you orders and insure to get your Orders with the best , fast way and with good prices juste from your house",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                    color: MyColors.secondTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 80),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnbordingScreen2(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: MyColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: MyColors.whiteColor,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
