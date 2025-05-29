import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/pages/livreur/order_screen.dart';
import 'package:delivery_app/pages/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum DeliveryStatusType { request, analysis, accepted, rejected }

class DeliveryStatusScreen extends StatefulWidget {
  final DeliveryStatusType status;

  const DeliveryStatusScreen({Key? key, required this.status})
    : super(key: key);

  @override
  State<DeliveryStatusScreen> createState() => _DeliveryStatusScreenState();
}

class _DeliveryStatusScreenState extends State<DeliveryStatusScreen> {
  bool _isUserActive = false;
  bool _isLoading = true;
  late DeliveryStatusType _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status; // Initialize with provided status
    _checkUserStatus();
  }

  DeliveryStatusType _getStatusFromUserData(List<String> roles, bool isActive) {
    if (roles.contains('LIVREUR') && isActive) {
      return DeliveryStatusType.accepted;
    }
    if (roles.contains('CLIENT') && isActive) {
      return DeliveryStatusType.request;
    }
    if (roles.contains('LIVREUR') && !isActive) {
      return DeliveryStatusType.analysis;
    }
    return DeliveryStatusType.request;
  }

  Future<void> _checkUserStatus() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final token = prefs.getString('auth_token');

      if (userId == null || token == null) {
        setState(() {
          _isLoading = false;
          _isUserActive = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          'http://192.168.154.195:7777/service-user/api/v1/auth/users/$userId?token=$token',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final List<String> roles = List<String>.from(
          userData['roles'] ?? ['Client'],
        );
        final bool active = userData['active'] ?? false;

        setState(() {
          _isUserActive = active;
          _currentStatus = _getStatusFromUserData(roles, active);
          _isLoading = false;
        });
        debugPrint('User active status: $_isUserActive, Roles: $roles');
      } else {
        debugPrint('Error response: ${response.statusCode}');
        setState(() {
          _isLoading = false;
          _isUserActive = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking user status: $e');
      setState(() {
        _isLoading = false;
        _isUserActive = false;
      });
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
              MaterialPageRoute(builder: (context) => ProfileScreen()),
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DeliveryStatusVisualizer(
                        currentStatus: _currentStatus,
                        showAcceptedIcon: _isUserActive,
                      ),
                      if (!_isUserActive && !_isLoading) ...[
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _checkUserStatus,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: Text(
                            "Refresh Status",
                            style: GoogleFonts.nunitoSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isUserActive &&
                              _currentStatus == DeliveryStatusType.accepted
                          ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrderScreen(),
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryColor,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isUserActive ? "See Orders" : "Be Delivery",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryStatusVisualizer extends StatelessWidget {
  final DeliveryStatusType currentStatus;
  final bool showAcceptedIcon;

  const DeliveryStatusVisualizer({
    Key? key,
    required this.currentStatus,
    this.showAcceptedIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeliveryStatusStep(
          title: "Request",
          description: "Your request is set",
          status: _getStepStatus('request'),
          image: "assets/images/request.png",
        ),
        StepConnector(
          active: currentStatus.index >= DeliveryStatusType.analysis.index,
        ),
        DeliveryStatusStep(
          title: "Analysis",
          description: "Request is analysed",
          status: _getStepStatus('analysis'),
          image: "assets/images/analysis.png",
        ),
        StepConnector(
          active:
              currentStatus.index >= DeliveryStatusType.accepted.index ||
              currentStatus == DeliveryStatusType.rejected,
        ),
        DeliveryStatusStep(
          title:
              currentStatus == DeliveryStatusType.rejected
                  ? "Rejected"
                  : "Accepted",
          description:
              currentStatus == DeliveryStatusType.rejected
                  ? "Request is rejected"
                  : "Request is accepted",
          status: _getStepStatus('accepted'),
          image:
              currentStatus == DeliveryStatusType.rejected
                  ? "assets/images/request.png"
                  : "assets/images/accepted.png",
        ),
        if (currentStatus == DeliveryStatusType.rejected)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              "Your files are not accepted",
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  String _getStepStatus(String step) {
    if (currentStatus == DeliveryStatusType.rejected && step == 'accepted') {
      return 'rejected';
    }

    if (step == 'accepted' && showAcceptedIcon) {
      return 'active';
    }

    final steps = ['request', 'analysis', 'accepted'];
    final current = currentStatus.toString().split('.').last;
    final currentIndex = steps.indexOf(current);
    final stepIndex = steps.indexOf(step);

    if (step == 'accepted' && currentStatus == DeliveryStatusType.accepted) {
      return 'active';
    }

    if (stepIndex < currentIndex) return 'completed';
    if (stepIndex == currentIndex) return 'active';
    return 'pending';
  }
}

class DeliveryStatusStep extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final String image;

  const DeliveryStatusStep({
    Key? key,
    required this.title,
    required this.description,
    required this.status,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Indicator Circle
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(child: _getStatusIcon()),
        ),
        const SizedBox(width: 16),

        // Step Info Card
        Container(
          width: 260,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (title == "Accepted" && status == 'active')
                Icon(Icons.verified_user, color: Colors.white, size: 32)
              else if (title == "Accepted")
                Icon(Icons.check_circle, color: Colors.white, size: 32)
              else
                Image.asset(image),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'completed':
        return MyColors.primaryColor;
      case 'active':
        return MyColors.primaryColor;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey.shade300;
    }
  }

  Widget _getStatusIcon() {
    switch (status) {
      case 'completed':
      case 'active':
        return const Icon(Icons.check_circle, color: Colors.white, size: 24);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.white, size: 24);
      default:
        return const Icon(Icons.circle, color: Colors.white, size: 10);
    }
  }
}

class StepConnector extends StatelessWidget {
  final bool active;

  const StepConnector({Key? key, required this.active}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, bottom: 12),
      height: 30,
      width: 1.5,
      color: active ? MyColors.primaryColor : Colors.grey.shade300,
    );
  }
}
