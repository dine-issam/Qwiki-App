import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/models/basket.dart';
import 'package:delivery_app/models/product.dart';
import 'package:delivery_app/pages/shop/basket_screen.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  final String boutiqueId;
  final Map<String, dynamic> boutiqueAddress;

  const ProductScreen({
    super.key,
    required this.product,
    required this.boutiqueId,
    required this.boutiqueAddress,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String selectedSize = "Medium";
  int quantity = 1;

  void incrementQuantity() {
    if (quantity < widget.product.stock) {
      setState(() {
        quantity++;
      });
    }
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void addToBasket() {
    final basket = Provider.of<BasketModel>(context, listen: false);
    final item = BasketItem(
      product: widget.product,
      quantity: quantity,
      size: selectedSize,
    );

    basket.addItem(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.nunitoSans(color: Colors.black),
                  children: [
                    TextSpan(
                      text: '${widget.product.name} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: 'has been added to your basket.'),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View',
          textColor: MyColors.primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BasketScreen(
                      boutiqueId: widget.boutiqueId,
                      boutiqueAddress: widget.boutiqueAddress,
                    ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
        ),
        backgroundColor: MyColors.primaryColor,
        toolbarHeight: 70.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        title: Text(
          widget.product.name,
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Consumer<BasketModel>(
            builder:
                (context, basket, child) => Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_basket_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BasketScreen(
                                  boutiqueId: widget.boutiqueId,
                                  boutiqueAddress: widget.boutiqueAddress,
                                ),
                          ),
                        );
                      },
                    ),
                    if (basket.itemCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            basket.itemCount.toString(),
                            style: GoogleFonts.nunitoSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      15,
                    ), // Adjust radius as desired
                    child: SizedBox(
                      width: double.infinity,
                      height: 300,
                      child:
                          widget.product.image.startsWith('http')
                              ? Image.network(
                                widget.product.image,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Image.asset(
                                      "assets/images/image.png",
                                      fit: BoxFit.cover,
                                    ),
                              )
                              : Image.asset(
                                widget.product.image,
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                ),

                if (widget.product.stock > 0)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: MyColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'In Stock: ${widget.product.stock}',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${widget.product.price.toStringAsFixed(2)} DA',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: MyColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.product.description,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Size Selection
                  Text(
                    'Size',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSizeButton('Small'),
                      const SizedBox(width: 8),
                      _buildSizeButton('Medium'),
                      const SizedBox(width: 8),
                      _buildSizeButton('Large'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selection
                  Text(
                    'Quantity',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: decrementQuantity,
                        style: IconButton.styleFrom(
                          backgroundColor: MyColors.primaryColor.withOpacity(
                            0.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        quantity.toString(),
                        style: GoogleFonts.nunitoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: incrementQuantity,
                        style: IconButton.styleFrom(
                          backgroundColor: MyColors.primaryColor.withOpacity(
                            0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 8,
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: widget.product.stock > 0 ? addToBasket : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.product.stock > 0
                  ? 'Add to Basket - \$${(widget.product.price * quantity).toStringAsFixed(2)}'
                  : 'Out of Stock',
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeButton(String size) {
    final isSelected = selectedSize == size;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedSize = size;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? MyColors.primaryColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : MyColors.primaryColor,
          side: BorderSide(color: MyColors.primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(size),
      ),
    );
  }
}
