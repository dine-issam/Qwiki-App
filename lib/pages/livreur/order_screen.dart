import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:delivery_app/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  mp.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  bool _locationReady = false;
  bool _mapReady = false;
  mp.Position? _lastPosition;
  bool _showBottomSheet = true;
  String _activeTab = 'orders';
  bool _isLoading = false;
  List<Map<String, dynamic>> _orders = [];
  String? _error;

  String currentAddress = "Loading address...";

  // Get access token from environment variables
  final String mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  WebSocketChannel? _channel;
  Timer? _locationUpdateTimer;
  bool _isWebSocketConnected = false;
  String? _userId;
  String? _userToken;

  // Add point annotation manager field
  mp.PointAnnotationManager? _pointAnnotationManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getUserCredentials();
      await _setupPositionTracking();
      await _fetchOrders(); // Added this line
      if (_userId != null && _userToken != null) {
        await _connectWebSocket();
        _startLocationUpdates();
      }
    });
  }

  Future<void> _connectWebSocket() async {
    print(
      'Attempting to connect WebSocket with userId=$_userId and token=$_userToken',
    );

    final wsUrl = Uri.parse(
      'ws://192.168.154.195:5020?userId=$_userId&role=LIVREUR&token=$_userToken',
    );

    try {
      _channel = WebSocketChannel.connect(wsUrl);
      _isWebSocketConnected = true;
      print('WebSocket connected to $wsUrl');

      _channel!.stream.listen(
        (message) {
          print('✅ Received WebSocket message: $message');
        },
        onDone: () {
          print('⚠️ WebSocket connection closed');
          _isWebSocketConnected = false;
          _reconnectWebSocket();
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _isWebSocketConnected = false;
          _reconnectWebSocket();
        },
      );
    } catch (e) {
      print('❌ Failed to connect WebSocket: $e');
    }
  }

  void _reconnectWebSocket() {
    if (!_isWebSocketConnected) {
      print('🔁 Attempting to reconnect WebSocket in 2 seconds...');
      Future.delayed(const Duration(seconds: 2), () {
        _connectWebSocket();
      });
    }
  }

  void _startLocationUpdates() {
    print('📍 Starting location updates every 2 seconds...');
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_lastPosition != null && _isWebSocketConnected) {
        final locationData = {
          'location': [_lastPosition!.lat, _lastPosition!.lng],
        };
        final jsonMessage = jsonEncode(locationData);
        print('📤 Sending location update: $jsonMessage');
        _channel?.sink.add(jsonMessage);
      } else {
        print(
          '⛔ Skipping location update: either no position or WebSocket not connected',
        );
      }
    });
  }

  void _stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    _channel?.sink.close();
    userPositionStream?.cancel();
    super.dispose();
  }

  void _updateMapMarkersForCurrentTab() {
    if (mapboxMapController == null) return;

    // Get current tab's orders
    final displayOrders =
        _activeTab == 'requests' ? pendingOrders : acceptedOrders;

    // Create or get point annotation manager
    if (_pointAnnotationManager == null) {
      mapboxMapController!.annotations.createPointAnnotationManager().then((
        manager,
      ) {
        _pointAnnotationManager = manager;
        _addMarkersForOrders(displayOrders);
      });
    } else {
      _clearMarkers();
      _addMarkersForOrders(displayOrders);
    }
  }

  void _addMarkersForOrders(List<Map<String, dynamic>> orders) {
    for (var order in orders) {
      if (order['pickUpCoordinates'] != null) {
        _addMarker(order['pickUpCoordinates']);
      }
    }
  }

  void _addMarker(List<double> coordinates) {
    if (_pointAnnotationManager == null) return;

    // Create a red marker
    final options = mp.PointAnnotationOptions(
      geometry: mp.Point(
        coordinates: mp.Position(coordinates[1], coordinates[0]),
      ),
      textField: '📍', // Using emoji as marker
      textSize: 20.0,
      textColor: Colors.red.value,
    );

    _pointAnnotationManager!.create(options);
  }

  void _clearMarkers() {
    _pointAnnotationManager?.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            mp.MapWidget(
              key: const ValueKey("mapWidget"),
              onMapCreated: (mp.MapboxMap controller) {
                mapboxMapController = controller;
                _mapReady = true;

                // Enable location tracking
                mapboxMapController?.location.updateSettings(
                  mp.LocationComponentSettings(
                    enabled: true,
                    pulsingEnabled: true,
                  ),
                );

                // Initialize markers for current tab
                _updateMapMarkersForCurrentTab();

                if (_lastPosition != null) {
                  mapboxMapController?.setCamera(
                    mp.CameraOptions(
                      center: mp.Point(coordinates: _lastPosition!),
                      zoom: 15,
                    ),
                  );
                }

                if (_locationReady) {
                  setState(() {});
                }
              },
              styleUri: mp.MapboxStyles.LIGHT,
            ),
            if (!_mapReady || !_locationReady)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: MyColors.primaryColor,
                  ),
                ),
              ),
            // Add refresh indicator and back button
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _fetchOrders();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Refreshing orders...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Bottom sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _showBottomSheet
                        ? Container(
                          key: const ValueKey("visible"),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.45,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          child: RefreshIndicator(
                            onRefresh: () async {
                              await _fetchOrders();
                            },
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 12,
                                    bottom: 8,
                                  ),
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                // Tab bar
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildTab('ORDERS', 'orders'),
                                      _buildTab('REQUESTS', 'requests'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(child: _buildContent()),
                              ],
                            ),
                          ),
                        )
                        : GestureDetector(
                          key: const ValueKey("hidden"),
                          onTap: () {
                            setState(() {
                              _showBottomSheet = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white,
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

  Widget _buildTab(String title, String tabName) {
    final bool isActive = _activeTab == tabName;
    final int pendingCount = tabName == 'requests' ? pendingOrders.length : 0;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = tabName;
            _updateMapMarkersForCurrentTab();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow:
                isActive
                    ? const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.nunitoSans(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  color: isActive ? Colors.black87 : Colors.grey[600],
                ),
              ),
              if (tabName == 'requests' && pendingCount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    pendingCount.toString(),
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onMapCreated(mp.MapboxMap controller) {
    mapboxMapController = controller;
    _mapReady = true;

    mapboxMapController?.location.updateSettings(
      mp.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    if (_lastPosition != null) {
      mapboxMapController?.setCamera(
        mp.CameraOptions(
          center: mp.Point(coordinates: _lastPosition!),
          zoom: 15,
        ),
      );
    }

    if (_locationReady) {
      setState(() {});
    }
  }

  Future<void> _setupPositionTracking() async {
    bool serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    gl.LocationPermission permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        print("Location permission denied");
        return;
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }

    final position = await gl.Geolocator.getCurrentPosition();
    _lastPosition = mp.Position(position.longitude, position.latitude);

    // Reverse geocode to get address
    final address = await reverseGeocode(position.latitude, position.longitude);
    setState(() {
      currentAddress = address ?? "Unknown address";
      _locationReady = true;
    });

    if (_mapReady && mapboxMapController != null) {
      mapboxMapController?.setCamera(
        mp.CameraOptions(
          center: mp.Point(coordinates: _lastPosition!),
          zoom: 15,
        ),
      );
    }

    gl.LocationSettings locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 200,
    );

    userPositionStream?.cancel();
    userPositionStream = gl.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((gl.Position? position) async {
      if (position != null) {
        _lastPosition = mp.Position(position.longitude, position.latitude);
        if (mapboxMapController != null) {
          mapboxMapController?.setCamera(
            mp.CameraOptions(
              center: mp.Point(coordinates: _lastPosition!),
              zoom: 15,
            ),
          );
        }

        // Update address on movement (optional, comment if too frequent)
        final newAddress = await reverseGeocode(
          position.latitude,
          position.longitude,
        );
        if (newAddress != null && newAddress != currentAddress) {
          setState(() {
            currentAddress = newAddress;
          });
        }
      }
    });
  }

  Future<String?> reverseGeocode(double latitude, double longitude) async {
    if (mapboxAccessToken.isEmpty) {
      print('Error: Mapbox access token is not configured');
      return 'Configuration Error';
    }

    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json?access_token=$mapboxAccessToken&types=address,place,neighborhood,locality,district',
    );

    try {
      final response = await http.get(url).timeout(Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List<dynamic>;
        if (features.isNotEmpty) {
          // Get the most relevant result
          final feature = features[0];
          final placeName = feature['place_name'] as String;

          // If we got a meaningful address, return it
          if (placeName.isNotEmpty && !placeName.contains('undefined')) {
            return placeName;
          }

          // If the first result wasn't good, try to construct from context
          final context = feature['context'] as List<dynamic>?;
          if (context != null && context.isNotEmpty) {
            final addressParts =
                context.map((c) => c['text']).where((t) => t != null).toList();
            if (addressParts.isNotEmpty) {
              return addressParts.join(', ');
            }
          }
        }
        return 'Address not found';
      }
      return 'Service Error (${response.statusCode})';
    } catch (e) {
      print('Reverse geocoding failed: $e');
      return 'Network Error';
    }
  }

  Future<void> _getUserCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final token = prefs.getString('auth_token');

      if (userId != null && token != null) {
        setState(() {
          _userId = userId.toString();
          _userToken = token;
        });
        print(
          'Retrieved credentials - userId: $_userId, token available: ${_userToken != null}',
        );
      } else {
        print('No credentials found in SharedPreferences');
      }
    } catch (e) {
      print('Error getting user credentials: $e');
    }
  }

  Future<void> _onSeeOrdersPressed() async {
    await _getUserCredentials();
    if (_userId != null && _userToken != null) {
      await _connectWebSocket();
      _startLocationUpdates();
    } else {
      print('Cannot connect: missing user credentials');
    }
  }

  Future<void> _handleOrderResponse(String orderId, bool accept) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        throw Exception('Authentication required');
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(color: MyColors.primaryColor),
          );
        },
      );

      // First assign the delivery person if accepting
      if (accept) {
        final assignResponse = await http.put(
          Uri.parse('http://192.168.154.195:5050/commandes/$orderId/livreur'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'idLivreur': userId.toString()}),
        );

        if (assignResponse.statusCode != 200) {
          throw Exception('Failed to assign delivery person');
        }
      }

      // Update the order status
      final statusResponse = await http.put(
        Uri.parse('http://192.168.154.195:5050/commandes/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'statusCommande': accept ? 'Validée' : 'Refusée'}),
      );

      if (statusResponse.statusCode != 200) {
        throw Exception('Failed to update order status');
      }

      // Remove loading indicator
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Order accepted' : 'Order ignored'),
          backgroundColor: accept ? Colors.green : Colors.grey,
        ),
      );

      // Refresh orders list
      await _fetchOrders();
    } catch (e) {
      // Remove loading indicator
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    print('[_fetchOrders] Started fetching orders');
    print('[_fetchOrders] Using token: $_userToken');

    try {
      final response = await http.get(
        Uri.parse('http://192.168.154.195:5050/commandes'),
        headers: {'Authorization': 'Bearer $_userToken'},
      );

      print('[_fetchOrders] Response status code: ${response.statusCode}');
      print('[_fetchOrders] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['commandes'] as List<dynamic>;
        print('[_fetchOrders] Decoded ${data.length} orders from response');

        final List<Map<String, dynamic>> processedOrders = [];

        for (var order in data) {
          try {
            print('[_fetchOrders] Processing order ID: ${order['_id']}');

            // Skip orders that already have a delivery person assigned (except if it's assigned to current user)
            final assignedLivreur = order['idLivreur']?.toString() ?? '-';
            if (assignedLivreur != '-' && assignedLivreur != _userId) {
              continue;
            }

            final pickUpAddress =
                order['PickUpAddress'] as Map<String, dynamic>;
            final dropOffAddress =
                order['DropOffAddress'] as Map<String, dynamic>;

            // Convert coordinates to double, handling both int and double types
            final double pickUpLat =
                (pickUpAddress['latitude'] is int)
                    ? (pickUpAddress['latitude'] as int).toDouble()
                    : pickUpAddress['latitude'] as double;
            final double pickUpLng =
                (pickUpAddress['longitude'] is int)
                    ? (pickUpAddress['longitude'] as int).toDouble()
                    : pickUpAddress['longitude'] as double;
            final double dropOffLat =
                (dropOffAddress['latitude'] is int)
                    ? (dropOffAddress['latitude'] as int).toDouble()
                    : dropOffAddress['latitude'] as double;
            final double dropOffLng =
                (dropOffAddress['longitude'] is int)
                    ? (dropOffAddress['longitude'] as int).toDouble()
                    : dropOffAddress['longitude'] as double;

            print(
              '[_fetchOrders] Coordinates - Pickup: ($pickUpLat, $pickUpLng), DropOff: ($dropOffLat, $dropOffLng)',
            );

            final pickupAddressStr = await reverseGeocode(pickUpLat, pickUpLng);
            final dropOffAddressStr = await reverseGeocode(
              dropOffLat,
              dropOffLng,
            );

            print(
              '[_fetchOrders] Resolved addresses - Pickup: $pickupAddressStr, DropOff: $dropOffAddressStr',
            );

            final distance = _calculateDistance(
              pickUpLat,
              pickUpLng,
              dropOffLat,
              dropOffLng,
            );
            print(
              '[_fetchOrders] Calculated distance: ${distance.toStringAsFixed(1)}km',
            );

            // Get client ID or name
            String clientName = order['idClient'] ?? 'Unknown Client';
            final avatarText = clientName.substring(0, 2).toUpperCase();

            processedOrders.add({
              'id': order['_id'],
              'orderId': order['_id'],
              'clientName': clientName,
              'itemLocation': pickupAddressStr ?? 'Unknown Location',
              'deliveryLocation': dropOffAddressStr ?? 'Unknown Location',
              'status': order['statusCommande'],
              'type': order['Livraisontype'] ?? 'Standard',
              'distance': '${distance.toStringAsFixed(1)}km',
              'avatar':
                  'https://via.placeholder.com/40x40/4CAF50/FFFFFF?text=$avatarText',
              'isAssignedToMe': assignedLivreur == _userId,
            });
          } catch (e) {
            print('[_fetchOrders] Error processing order: $e');
            continue; // Skip this order and continue with the next one
          }
        }

        print(
          '[_fetchOrders] Finished processing orders. Total: ${processedOrders.length}',
        );
        setState(() {
          _orders = processedOrders;
          _isLoading = false;
        });

        // Update map markers with new orders
        _updateMapMarkersForCurrentTab();
      } else {
        print('[_fetchOrders] Error response status: ${response.statusCode}');
        setState(() {
          _error = 'Failed to load orders: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[_fetchOrders] Exception occurred: $e');
      setState(() {
        _error = 'Error loading orders: $e';
        _isLoading = false;
      });
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radius of the earth in km
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  List<Map<String, dynamic>> get pendingOrders {
    return _orders
        .where(
          (order) =>
              order['status'] == 'En cours' ||
              order['status'] == 'En attente' ||
              order['status'] == null,
        )
        .toList();
  }

  List<Map<String, dynamic>> get acceptedOrders {
    return _orders.where((order) => order['status'] == 'Validée').toList();
  }

  Widget _buildContent() {
    final items = _activeTab == 'orders' ? acceptedOrders : pendingOrders;

    if (items.isEmpty) {
      return Center(
        child: Text(
          _activeTab == 'orders' ? 'No orders yet' : 'No pending requests',
          style: GoogleFonts.nunitoSans(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildOrderCard(item, _activeTab == 'requests');
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isRequest) {
    // Extract order details
    final String orderType = order['type'] ?? 'Standard';
    final String distance = order['distance'] ?? '0km';
    final List<Widget> productWidgets = [];

    // Build product list if available
    if (order['produits'] != null) {
      for (var produit in order['produits']) {
        if (produit['produit'] != null) {
          final product = produit['produit'];
          final int quantity = produit['quantity'] ?? 1;
          productWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${product['nomProduit']} x$quantity',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${product['price']} DA',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MyColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MyColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: MyColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${distance}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isRequest ? Colors.blue[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isRequest ? Colors.blue : Colors.green,
                  ),
                ),
                child: Text(
                  orderType,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isRequest ? Colors.blue : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...productWidgets,
          const SizedBox(height: 16),
          _buildLocationItem(
            'Pickup Location',
            order['itemLocation'],
            Icons.location_on,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildLocationItem(
            'Delivery Location',
            order['deliveryLocation'],
            Icons.flag,
            Colors.red,
          ),
          const SizedBox(height: 16),
          if (!isRequest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green),
              ),
              child: Text(
                order['status'],
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      () => _handleOrderResponse(order['orderId'], false),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Ignore'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _handleOrderResponse(order['orderId'], true),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(
    String title,
    String address,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                address,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
