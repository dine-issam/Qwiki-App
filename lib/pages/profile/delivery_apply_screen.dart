import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeliveryApplyScreen extends StatefulWidget {
  const DeliveryApplyScreen({super.key, required this.onApply});
  final VoidCallback onApply;

  @override
  State<DeliveryApplyScreen> createState() => _DeliveryApplyScreenState();
}

class _DeliveryApplyScreenState extends State<DeliveryApplyScreen> {
  bool _acceptTerms = false;
  final _nationalCardController = TextEditingController();
  final _vehiclePapersController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nationalCardController.dispose();
    _vehiclePapersController.dispose();
    super.dispose();
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 60, color: MyColors.primaryColor),
              const SizedBox(height: 20),
              Text(
                "Your Request is Passed Successfully",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Wait to analyze your request and get an answer in a short time.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isConfirmEnabled =
        _nationalCardController.text.isNotEmpty &&
        _vehiclePapersController.text.isNotEmpty &&
        _acceptTerms;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: MyColors.primaryColor,
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        title: Text(
          "Delivery Apply",
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Text(
              "Enter your Document Numbers to Confirm\nyour Identity",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 25),
            _documentInputTile(
              title: "National Card Number",
              icon: Icons.credit_card_outlined,
              controller: _nationalCardController,
              hint: "Enter your national card number",
            ),
            const SizedBox(height: 15),
            _documentInputTile(
              title: "Vehicle Papers Number",
              icon: Icons.directions_car_outlined,
              controller: _vehiclePapersController,
              hint: "Enter your vehicle papers number",
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  activeColor: MyColors.primaryColor,
                  onChanged: (bool? value) {
                    setState(() => _acceptTerms = value ?? false);
                  },
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "Accept our terms and conditions included in the app",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isConfirmEnabled && !_isSubmitting
                        ? () async {
                          setState(() {
                            _isSubmitting = true;
                          });

                          try {
                            final prefs = await SharedPreferences.getInstance();

                            int? userIdInt = prefs.getInt('user_id');
                            if (userIdInt == null)
                              throw Exception('User ID not found');

                            String? token = prefs.getString('auth_token');
                            if (token == null)
                              throw Exception('Auth token not found');

                            String userId = userIdInt.toString();
                            final url = Uri.parse(
                              'http://192.168.188.195:7777/service-user/api/v1/auth/upgrade-to-livreur/$userId?token=$token',
                            );

                            final body = {
                              'cartNationalId':
                                  _nationalCardController.text.trim(),
                              'vehiclePapiers':
                                  _vehiclePapersController.text.trim(),
                            };

                            debugPrint("📤 Sending POST to $url");
                            debugPrint("🛂 Token: $token");
                            debugPrint("📦 Body: $body");

                            final response = await http
                                .post(
                                  url,
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode(body),
                                )
                                .timeout(const Duration(seconds: 30));

                            debugPrint(
                              "✅ Response status: ${response.statusCode}",
                            );
                            debugPrint("📩 Response body: ${response.body}");

                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              await prefs.setBool(
                                'hasAppliedForDelivery',
                                true,
                              );
                              widget.onApply();
                              _showSuccessPopup();
                            } else {
                              throw Exception(
                                'Failed to submit application: ${response.statusCode}\n${response.body}',
                              );
                            }
                          } catch (e) {
                            debugPrint("🔥 Error occurred: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            setState(() {
                              _isSubmitting = false;
                            });
                          }
                        }
                        : null,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isConfirmEnabled ? MyColors.primaryColor : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          "Confirm",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _documentInputTile({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
