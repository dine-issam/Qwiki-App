import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/models/boutique.dart';
import 'package:delivery_app/pages/shop/catalogue_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopScreen extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final String image;
  final String phone;
  final String address;
  final List<Map<String, dynamic>> catalogues;

  const ShopScreen({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.phone,
    required this.address,
    required this.catalogues,
  });

  Future<void> _handleCataloguePress(
    BuildContext context,
    Map<String, dynamic> catalogue,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view products')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      // First verify token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        Navigator.pop(context); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in again to continue'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final boutique = await Boutique.fetchBoutiquesById(id);
      // Hide loading indicator
      Navigator.pop(context);

      if (boutique != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CatalogueScreen(
                  boutiqueId: id,
                  catalogueId: catalogue['_id'],
                  catalogueName:
                      catalogue['nomCatalogue'] ?? 'Unnamed Catalogue',
                  shopName: name,
                  boutiqueAddress: {
                    'latitude': boutique.address['latitude'] ?? 0.0,
                    'longitude': boutique.address['longitude'] ?? 0.0,
                    'label': address,
                  },
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to access boutique details. Please check your permissions.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
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
          "Shop Details",
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child:
                  image.startsWith('http')
                      ? Image.network(
                        image,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Image.asset(
                              "assets/images/image2.png",
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                      )
                      : Image.asset(
                        "assets/images/image2.png",
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: GoogleFonts.nunitoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            Text(
              description,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Phone: $phone",
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Address: $address",
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            if (catalogues.isNotEmpty) ...[
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Catalogues",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: MyColors.primaryColor,
                    decoration: TextDecoration.underline,
                    decorationColor: MyColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: catalogues.length,
                  itemBuilder: (context, index) {
                    final catalogue = catalogues[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColors.primaryColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            catalogue['nomCatalogue'] ?? 'Unnamed Catalogue',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                () => _handleCataloguePress(context, catalogue),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Check Products",
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Text(
                    "No catalogues available",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
