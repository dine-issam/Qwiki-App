import 'package:delivery_app/pages/maps/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/models/basket.dart';
import 'package:delivery_app/models/commande.dart';
import 'package:delivery_app/utils/my_navigation_bar.dart';
import 'package:provider/provider.dart';

class BasketScreen extends StatefulWidget {
  final String boutiqueId;
  final Map<String, dynamic> boutiqueAddress;

  const BasketScreen({
    super.key,
    required this.boutiqueId,
    required this.boutiqueAddress,
  });

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  String? selectedAddress;
  double? selectedLat;
  double? selectedLng;
  late final Address pickupAddress;

  @override
  void initState() {
    super.initState();
    pickupAddress = Address(
      latitude: widget.boutiqueAddress['latitude'],
      longitude: widget.boutiqueAddress['longitude'],
      label: widget.boutiqueAddress['label'] ?? '',
    );
  }

  Future<void> _openMapScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        selectedAddress = result['address'] as String;
        selectedLat = result['latitude'] as double;
        selectedLng = result['longitude'] as double;
      });
    }
  }

  void _showCustomSnackBar({
    required List<InlineSpan> messageSpans,
    required Widget icon,
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        backgroundColor: backgroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.nunitoSans(color: Colors.black),
                  children: messageSpans,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        action: action,
      ),
    );
  }

  Future<void> _handleCheckout(BasketModel basket) async {
    if (selectedAddress == null || selectedLat == null || selectedLng == null) {
      _showCustomSnackBar(
        icon: const Icon(Icons.error_outline, color: Colors.red),
        messageSpans: const [
          TextSpan(text: 'Please select a delivery address.'),
        ],
        backgroundColor: Colors.red.shade50,
      );
      return;
    }

    final dropOffAddress = Address(
      latitude: selectedLat!,
      longitude: selectedLng!,
      label: selectedAddress!,
    );

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final success = await basket.confirmOrder(
        pickUpAddress: pickupAddress,
        dropOffAddress: dropOffAddress,
        idBoutique: widget.boutiqueId,
      );

      Navigator.pop(context); // Hide loading indicator

      if (success) {
        _showCustomSnackBar(
          icon: const Icon(
            Icons.check_circle_outline,
            color: MyColors.primaryColor,
          ),
          messageSpans: const [TextSpan(text: 'Order placed successfully!')],
          backgroundColor: MyColors.primaryColor,
        );
        Navigator.pop(context);
      } else {
        _showCustomSnackBar(
          icon: const Icon(Icons.error_outline, color: Colors.red),
          messageSpans: const [
            TextSpan(text: 'Failed to place order. Please try again.'),
          ],
          backgroundColor: Colors.red.shade50,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showCustomSnackBar(
        icon: const Icon(Icons.error_outline, color: Colors.red),
        messageSpans: [TextSpan(text: 'Error: ${e.toString()}')],
        backgroundColor: Colors.red.shade50,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
        ),
        backgroundColor: MyColors.primaryColor,
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        title: Text(
          "Your Basket",
          style: GoogleFonts.oxygen(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<BasketModel>(
        builder: (context, basket, child) {
          if (basket.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Your basket is empty",
                    style: GoogleFonts.oxygen(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Add items to start shopping!",
                    style: GoogleFonts.oxygen(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: basket.items.length,
                  itemBuilder: (context, index) {
                    final item = basket.items[index];
                    return Dismissible(
                      key: Key('${item.product.id}-${item.size}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      onDismissed: (direction) {
                        basket.removeItem(item.product.id, item.size);
                        _showCustomSnackBar(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          messageSpans: [
                            TextSpan(
                              text: '${item.product.name} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: 'removed from basket.'),
                          ],
                          backgroundColor: Colors.red.shade50,
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: Colors.red,
                            onPressed: () {
                              basket.addItem(item);
                            },
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    item.product.image.startsWith('http')
                                        ? Image.network(
                                          item.product.image,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                        : Image.asset(
                                          item.product.image,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: GoogleFonts.oxygen(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Size: ${item.size} x${item.quantity}',
                                      style: GoogleFonts.oxygen(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${(item.product.price * item.quantity).toStringAsFixed(2)} DA',
                                style: GoogleFonts.oxygen(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 8,
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPriceRow("Subtotal", basket.totalPrice),
                      const SizedBox(height: 6),
                      _buildPriceRow(
                        "Delivery",
                        basket.deliveryFee,
                        freeLabel: basket.deliveryFee <= 0,
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _openMapScreen,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: MyColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  selectedAddress ?? "Pick your address",
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      _buildPriceRow("Total", basket.grandTotal, isTotal: true),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 250,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleCheckout(basket),
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            'Confirm Order',
                            style: GoogleFonts.oxygen(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.black, // green confirm button
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const MyNavigationBar(
        selectedIndex: 0, // Basket screen index
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool freeLabel = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.oxygen(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        Text(
          freeLabel ? 'FREE' : '${amount.toStringAsFixed(2)} DA',
          style: GoogleFonts.oxygen(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color:
                freeLabel
                    ? MyColors.primaryColor
                    : isTotal
                    ? MyColors.primaryColor
                    : Colors.black,
          ),
        ),
      ],
    );
  }
}
