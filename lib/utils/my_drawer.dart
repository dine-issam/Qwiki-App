import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/auth/login_screen.dart';
import 'package:delivery_app/pages/home/home_screen.dart';
import 'package:delivery_app/pages/home/orders_screen.dart';
import 'package:delivery_app/pages/profile/profile_screen.dart';
import 'package:delivery_app/pages/shop/basket_screen.dart';
import 'package:delivery_app/pages/shop/shops_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  final VoidCallback onClose;

  const CustomDrawer({super.key, required this.onClose});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int _selectedIndex = 0; // Default selected item index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Close the drawer first
    widget.onClose();

    // Define screen navigation
    Widget nextScreen;
    switch (index) {
      case 0: // Home
        nextScreen = const HomeScreen();
        break;
      case 1: // Shops
        nextScreen = const ShopsScreen();
        break;
      case 2: // My Orders
        nextScreen = const OrdersScreen();
        break;
      case 3: // My Basket
        nextScreen = BasketScreen(
          boutiqueId: '', // We'll need to handle this case differently
          boutiqueAddress: const {
            'latitude': 0.0,
            'longitude': 0.0,
            'label': '',
          },
        );
        break;
      case 4: // Profile
        nextScreen = const ProfileScreen();
        break;
      case 7: // Logout
        _handleLogout(context);
        return;
      default:
        return;
    }

    // Navigate to the selected screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  void _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Confirm Logout',
              style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to logout?',
              style: GoogleFonts.nunitoSans(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.nunitoSans(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Logout',
                  style: GoogleFonts.nunitoSans(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      // Clear user data and navigate to login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!context.mounted) return;

      // Navigate to login screen and clear all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    int index, {
    Color color = Colors.black,
  }) {
    bool isSelected = _selectedIndex == index;
    bool isLogout = index == 9; // Check if the item is "Log out"
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color:
                isLogout
                    ? Colors.red
                    : (isSelected
                        ? MyColors.primaryColor
                        : Colors
                            .white), // Change color based on selection and if it's "Log out"
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 25,
                color:
                    isLogout
                        ? Colors.white
                        : (isSelected ? Colors.white : color),
              ), // Change icon color based on selection and if it's "Log out"
              const SizedBox(width: 40),
              Text(
                title,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      isLogout
                          ? Colors.white
                          : (isSelected
                              ? Colors.white
                              : color), // Change text color based on selection and if it's "Log out"
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 50, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Icon(Icons.arrow_back_ios_new_outlined, size: 25),
                  ),
                  const SizedBox(width: 40),
                  Text(
                    "MENU",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              _buildDrawerItem(Icons.home, "Home", 0),
              _buildDrawerItem(Icons.store, "Shops", 1),

              _buildDrawerItem(Icons.shopping_cart, "My Orders", 2),
              _buildDrawerItem(Icons.shopping_basket, "My Basket", 3),
              Spacer(),
              _buildDrawerItem(Icons.person, "Profile", 4),
              _buildDrawerItem(Icons.info, "About us", 5),
              _buildDrawerItem(Icons.help, "Help", 6),
              const SizedBox(height: 20),

              _buildDrawerItem(Icons.logout, "Log out", 7, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
