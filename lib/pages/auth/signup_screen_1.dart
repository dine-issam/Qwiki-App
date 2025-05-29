import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/auth/login_screen.dart';
import 'package:delivery_app/pages/auth/signup_screen_2.dart';
import 'package:delivery_app/utils/my_button.dart';
import 'package:delivery_app/utils/my_google_login_button.dart';
import 'package:delivery_app/utils/my_text_field.dart';
import 'package:delivery_app/utils/stepper_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:async';

class SignupScreen1 extends StatefulWidget {
  const SignupScreen1({super.key});

  @override
  _SignupScreen1State createState() => _SignupScreen1State();
}

class _SignupScreen1State extends State<SignupScreen1> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  String? firstNameError;
  String? lastNameError;
  String? phoneNumberError;

  Future<void> _handleGoogleOAuth2() async {
    final Uri oauthUrl = Uri.parse(
      'http://192.168.1.16:8080/api/v1/auth/oauth2/google',
    );

    if (await canLaunchUrl(oauthUrl)) {
      await launchUrl(oauthUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $oauthUrl';
    }
  }

  void _validateAndProceed() {
    setState(() {
      firstNameError = _validateName(_firstNameController.text);
      lastNameError = _validateName(_lastNameController.text);
      phoneNumberError = _validatePhoneNumber(_phoneNumberController.text);
    });

    if (firstNameError == null &&
        lastNameError == null &&
        phoneNumberError == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SignupScreen2(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                phone: _phoneNumberController.text,
              ),
        ),
      );
    }
  }

  String? _validateName(String name) {
    if (name.isEmpty) {
      return "Name cannot be empty";
    }
    return null;
  }

  String? _validatePhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (phoneNumber.isEmpty) {
      return "Phone number cannot be empty";
    } else if (!phoneRegex.hasMatch(phoneNumber)) {
      return "Enter a valid 10-digit phone number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/login.png",
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Text(
              "SIGN UP",
              style: GoogleFonts.nunitoSans(
                textStyle: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: MyColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            StepperIndicator(step: 1),
            const SizedBox(height: 10),
            Text(
              "Set your personal information",
              style: GoogleFonts.nunitoSans(
                textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: MyColors.secondTextColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    hintText: "First Name",
                    icon: Icons.person_outline,
                    isPassword: false,
                    controller: _firstNameController,
                    keyboardType: TextInputType.name,
                  ),
                  if (firstNameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        firstNameError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 20),
                  MyTextField(
                    hintText: "Last Name",
                    icon: Icons.person_outline,
                    isPassword: false,
                    controller: _lastNameController,
                    keyboardType: TextInputType.name,
                  ),
                  if (lastNameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        lastNameError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 20),
                  MyTextField(
                    hintText: "Phone Number",
                    icon: Icons.phone_outlined,
                    isPassword: false,
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                  ),
                  if (phoneNumberError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        phoneNumberError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 20),
                  MyButton(
                    text: "Next",
                    color: MyColors.blackColor,
                    onTap: _validateAndProceed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Text(
                "Already have an account?",
                style: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MyColors.blackColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            MyGoogleLoginButton(
              text: "Continue with Google",
              image: "assets/images/google.png",
              onTap: _handleGoogleOAuth2,
            ),

            const SizedBox(height: 10),
            MyGoogleLoginButton(
              text: "Continue with Facebook",
              image: "assets/images/facebook.png",
              onTap: () {
                // Handle Facebook login
              },
            ),
          ],
        ),
      ),
    );
  }
}
