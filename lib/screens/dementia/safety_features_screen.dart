import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import '../../themes/minimalistic_theme.dart';

class SafetyFeaturesScreen extends StatefulWidget {
  const SafetyFeaturesScreen({super.key});

  @override
  State<SafetyFeaturesScreen> createState() => _SafetyFeaturesScreenState();
}

class _SafetyFeaturesScreenState extends State<SafetyFeaturesScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  LatLng? _safeZoneCenter;
  double _safeZoneRadius = 500; // meters
  Set<Circle> _circles = {};
  Set<Marker> _markers = {};
  bool _isLocationEnabled = false;
  bool _isGeofenceActive = false;
  String _currentAddress = 'Getting location...';
  Timer? _locationTimer;
  List<String> _caretakers = [];
  bool _isInsideSafeZone = true;
  DateTime? _lastAlertTime;
  
  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadSettings();
  }
  
  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    await _requestLocationPermission();
    await _getCurrentLocation();
    _startLocationTracking();
  }
  
  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog();
      return;
    }
    
    setState(() {
      _isLocationEnabled = permission == LocationPermission.whileInUse || 
                          permission == LocationPermission.always;
    });
  }
  
  Future<void> _getCurrentLocation() async {
    if (!_isLocationEnabled) return;
    
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
      });
      
      await _getAddressFromCoordinates(position.latitude, position.longitude);
      _updateMapLocation();
    } catch (e) {
      print('Error getting location: $e');
    }
  }
  
  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }
  
  void _updateMapLocation() {
    if (_currentPosition != null) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Current Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
      
      if (_safeZoneCenter != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('safe_zone_center'),
            position: _safeZoneCenter!,
            infoWindow: const InfoWindow(title: 'Safe Zone Center'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
        
        _circles.clear();
        _circles.add(
          Circle(
            circleId: const CircleId('safe_zone'),
            center: _safeZoneCenter!,
            radius: _safeZoneRadius,
            fillColor: Colors.green.withOpacity(0.2),
            strokeColor: Colors.green,
            strokeWidth: 2,
          ),
        );
      }
      
      setState(() {});
    }
  }
  
  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _checkLocationAndGeofence();
    });
  }
  
  Future<void> _checkLocationAndGeofence() async {
    if (!_isLocationEnabled || !_isGeofenceActive || _safeZoneCenter == null) return;
    
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
      
      // Calculate distance from safe zone center
      double distance = Geolocator.distanceBetween(
        _safeZoneCenter!.latitude,
        _safeZoneCenter!.longitude,
        position.latitude,
        position.longitude,
      );
      
      bool wasInside = _isInsideSafeZone;
      _isInsideSafeZone = distance <= _safeZoneRadius;
      
      if (distance > _safeZoneRadius && wasInside) {
        // User just left the safe zone
        _triggerGeofenceAlert(position, distance);
      }
      
      _updateMapLocation();
    } catch (e) {
      print('Error checking location: $e');
    }
  }
  
  void _triggerGeofenceAlert(Position position, double distance) {
    // Prevent spam alerts - only send if it's been more than 5 minutes since last alert
    if (_lastAlertTime != null && 
        DateTime.now().difference(_lastAlertTime!).inMinutes < 5) {
      return;
    }
    
    _lastAlertTime = DateTime.now();
    
    // Send alert to caretakers
    _sendAlertToCaretakers(position, distance);
    
    // Show local notification
    _showLocalAlert(position, distance);
  }
  
  void _sendAlertToCaretakers(Position position, double distance) {
    // In a real app, this would send notifications to caretakers
    // via push notifications, SMS, or email
    _sendNotificationToCaretakers(position, distance);

    print('ALERT: User has left safe zone!');
    print('Current location: ${position.latitude}, ${position.longitude}');
    print('Distance from safe zone: ${distance.toStringAsFixed(0)} meters');

    // Show alert to caretakers (simulate)
    for (String caretaker in _caretakers) {
      print('Sending alert to: $caretaker');
    }
  }
  
  void _sendNotificationToCaretakers(Position position, double distance) {
    // This would be implemented with Firebase Cloud Messaging, email service, or SMS service
    final String alertMessage = 'SAFETY ALERT: User has left the safe zone!\n'
        'Current location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}\n'
        'Distance from safe zone: ${distance.toStringAsFixed(0)} meters';
    
    // Simulate sending notifications to each caretaker
    for (String caretaker in _caretakers) {
      // In a real implementation, you would:
      // 1. Send push notification via FCM
      // 2. Send email via a service like SendGrid or AWS SES
      // 3. Send SMS via a service like Twilio
      print('Notification sent to $caretaker: $alertMessage');
    }
  }
  
  void _showLocalAlert(Position position, double distance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Safety Alert'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have moved outside your safe zone by ${(distance - _safeZoneRadius).toStringAsFixed(0)} meters.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your caretakers have been notified of your location.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _callEmergency();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Call Help', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _setSafeZone() {
    if (_currentPosition != null) {
      setState(() {
        _safeZoneCenter = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
        _isGeofenceActive = true;
      });
      _updateMapLocation();
      _saveSettings();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Safe zone set at current location'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _callEmergency() {
    // In a real app, this would dial emergency services
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Call'),
        content: const Text('This will call emergency services. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would use url_launcher to dial emergency number
              // launch('tel:911'); // or appropriate emergency number
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency services contacted!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Call Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location permission to provide safety features. Please enable location access in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    double? lat = prefs.getDouble('safe_zone_lat');
    double? lng = prefs.getDouble('safe_zone_lng');
    
    if (lat != null && lng != null) {
      setState(() {
        _safeZoneCenter = LatLng(lat, lng);
        _safeZoneRadius = prefs.getDouble('safe_zone_radius') ?? 500;
        _isGeofenceActive = prefs.getBool('geofence_active') ?? false;
        _caretakers = prefs.getStringList('caretakers') ?? [];
      });
    }
  }
  
  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (_safeZoneCenter != null) {
      await prefs.setDouble('safe_zone_lat', _safeZoneCenter!.latitude);
      await prefs.setDouble('safe_zone_lng', _safeZoneCenter!.longitude);
    }
    
    await prefs.setDouble('safe_zone_radius', _safeZoneRadius);
    await prefs.setBool('geofence_active', _isGeofenceActive);
    await prefs.setStringList('caretakers', _caretakers);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Safety Features',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Location Status Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLocationEnabled ? Icons.location_on : Icons.location_off,
                          color: _isLocationEnabled ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location Status',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _isLocationEnabled ? 'Active' : 'Disabled',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: _isLocationEnabled ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_isLocationEnabled) ...[
                      const SizedBox(height: 12),
                      Text(
                        _currentAddress,
                        style: GoogleFonts.inter(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      if (_safeZoneCenter != null && _isGeofenceActive) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isInsideSafeZone ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isInsideSafeZone ? Icons.shield : Icons.warning,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isInsideSafeZone ? 'Inside Safe Zone' : 'Outside Safe Zone',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              
              // Map Container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _currentPosition != null
                        ? _buildMapWidget()
                        : Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                  ),
                ),
              ),
              
              // Control Buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLocationEnabled ? _setSafeZone : null,
                            icon: const Icon(Icons.add_location),
                            label: const Text('Set Safe Zone'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isGeofenceActive = !_isGeofenceActive;
                              });
                              _saveSettings();
                            },
                            icon: Icon(_isGeofenceActive ? Icons.pause : Icons.play_arrow),
                            label: Text(_isGeofenceActive ? 'Pause Alert' : 'Start Alert'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isGeofenceActive ? Colors.orange : Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _callEmergency,
                        icon: const Icon(Icons.emergency),
                        label: const Text('Emergency Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMapWidget() {
    try {
      return GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 15,
        ),
        markers: _markers,
        circles: _circles,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onTap: _onMapTap,
      );
    } catch (e) {
      // Handle API key or other map-related errors
      return Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Map Unavailable',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Google Maps API key is required for location features. Please see SETUP_GUIDE.md for configuration instructions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Location:\n${_currentAddress}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }
  
  void _onMapTap(LatLng location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Safe Zone Here?'),
        content: Text(
          'Do you want to set the safe zone at this location?\n\nLatitude: ${location.latitude.toStringAsFixed(6)}\nLongitude: ${location.longitude.toStringAsFixed(6)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _safeZoneCenter = location;
                _isGeofenceActive = true;
              });
              _updateMapLocation();
              _saveSettings();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Safe zone set at selected location'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Set Here'),
          ),
        ],
      ),
    );
  }
  
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Safety Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Safe Zone Radius: ${_safeZoneRadius.toInt()} meters'),
            Slider(
              value: _safeZoneRadius,
              min: 100,
              max: 2000,
              divisions: 19,
              label: '${_safeZoneRadius.toInt()}m',
              onChanged: (value) {
                setState(() {
                  _safeZoneRadius = value;
                });
                _updateMapLocation();
              },
            ),
            const SizedBox(height: 16),
            if (_safeZoneCenter != null) ...[
              Row(
                children: [
                  Icon(
                    _isGeofenceActive ? Icons.notifications_active : Icons.notifications_off,
                    color: _isGeofenceActive ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Geofence Alert: ${_isGeofenceActive ? 'Active' : 'Inactive'}',
                    style: TextStyle(
                      color: _isGeofenceActive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Caretakers: ${_caretakers.length}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _showCaretakerDialog,
              child: const Text('Manage Caretakers'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveSettings();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showCaretakerDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Caretaker Contacts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._caretakers.map((caretaker) => ListTile(
              title: Text(caretaker),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _caretakers.remove(caretaker);
                  });
                  Navigator.pop(context);
                  _showCaretakerDialog();
                },
              ),
            )),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Add caretaker contact',
                hintText: 'Email or phone number',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _caretakers.add(controller.text);
                });
                controller.clear();
                Navigator.pop(context);
                _showCaretakerDialog();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
