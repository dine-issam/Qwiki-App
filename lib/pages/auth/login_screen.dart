import 'dart:convert';

import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/auth/forget_password_1.dart';
import 'package:delivery_app/pages/home/home_screen.dart';
import 'package:delivery_app/pages/auth/signup_screen_1.dart';
import 'package:delivery_app/utils/my_button.dart';
import 'package:delivery_app/utils/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? emailError;
  String? passwordError;
  bool isLoading = false;

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

  Future<void> _validateAndLogin() async {
    setState(() {
      emailError = _validateEmail(_emailController.text);
      passwordError = _validatePassword(_passwordController.text);
    });

    if (emailError == null && passwordError == null) {
      setState(() => isLoading = true);
      final url = Uri.parse(dotenv.env['LOGIN_URL']!); // for Android emulator
      final headers = {"Content-Type": "application/json"};
      final body = jsonEncode({
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      });

      try {
        final response = await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 30));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final token = data['token'];
          final int userId = data['userId'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setInt('user_id', userId);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          final data = jsonDecode(response.body);
          _showErrorDialog(data['message'] ?? 'Login failed');
        }
      } catch (e) {
        _showErrorDialog("An error occurred. Check your connection.");
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Login Failed"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
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
              "LOGIN",
              style: GoogleFonts.nunitoSans(
                textStyle: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: MyColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: _emailController,
                    hintText: "E-mail",
                    icon: Icons.email_outlined,
                    isPassword: false,
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
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
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
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgetPassword1(),
                        ),
                      );
                    },
                    child: Text(
                      "Forget your password?",
                      style: GoogleFonts.nunitoSans(
                        textStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: MyColors.blackColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  MyButton(
                    text: "Log in",
                    color: MyColors.blackColor,
                    onTap: _validateAndLogin,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupScreen1(),
                  ),
                );
              },
              child: Text(
                "Create Account ?",
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
          ],
        ),
      ),
    );
  }
}
