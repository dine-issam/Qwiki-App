import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnbordingScreen2 extends StatelessWidget {
  const OnbordingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage('assets/images/onbording_2.png')),
              const SizedBox(height: 40),
              Text(
                'Get new benefits and\n Work in safe way',
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
                "You can be delivery in our app and you will insure to get reveniew with the best  way and in safe conditions",
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
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 100),
                  decoration: BoxDecoration(
                    color: MyColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Get Started",
                    style: GoogleFonts.nunitoSans(
                      textStyle: TextStyle(
                        color: MyColors.whiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
