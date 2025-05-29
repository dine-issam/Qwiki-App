import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/models/boutique.dart';
import 'package:delivery_app/models/product.dart'; // Add this import
import 'package:delivery_app/pages/home/orders_screen.dart';
import 'package:delivery_app/pages/shop/producte_screen.dart'; // Add this import
import 'package:delivery_app/pages/shop/shops_screen.dart';
import 'package:delivery_app/utils/my_drawer.dart';
import 'package:delivery_app/utils/my_item_ui.dart';
import 'package:delivery_app/utils/my_navigation_bar.dart';
import 'package:delivery_app/utils/my_seggestions_ui.dart';
import 'package:delivery_app/utils/my_shops_ui.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDrawerOpen = false;
  List<Product> _suggestions = [];
  bool _loading = true;
  String _searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
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

  Future<void> _loadSuggestions() async {
    try {
      final allProducts = await Product.fetchAllProducts();
      allProducts.shuffle(); // Randomize the products
      setState(() {
        _suggestions =
            allProducts.take(5).toList(); // Get first 5 random products
        _loading = false;
      });
    } catch (e) {
      print('Error loading suggestions: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  int selectedIndex = 0;

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
              onPressed: _toggleDrawer,
              icon: Icon(Icons.menu, color: MyColors.whiteColor),
            ),
            backgroundColor: MyColors.primaryColor,
            toolbarHeight: 70.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.list_alt_outlined, color: MyColors.whiteColor),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: searchController,
                            cursorColor: MyColors.blackColor,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
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
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrdersScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MyColors.blackColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.download_done_sharp,
                            color: MyColors.whiteColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Suggestions Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Suggestions",
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Row(
                        children: [
                          Text(
                            "See All",
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 5),
                          ImageIcon(
                            AssetImage("assets/icons/see_all_icon.png"),
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Suggestions (Horizontal Scroll)
                  _loading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: MyColors.primaryColor,
                        ),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              _suggestions
                                  .where(
                                    (product) =>
                                        _searchQuery.isEmpty ||
                                        product.name.toLowerCase().contains(
                                          _searchQuery.toLowerCase(),
                                        ) ||
                                        product.description
                                            .toLowerCase()
                                            .contains(
                                              _searchQuery.toLowerCase(),
                                            ),
                                  )
                                  .map((product) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: MySuggestionsUi(
                                        name: product.name,
                                        description: product.description,
                                        image: product.image,
                                        price: product.price,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ProductScreen(
                                                    product: product,
                                                    boutiqueId:
                                                        product.catalogueId,
                                                    boutiqueAddress: const {
                                                      'latitude': 0.0,
                                                      'longitude': 0.0,
                                                      'label': '',
                                                    },
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "SHOPs",
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ShopsScreen(),
                                  ),
                                ),
                            child: Text(
                              "See All",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          ImageIcon(
                            AssetImage("assets/icons/see_all_icon.png"),
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                  FutureBuilder<List<Boutique>>(
                    future:
                        Boutique.fetchBoutiques(), // fetches directly with token inside
                    builder: (context, snapshot) {
                      // 1. While waiting
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: MyColors.primaryColor,
                          ),
                        );
                      }

                      // 2. If there's an error
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      // 3. If empty or null data
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No shops found.'));
                      }

                      // 4. Success - render list
                      var boutiques = snapshot.data!;

                      // Filter boutiques based on search query
                      if (_searchQuery.isNotEmpty) {
                        boutiques =
                            boutiques
                                .where(
                                  (boutique) =>
                                      boutique.name.toLowerCase().contains(
                                        _searchQuery.toLowerCase(),
                                      ) ||
                                      boutique.description
                                          .toLowerCase()
                                          .contains(_searchQuery.toLowerCase()),
                                )
                                .toList();
                      }

                      if (boutiques.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Center(
                            child: Text(
                              'No shops found matching "$_searchQuery"',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: boutiques.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
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
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          bottomNavigationBar: const MyNavigationBar(
            selectedIndex: 1, // Home screen index
          ),
        ),

        // Blur effect when drawer is open
        if (_isDrawerOpen)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
