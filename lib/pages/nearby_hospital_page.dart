import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';

class NearbyHospitalPage extends StatefulWidget {
  const NearbyHospitalPage({super.key});

  @override
  State<NearbyHospitalPage> createState() => _NearbyHospitalPageState();
}

class _NearbyHospitalPageState extends State<NearbyHospitalPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  Position? _currentPosition;
  String? _error;
  bool _isLoading = true;
  LatLng? _pendingCameraTarget;
  bool _isFetchingHospitals = false;
  final Set<Marker> _hospitalMarkers = {};

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(23.8103, 90.4125), // Dhaka as placeholder
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _error = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _error = 'Location permission denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _error =
              'Location permission permanently denied. Please enable it in settings.';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      final target = LatLng(position.latitude, position.longitude);
      if (_mapController.isCompleted) {
        final controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 15),
          ),
        );
      } else {
        _pendingCameraTarget = target;
      }

      await _fetchNearbyHospitals(position);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'You are here'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );

      // Placeholder hospitals; replace with real Places API in future
      markers.addAll(_hospitalMarkers);
    }
    return markers;
  }

  Future<void> _fetchNearbyHospitals(Position position) async {
    if (_isFetchingHospitals) return;
    setState(() {
      _isFetchingHospitals = true;
    });

    final url =
        Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json'
            '?location=${position.latitude},${position.longitude}'
            '&radius=4000'
            '&type=hospital'
            '&key=${AppConstants.googleMapsApiKey}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          final markers = results.take(20).map((place) {
            final geometry = place['geometry']['location'];
            final lat = (geometry['lat'] as num).toDouble();
            final lng = (geometry['lng'] as num).toDouble();
            final name = place['name'] as String? ?? 'Hospital';
            final vicinity = place['vicinity'] as String?;
            final rating = place['rating']?.toString();
            final snippetBuffer = StringBuffer();
            if (vicinity != null) snippetBuffer.write(vicinity);
            if (rating != null) {
              if (snippetBuffer.isNotEmpty) snippetBuffer.write(' • ');
              snippetBuffer.write('Rating: $rating');
            }

            return Marker(
              markerId: MarkerId(place['place_id'] as String? ?? name),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: name,
                snippet:
                    snippetBuffer.isEmpty ? null : snippetBuffer.toString(),
              ),
            );
          }).toSet();

          if (!mounted) return;
          setState(() {
            _hospitalMarkers
              ..clear()
              ..addAll(markers);
          });
        } else {
          if (!mounted) return;
          setState(() {
            _error = 'Google Places error: ${data['status']}';
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Failed to fetch hospitals (HTTP ${response.statusCode})';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error fetching hospitals: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingHospitals = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _determinePosition,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: _currentPosition != null
                      ? CameraPosition(
                          target: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          zoom: 15,
                        )
                      : _defaultPosition,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) async {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(controller);
                    }
                    if (_pendingCameraTarget != null) {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: _pendingCameraTarget!, zoom: 15),
                        ),
                      );
                      _pendingCameraTarget = null;
                    }
                  },
                  markers: _buildMarkers(),
                ),
    );
  }
}
