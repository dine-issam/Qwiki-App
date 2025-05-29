// ignore_for_file: must_be_immutable

import 'package:delivery_app/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.isPassword, 
    required this.controller, required TextInputType keyboardType,
  });

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: widget.controller,
        cursorColor: MyColors.blackColor,
        obscureText: widget.isPassword && !_isPasswordVisible,
        decoration: InputDecoration(
          
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: MyColors.blackColor),
            borderRadius: BorderRadius.circular(8.0),
          ),
          hintText: widget.hintText,
          prefixIcon: Icon(widget.icon, color: MyColors.blackColor),
          suffixIcon:
              widget.isPassword
                  ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: MyColors.blackColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                  : null,
          hintStyle: GoogleFonts.nunitoSans(
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
