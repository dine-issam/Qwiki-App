import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/onbording/onbording_screen_1.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  _navigateToOnboarding() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>OnbordingScreen1 ()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image(image: AssetImage('assets/images/logo.png')),
            
            Padding(
              padding: const EdgeInsets.only(top: 170),
              child: Text(
                'Logo',
                style: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                    color: MyColors.blackColor,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
