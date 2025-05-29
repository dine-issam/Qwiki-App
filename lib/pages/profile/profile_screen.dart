import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/home/home_screen.dart';
import 'package:delivery_app/pages/auth/login_screen.dart';
import 'package:delivery_app/models/basket.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:delivery_app/pages/profile/delivery_apply_screen.dart';
import 'package:delivery_app/pages/profile/delivery_status_screen.dart';
import 'package:delivery_app/pages/profile/edit_profile_screen.dart';
import 'package:delivery_app/utils/my_navigation_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool hasAppliedForDelivery = false;
  bool isLoading = true; // Add loading state
  bool isActive = false; // Track if user is active delivery person

  // Initialize with default values to prevent null errors
  int id = 0;
  String firstName = "";
  String lastName = "";
  String email = "";
  int phone = 0;
  String gender = "";
  int age = 0;
  File? profileImage;
  List<String> roles = [];

  int? userId;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadDeliveryStatus();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id');
      token = prefs.getString('auth_token');

      if (userId != null && token != null) {
        await fetchUserProfile(userId!, token!);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserProfile(int userId, String token) async {
    try {
      final url = Uri.parse(
        "http://192.168.154.195:7777/service-user/api/v1/auth/users/$userId?token=$token",
      );

      debugPrint("📡 Sending GET request to $url");

      final response = await http.get(url).timeout(const Duration(seconds: 30));

      debugPrint("✅ Response status: ${response.statusCode}");
      debugPrint("📦 Raw Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        debugPrint("🧩 Parsed user data: $data");

        setState(() {
          id = data['id'] ?? 0;
          firstName = data['firstName'] ?? '';
          lastName = data['lastName'] ?? '';
          email = data['email'] ?? '';
          phone = data['phone'] ?? '';
          gender = data['gender'] ?? '';
          age = data['age'] ?? 0;
          isActive = data['active'] ?? false; // Get delivery active status
          roles = List<String>.from(data['roles'] ?? []);
          isLoading = false;
        });
      } else {
        debugPrint("❌ Failed to load profile. Status: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🔥 Exception during fetch: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadDeliveryStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hasAppliedForDelivery = prefs.getBool('hasAppliedForDelivery') ?? false;
    });
  }

  Future<void> _markAsApplied() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAppliedForDelivery', true);
    setState(() {
      hasAppliedForDelivery = true;
    });
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Logout",
            style: GoogleFonts.nunitoSans(
              fontWeight: FontWeight.w700,
              color: MyColors.primaryColor,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.nunitoSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancel",
                style: GoogleFonts.nunitoSans(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Logout",
                style: GoogleFonts.nunitoSans(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        // Clear the basket first
        final basket = Provider.of<BasketModel>(context, listen: false);
        await basket.clearOnLogout();

        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Clear specific authentication data
        await prefs.remove('auth_token');
        await prefs.remove('user_id');
        await prefs.remove('hasAppliedForDelivery');

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error logging out. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
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
          "Profile",
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: MyColors.primaryColor),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile picture
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                profileImage != null
                                    ? FileImage(profileImage!)
                                    : const AssetImage(
                                          "assets/images/image.png",
                                        )
                                        as ImageProvider,
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final updatedProfile = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditProfileScreen(
                                        userId: id,
                                        firstname: firstName,
                                        lastname: lastName,
                                        phone: phone,
                                      ),
                                ),
                              );

                              if (updatedProfile != null) {
                                setState(() {
                                  firstName =
                                      updatedProfile["firstName"] ?? firstName;
                                  lastName =
                                      updatedProfile["lastName"] ?? lastName;
                                  phone = updatedProfile["phone"] ?? phone;
                                  gender = updatedProfile["gender"] ?? gender;
                                  age = updatedProfile["age"] ?? age;
                                  profileImage = updatedProfile["image"];
                                });
                              }
                            },
                            icon: Icon(Icons.edit, color: Colors.black),
                            label: Text(
                              "Edit Information",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Profile details
                    _buildProfileCard(),

                    SizedBox(height: 20),

                    // Credits
                    _buildCreditsSection(),

                    SizedBox(height: 20),

                    // Delivery Button
                    if (roles.contains('LIVREUR') && isActive)
                      // Show See Status button for active delivery person
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const DeliveryStatusScreen(
                                    status: DeliveryStatusType.accepted,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 100,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "See Orders",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      // Show Be Delivery button for non-active users
                      ElevatedButton(
                        onPressed: () {
                          if (!hasAppliedForDelivery) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DeliveryApplyScreen(
                                      onApply: _markAsApplied,
                                    ),
                              ),
                            ).then((_) => _loadDeliveryStatus());
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const DeliveryStatusScreen(
                                      status: DeliveryStatusType.analysis,
                                    ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 100,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          hasAppliedForDelivery ? "View Status" : "Be Delivery",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    SizedBox(height: 20),

                    // Logout button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: Icon(Icons.logout, color: Colors.white, size: 16),
                        label: Text(
                          "Log Out",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: const MyNavigationBar(
        selectedIndex: 3, // Profile screen index
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _profileDetail("Full Name", "$firstName $lastName", Colors.black),
          _profileDetail(
            "Gender",
            gender.isEmpty ? "Not specified" : gender,
            MyColors.primaryColor,
          ),
          _profileDetail(
            "Age",
            age == 0 ? "Not specified" : age.toString(),
            Colors.black,
          ),
          _profileDetail(
            "Address",
            "La Maquetta, Sidi Belabbas Ville",
            Colors.blue,
          ),
          _profileDetail(
            "Phone Number",
            phone.toString(),
            MyColors.primaryColor,
          ),
          _profileDetail(
            "Email",
            email.isEmpty ? "Not specified" : email,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 28,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Credits",
                    style: GoogleFonts.nunitoSans(fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "3000 Da",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MyColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {}, // TODO: Add functionality
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Charge Credits",
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileDetail(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
