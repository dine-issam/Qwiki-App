import 'dart:async';
import 'dart:convert';

import 'package:delivery_app/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  mp.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  bool _locationReady = false;
  bool _mapReady = false;
  mp.Position? _lastPosition;
  bool _showBottomSheet = true;

  String currentAddress = "Loading address...";

  // Get access token from environment variables
  final String mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupPositionTracking();
    });
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            mp.MapWidget(
              onMapCreated: _onMapCreated,
              styleUri: mp.MapboxStyles.SATELLITE,
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
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _showBottomSheet
                        ? Container(
                          key: const ValueKey("visible"),
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Colors.white, Colors.greenAccent],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: IconButton(
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  onPressed: () {
                                    setState(() {
                                      _showBottomSheet = false;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                "Select Location",
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  currentAddress,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context, {
                                      'address': currentAddress,
                                      'latitude': _lastPosition?.lat ?? 0.0,
                                      'longitude': _lastPosition?.lng ?? 0.0,
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.location_pin),
                                  label: Text(
                                    "Confirm",
                                    style: GoogleFonts.nunitoSans(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
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
      final response = await http.get(url);
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
}
