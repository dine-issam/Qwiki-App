import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/auth/login_screen.dart';
import 'package:delivery_app/utils/my_button.dart';
import 'package:delivery_app/utils/my_google_login_button.dart';
import 'package:delivery_app/utils/my_text_field.dart';
import 'package:delivery_app/utils/stepper_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SignupScreen2 extends StatefulWidget {
  const SignupScreen2({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });
  final String firstName;
  final String lastName;
  final String phone;

  @override
  _SignupScreen2State createState() => _SignupScreen2State();
}

class _SignupScreen2State extends State<SignupScreen2> {
  late String _firstNameFromPreviousScreen;
  late String _lastNameFromPreviousScreen;
  late String _phoneFromPreviousScreen;

  @override
  void initState() {
    super.initState();
    _firstNameFromPreviousScreen = widget.firstName;
    _lastNameFromPreviousScreen = widget.lastName;
    _phoneFromPreviousScreen = widget.phone;
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _acceptTerms = false;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? termsError;

  Future<void> _registerUser(
    String firstname,
    String lastname,
    String phone,
    String email,
    String password,
  ) async {
    String apiUrl = dotenv.env['SIGNUP_URL']!; // for Android emulator

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "firstname": firstname,
              "lastname": lastname,
              "phone": phone,
              "email": email,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Account Created'),
                content: const Text(
                  'Your account has been successfully created!',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        // Registration failed
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Error'),
                content: Text('Registration failed: ${response.body}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      // Handle network or unexpected errors
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _handleGoogleOAuth2() async {
    final Uri oauthUrl = Uri.parse(
      'http://192.168.1.16:8080/api/v1/auth/oauth2/google',
    );

    if (await canLaunchUrl(oauthUrl)) {
      await launchUrl(
        oauthUrl,
        mode: LaunchMode.externalApplication, // open in external browser
      );
    } else {
      throw 'Could not launch $oauthUrl';
    }
  }

  void _validateAndSignUp() {
    setState(() {
      emailError = _validateEmail(_emailController.text);
      passwordError = _validatePassword(_passwordController.text);
      confirmPasswordError = _validateConfirmPassword(
        _passwordController.text,
        _confirmPasswordController.text,
      );
      termsError = _validateTerms(_acceptTerms);
    });

    if (emailError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        termsError == null) {
      // Call register function
      _registerUser(
        _firstNameFromPreviousScreen,
        _lastNameFromPreviousScreen,
        _phoneFromPreviousScreen,
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  String? _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (email.isEmpty) {
      return "Email cannot be empty";
    } else if (!emailRegex.hasMatch(email)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return "Password cannot be empty";
    } else if (password.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return "Confirm password cannot be empty";
    } else if (password != confirmPassword) {
      return "Passwords do not match";
    }
    return null;
  }

  String? _validateTerms(bool acceptTerms) {
    if (!acceptTerms) {
      return "You must accept the terms and conditions";
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

            // Step Indicator (1 --- 2)
            StepperIndicator(step: 2),

            const SizedBox(height: 10),

            Text(
              "Set your digital information here",
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
                  const SizedBox(height: 20),

                  MyTextField(
                    hintText: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  if (passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        passwordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 20),

                  MyTextField(
                    hintText: "Confirm Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  if (confirmPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        confirmPasswordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Checkbox(
                        checkColor: MyColors.whiteColor,
                        activeColor: MyColors.primaryColor,
                        splashRadius: 1,
                        value: _acceptTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _acceptTerms = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          "Accept our terms and conditions included in the app",
                          style: GoogleFonts.nunitoSans(
                            textStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: MyColors.blackColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (termsError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        termsError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 5),

                  MyButton(
                    text: "Sign Up",
                    color: MyColors.blackColor,
                    onTap: _validateAndSignUp,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
