import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/models/product.dart';
import 'package:delivery_app/models/basket.dart';
import 'package:delivery_app/pages/shop/producte_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyProducte extends StatelessWidget {
  final Product product;
  final String boutiqueId;
  final Map<String, dynamic> boutiqueAddress;

  const MyProducte({
    super.key,
    required this.product,
    required this.boutiqueId,
    required this.boutiqueAddress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductScreen(
                  product: product,
                  boutiqueId: boutiqueId,
                  boutiqueAddress: boutiqueAddress,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: MyColors.primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  product.image.startsWith('http')
                      ? Image.network(
                        product.image,
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Image.asset(
                              "assets/images/image.png",
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                            ),
                      )
                      : Image.asset(
                        product.image,
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.oxygen(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: GoogleFonts.oxygen(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} DA',
                        style: GoogleFonts.oxygen(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Consumer<BasketModel>(
                        builder: (context, basket, child) {
                          final quantity = basket.getItemQuantity(product);
                          return quantity > 0
                              ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: MyColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'In Cart: $quantity',
                                  style: GoogleFonts.oxygen(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : const SizedBox();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
