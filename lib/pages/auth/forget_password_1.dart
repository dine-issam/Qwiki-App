import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/auth/forget_password_2.dart';
import 'package:delivery_app/pages/auth/login_screen.dart';
import 'package:delivery_app/utils/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgetPassword1 extends StatefulWidget {
  const ForgetPassword1({super.key});

  @override
  State<ForgetPassword1> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword1> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  
  bool isEmail = true;
  bool isPhone = false;

  String? emailError;
  String? phoneError;

  // Validate Email
  String? _validateEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (email.isEmpty) {
      return "Email cannot be empty";
    } else if (!emailRegex.hasMatch(email)) {
      return "Enter a valid email";
    }
    return null;
  }

  // Validate Phone Number
  String? _validatePhone(String phone) {
    if (phone.isEmpty) {
      return "Phone number cannot be empty";
    } else if (phone.length != 10) {
      return "Phone number must be 10 digits";
    }
    return null;
  }

  // On Continue Button Click
  void _validateAndContinue() {
    setState(() {
      emailError = isEmail ? _validateEmail(_emailController.text) : null;
      phoneError = isPhone ? _validatePhone(_phoneNumberController.text) : null;
    });

    // If no errors, continue to the next screen
    if (emailError == null && phoneError == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForgetPassword2(),
        ),
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
              "Enter your email or phone number to receive a code to reset your password.",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isEmail = true;
                      isPhone = false;
                    });
                  },
                  child: Text(
                    "E-mail",
                    style: GoogleFonts.nunitoSans(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color:
                            isEmail ? MyColors.primaryColor : MyColors.blackColor,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            isEmail ? MyColors.primaryColor : MyColors.blackColor,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isEmail = false;
                      isPhone = true;
                    });
                  },
                  child: Text(
                    "Phone",
                    style: GoogleFonts.nunitoSans(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color:
                            isPhone ? MyColors.primaryColor : MyColors.blackColor,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            isPhone ? MyColors.primaryColor : MyColors.blackColor,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEmail) ...[
                    MyTextField(
                      hintText: "E-mail",
                      icon: Icons.email_outlined,
                      isPassword: false,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          emailError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ] else ...[
                    MyTextField(
                      hintText: "Phone Number",
                      icon: Icons.phone_outlined,
                      isPassword: false,
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                    ),
                    if (phoneError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          phoneError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
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
