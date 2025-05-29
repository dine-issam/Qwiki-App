import 'dart:async';
import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/auth/forget_password_1.dart';
import 'package:delivery_app/pages/auth/forget_password_3.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgetPassword2 extends StatefulWidget {
  const ForgetPassword2({super.key});

  @override
  State<ForgetPassword2> createState() => _ForgetPassword2State();
}

class _ForgetPassword2State extends State<ForgetPassword2> {
  List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());
  int countdown = 180;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    setState(() {
      countdown = 180;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void restartTimer() {
    timer.cancel();
    startTimer();
  }

  String get timerText {
    int minutes = countdown ~/ 60;
    int seconds = countdown % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Enter the code that has been sent to your email to validate the reset request",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                    width: 40,
                    height: 60,
                    child: TextField(
                      controller: otpControllers[index],
                      focusNode: otpFocusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: MyColors.blackColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: MyColors.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 5) {
                            FocusScope.of(
                              context,
                            ).requestFocus(otpFocusNodes[index + 1]);
                          } else {
                            FocusScope.of(context).unfocus(); // Hide keyboard
                          }
                        } else {
                          if (index > 0) {
                            FocusScope.of(
                              context,
                            ).requestFocus(otpFocusNodes[index - 1]);
                          } else {
                            for (var controller in otpControllers) {
                              controller.clear(); // Clear all OTP fields
                            }
                            FocusScope.of(
                              context,
                            ).requestFocus(otpFocusNodes[0]);
                          }
                        }
                      },
                      onTap: () {
                        otpControllers[index].selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: otpControllers[index].text.length,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),
            Text(
              "Code has been sent to your phone",
              style: GoogleFonts.nunitoSans(
                textStyle: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 10),
            GestureDetector(
              onTap: restartTimer,
              child: Text(
                countdown > 0 ? "Resend in $timerText" : "Resend Code",
                style: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: MyColors.blackColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword1()));
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
                    onTap: () {
                      print("Verifying OTP...");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgetPassword3(),
                        ),
                      );
                    },
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
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
