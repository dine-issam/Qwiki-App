import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/models/boutique.dart';
import 'package:delivery_app/pages/home/home_screen.dart';
import 'package:delivery_app/utils/my_drawer.dart';
import 'package:delivery_app/utils/my_item_ui.dart';
import 'package:delivery_app/utils/my_navigation_bar.dart';
import 'package:delivery_app/utils/my_shops_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  bool _isDrawerOpen = false;
  String _searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {"title": "Drinks", "image": "assets/icons/cup_icon.png"},
      {"title": "Candy", "image": "assets/icons/cockiz.png"},
      {"title": "Food", "image": "assets/icons/pizza.png"},
      {"title": "Clothe", "image": "assets/icons/tshirt.png"},
    ];

    return Stack(
      children: [
        Scaffold(
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
              "Shops",
              style: GoogleFonts.nunitoSans(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: searchController,
                      cursorColor: MyColors.blackColor,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: MyColors.blackColor,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintText: "Search for shop...",
                        suffixIcon: Icon(
                          Icons.search,
                          color: MyColors.blackColor,
                        ),
                        hintStyle: GoogleFonts.nunitoSans(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  FutureBuilder<List<Boutique>>(
                    future: Boutique.fetchBoutiques(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: MyColors.primaryColor,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No shops found.'));
                      }
                      var boutiques = snapshot.data!;

                      // Filter boutiques based on search query
                      if (_searchQuery.isNotEmpty) {
                        boutiques =
                            boutiques
                                .where(
                                  (boutique) => boutique.name
                                      .toLowerCase()
                                      .contains(_searchQuery.toLowerCase()),
                                )
                                .toList();
                      }

                      if (boutiques.isEmpty) {
                        return Center(
                          child: Text(
                            'No shops found matching "$_searchQuery"',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemBuilder: (_, index) {
                          final boutique = boutiques[index];
                          return MyShopsUi(
                            id: boutique.id,
                            image: boutique.photo,
                            title: boutique.name,
                            description: boutique.description,
                            phone: boutique.phone,
                            address: boutique.address,
                            catalogues: boutique.catalogues,
                          );
                        },
                        itemCount: boutiques.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          bottomNavigationBar: MyNavigationBar(
            selectedIndex:
                2, // Set the selected index to highlight the Profile tab
          ),
        ),

        // Blur effect when drawer is open
        if (_isDrawerOpen)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              // ignore: deprecated_member_use
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

        // Custom Drawer
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          left: _isDrawerOpen ? 0 : -250,
          top: 0,
          bottom: 0,
          child: CustomDrawer(onClose: _toggleDrawer),
        ),
      ],
    );
  }
}
