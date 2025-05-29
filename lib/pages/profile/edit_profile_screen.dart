import 'package:delivery_app/pages/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:delivery_app/constants/my_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final int userId;
  final String firstname;
  final String lastname;
  final int phone;
  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.firstname,
    required this.lastname,
    required this.phone,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _firstNameController = TextEditingController(
    text: widget.firstname,
  );
  late final TextEditingController _lastNameController = TextEditingController(
    text: widget.lastname,
  );
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.phone.toString(),
  );

  bool isMale = true;
  int selectedAge = 30;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: MyColors.primaryColor,
                ),
                title: Text("Import from Gallery"),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: MyColors.primaryColor),
                title: Text("Take a Picture"),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('auth_token') ?? '';
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_phoneController.text.length != 10 ||
        !_phoneController.text.startsWith("0")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid phone number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Remove prefix '0' from phone number before parsing
    String phoneWithoutPrefix =
        _phoneController.text.startsWith('0')
            ? _phoneController.text.substring(1)
            : _phoneController.text;

    final updatedProfile = {
      "firstname": _firstNameController.text.trim(),
      "lastname": _lastNameController.text.trim(),
      "phone": int.parse(phoneWithoutPrefix),
      "gender": isMale ? "MALE" : "FEMALE",
      "age": selectedAge,
    };

    final url = Uri.parse(
      'http://192.168.154.195:7777/service-user/api/v1/auth/user/${widget.userId}?token=$token',
    );

    try {
      final response = await http
          .put(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(updatedProfile),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      } else {
        print('Error response body: ${response.body}'); // Add debug print
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to update profile: ${response.statusCode}\n${response.body}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: MyColors.whiteColor,
          ),
        ),
        backgroundColor: MyColors.primaryColor,
        toolbarHeight: 70.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        title: Text(
          "Edit Information",
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!) as ImageProvider
                            : AssetImage("assets/profile.jpg"),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: _showImageSourceModal,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: MyColors.primaryColor,
                        child: Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(Icons.person, "First Name", _firstNameController),
            SizedBox(height: 10),
            _buildTextField(Icons.person, "Last Name", _lastNameController),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.male, color: MyColors.primaryColor),
                    SizedBox(width: 5),
                    Text("Male"),
                    Radio(
                      value: true,
                      groupValue: isMale,
                      activeColor: MyColors.primaryColor,
                      onChanged: (value) => setState(() => isMale = true),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.female, color: Colors.pink),
                    SizedBox(width: 5),
                    Text("Female"),
                    Radio(
                      value: false,
                      groupValue: isMale,
                      activeColor: Colors.pink,
                      onChanged: (value) => setState(() => isMale = false),
                    ),
                  ],
                ),
                DropdownButton<int>(
                  value: selectedAge,
                  onChanged:
                      (int? newValue) =>
                          setState(() => selectedAge = newValue!),
                  items:
                      List.generate(83, (index) => 18 + index)
                          .map<DropdownMenuItem<int>>(
                            (int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildTextField(Icons.phone, "Phone", _phoneController),
            SizedBox(height: 150),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Save Changes",
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
