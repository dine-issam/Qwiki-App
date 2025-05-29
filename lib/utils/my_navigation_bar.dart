import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/home/home_screen.dart';
import 'package:delivery_app/pages/profile/profile_screen.dart';
import 'package:delivery_app/pages/shop/basket_screen.dart';
import 'package:delivery_app/pages/shop/shops_screen.dart';
import 'package:flutter/material.dart';

class MyNavigationBar extends StatefulWidget {
  final int selectedIndex;

  const MyNavigationBar({super.key, required this.selectedIndex})
    : assert(
        selectedIndex >= 0 && selectedIndex < 4,
        'selectedIndex must be between 0 and 3',
      );

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  // Function to handle navigation
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Avoid unnecessary navigation

    setState(() {
      _selectedIndex = index;
    });

    // Define screen navigation
    Widget nextScreen;
    switch (index) {
      case 0: // Basket
        nextScreen = BasketScreen(
          boutiqueId: '',
          boutiqueAddress: const {
            'latitude': 0.0,
            'longitude': 0.0,
            'label': '',
          },
        );
        break;
      case 1: // Home
        nextScreen = const HomeScreen();
        break;
      case 2: // Explore (same as Home for now)
        nextScreen = const ShopsScreen();
        break;
      case 3: // Profile
        nextScreen = const ProfileScreen();
        break;
      default:
        nextScreen = const HomeScreen();
    }

    // Navigate to the selected screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  Widget _buildIcon(IconData icon, bool isSelected) {
    return isSelected
        ? Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: MyColors.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white),
        )
        : Icon(icon);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: MyColors.primaryColor,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.shopping_cart, _selectedIndex == 0),
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.home, _selectedIndex == 1),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.explore, _selectedIndex == 2),
              label: "Explore",
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.person, _selectedIndex == 3),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
