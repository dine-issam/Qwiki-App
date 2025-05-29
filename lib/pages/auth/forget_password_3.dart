import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/auth/forget_password_2.dart';
import 'package:delivery_app/pages/auth/login_screen.dart';
import 'package:delivery_app/utils/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgetPassword3 extends StatefulWidget {
  const ForgetPassword3({super.key});

  @override
  State<ForgetPassword3> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword3> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? newPasswordError;
  String? confirmPasswordError;

  // Validate New Password
  String? _validateNewPassword(String password) {
    if (password.isEmpty) {
      return "Password cannot be empty";
    } else if (password.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  // Validate Confirm Password
  String? _validateConfirmPassword(String confirmPassword) {
    if (confirmPassword != _newPasswordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  // Handle Continue button click
  void _validateAndContinue() {
    setState(() {
      newPasswordError = _validateNewPassword(_newPasswordController.text);
      confirmPasswordError = _validateConfirmPassword(
        _confirmPasswordController.text,
      );
    });

    // Proceed if there are no errors
    if (newPasswordError == null && confirmPasswordError == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
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
            const SizedBox(height: 10),
            Text(
              "Forget Password",
              style: GoogleFonts.nunitoSans(
                textStyle: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  color: MyColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Enter your new password and confirm it",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: MyTextField(
                hintText: "New Password",
                icon: Icons.password_outlined,
                isPassword: true,
                controller: _newPasswordController,
                keyboardType: TextInputType.visiblePassword,
              ),
            ),
            if (newPasswordError != null)
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 5),
                child: Text(
                  newPasswordError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: MyTextField(
                hintText: "Confirm Password",
                icon: Icons.password_outlined,
                isPassword: true,
                controller: _confirmPasswordController,
                keyboardType: TextInputType.visiblePassword,
              ),
            ),
            if (confirmPasswordError != null)
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 5),
                child: Text(
                  confirmPasswordError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgetPassword2(),
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
                            Icons.arrow_back,
                            color: MyColors.whiteColor,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _validateAndContinue,
                        child: Container(
                          height: 40,
                          width: 258,
                          decoration: BoxDecoration(
                            color: MyColors.blackColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "Continue",
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
