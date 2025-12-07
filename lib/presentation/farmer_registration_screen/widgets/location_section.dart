import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LocationSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> initialData;

  const LocationSection({
    Key? key,
    required this.onDataChanged,
    required this.initialData,
  }) : super(key: key);

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String? _locationAccuracy;

  // ✅ Normalize any dynamic/LinkedMap to typed Map<String,dynamic>
  Map<String, dynamic> _norm(dynamic raw) =>
      raw == null ? <String, dynamic>{} : Map<String, dynamic>.from(raw as Map);

  @override
  void initState() {
    super.initState();

    // ✅ Normalized initial data prevents LinkedMap type errors
    final init = _norm(widget.initialData);

    _addressController.text = (init['address'] as String?) ?? '';
    _cityController.text = (init['city'] as String?) ?? '';
    _stateController.text = (init['state'] as String?) ?? '';
    _pincodeController.text = (init['pincode'] as String?) ?? '';

    final lat = (init['latitude'] as num?)?.toDouble();
    final lng = (init['longitude'] as num?)?.toDouble();
    final acc = (init['accuracy'] as num?)?.toDouble() ?? 0.0;

    if (lat != null && lng != null) {
      // Geolocator's Position requires all fields; provide safe defaults.
      _currentPosition = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: acc,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
      _updateLocationAccuracy();
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<bool> _requestLocationPermission() async {
    // On web, Geolocator handles prompts in the browser; skip PermissionHandler.
    if (kIsWeb) return true;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      if (!await _requestLocationPermission()) {
        // make sure to turn loading OFF before leaving
        setState(() => _isLoadingLocation = false);
        _showLocationPermissionDialog();
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        _showLocationServiceDialog();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });

      _updateLocationAccuracy();
      _updateData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location captured successfully'),
          backgroundColor: AppTheme.getSuccessColor(true),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to get location. Please try again.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _updateLocationAccuracy() {
    if (_currentPosition != null) {
      final accuracy = _currentPosition!.accuracy;
      if (accuracy <= 10) {
        _locationAccuracy = 'High (${accuracy.toStringAsFixed(1)}m)';
      } else if (accuracy <= 50) {
        _locationAccuracy = 'Medium (${accuracy.toStringAsFixed(1)}m)';
      } else {
        _locationAccuracy = 'Low (${accuracy.toStringAsFixed(1)}m)';
      }
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location access to provide accurate soil data and crop recommendations for your area.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable location services to use GPS functionality.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _updateData() {
    final data = {
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'pincode': _pincodeController.text,
      'latitude': _currentPosition?.latitude,
      'longitude': _currentPosition?.longitude,
      'accuracy': _currentPosition?.accuracy,
    };
    widget.onDataChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Location Details',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // GPS Location Section
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _currentPosition != null
                    ? AppTheme.getSuccessColor(true).withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _currentPosition != null
                      ? AppTheme.getSuccessColor(true)
                      : AppTheme.lightTheme.dividerColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'gps_fixed',
                        color: _currentPosition != null
                            ? AppTheme.getSuccessColor(true)
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'GPS Location',
                        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: _currentPosition != null
                              ? AppTheme.getSuccessColor(true)
                              : AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),

                  if (_currentPosition != null) ...[
                    Text(
                      'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    Text(
                      'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'my_location',
                          color: AppTheme.getSuccessColor(true),
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Accuracy: $_locationAccuracy',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.getSuccessColor(true),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'GPS location helps provide accurate soil data for your area',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ],

                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                      icon: _isLoadingLocation
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : CustomIconWidget(
                        iconName: _currentPosition != null ? 'refresh' : 'my_location',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      label: Text(
                        _isLoadingLocation
                            ? 'Getting Location...'
                            : _currentPosition != null
                            ? 'Update Location'
                            : 'Use Current Location',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPosition != null
                            ? AppTheme.getSuccessColor(true)
                            : AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Manual Address Section
            Text(
              'Manual Address (Optional)',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                hintText: 'Enter your complete address',
                prefixIcon: Icon(Icons.home_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              maxLines: 2,
              onChanged: (_) => _updateData(),
            ),
            SizedBox(height: 2.h),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      hintText: 'Enter city',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _updateData(),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      hintText: 'Enter state',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _updateData(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            TextFormField(
              controller: _pincodeController,
              decoration: const InputDecoration(
                labelText: 'Pincode',
                hintText: 'Enter 6-digit pincode',
                prefixIcon: Icon(Icons.pin_drop_outlined),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (_) => _updateData(),
            ),
          ],
        ),
      ),
    );
  }
}
