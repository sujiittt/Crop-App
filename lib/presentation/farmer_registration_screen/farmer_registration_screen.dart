import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/agricultural_details_section.dart';
import './widgets/location_section.dart';
import './widgets/personal_details_section.dart';
import './widgets/progress_indicator_widget.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  const FarmerRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<FarmerRegistrationScreen> createState() =>
      _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic> _registrationData = {
    'personalDetails': <String, dynamic>{},
    'agriculturalDetails': <String, dynamic>{},
    'locationDetails': <String, dynamic>{},
  };

  /// Post-frame safe setState to avoid "setState during build" when children
  /// fire onDataChanged immediately on first build.
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  /// Recursively normalize any decoded JSON (LinkedHashMap / dynamic lists)
  /// into typed Map<String,dynamic> / List<dynamic>.
  dynamic _normalizeTree(dynamic value) {
    if (value is Map) {
      final m = <String, dynamic>{};
      value.forEach((k, v) {
        m[k.toString()] = _normalizeTree(v);
      });
      return m;
    }
    if (value is List) {
      return value.map(_normalizeTree).toList();
    }
    return value;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('farmer_registration_data');

      if (savedData != null) {
        final decoded = json.decode(savedData);
        final normalized = _normalizeTree(decoded) as Map<String, dynamic>;
        _safeSetState(() {
          _registrationData = normalized;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'farmer_registration_data',
        json.encode(_registrationData),
      );
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  void _updatePersonalDetails(Map<String, dynamic> data) {
    _safeSetState(() {
      _registrationData['personalDetails'] = _normalizeTree(data) as Map<String, dynamic>;
    });
    _saveData();
  }

  void _updateAgriculturalDetails(Map<String, dynamic> data) {
    _safeSetState(() {
      _registrationData['agriculturalDetails'] = _normalizeTree(data) as Map<String, dynamic>;
    });
    _saveData();
  }

  void _updateLocationDetails(Map<String, dynamic> data) {
    _safeSetState(() {
      _registrationData['locationDetails'] = _normalizeTree(data) as Map<String, dynamic>;
    });
    _saveData();
  }
  // === STEP CALCULATORS (add inside _FarmerRegistrationScreenState) ===

  bool get _isStep1Complete {
    final p = (_registrationData['personalDetails'] as Map<String, dynamic>? ) ?? {};
    final nameOk  = (p['name'] as String?)?.trim().isNotEmpty == true;
    final phoneOk = (p['phone'] as String?)?.length == 10;
    final otpOk   = p['phoneVerified'] == true;
    return nameOk && phoneOk && otpOk;
  }

  bool get _isStep2Complete {
    final a = (_registrationData['agriculturalDetails'] as Map<String, dynamic>? ) ?? {};
    final farmSizeOk = a['farmSize'] != null;
    final crops = (a['primaryCrops'] as List?) ?? const [];
    final cropsOk = crops.isNotEmpty;
    return farmSizeOk && cropsOk;
  }

  bool get _isStep3Started {
    final l = (_registrationData['locationDetails'] as Map<String, dynamic>? ) ?? {};
    final hasAddress = ((l['address'] as String?)?.trim().isNotEmpty == true) ||
        ((l['pincode'] as String?)?.trim().isNotEmpty == true);
    final hasGps = l['latitude'] != null && l['longitude'] != null;
    return hasAddress || hasGps;
  }

  int get _currentStepNumber {
    if (!_isStep1Complete) return 1;
    if (!_isStep2Complete) return 2;
    return 3; // step 3 when user started/filled any location info
  }


  bool _validateForm() {
    final personalDetails =
        _registrationData['personalDetails'] as Map<String, dynamic>? ?? {};
    final agriculturalDetails =
        _registrationData['agriculturalDetails'] as Map<String, dynamic>? ?? {};

    // Validate personal details
    if (personalDetails['name'] == null ||
        (personalDetails['name'] as String).trim().isEmpty) {
      _showValidationError('Please enter your full name');
      return false;
    }

    if (personalDetails['phone'] == null ||
        (personalDetails['phone'] as String).length != 10) {
      _showValidationError('Please enter a valid 10-digit phone number');
      return false;
    }

    if (personalDetails['phoneVerified'] != true) {
      _showValidationError('Please verify your phone number with OTP');
      return false;
    }

    // Validate agricultural details
    if (agriculturalDetails['farmSize'] == null) {
      _showValidationError('Please select your farm size');
      return false;
    }

    final primaryCrops =
        agriculturalDetails['primaryCrops'] as List<dynamic>? ?? [];
    if (primaryCrops.isEmpty) {
      _showValidationError('Please select at least one primary crop');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _scrollToError() {
    // Schedule after frame so we don't animate during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _continueToNextStep() {
    if (_validateForm()) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 2.w),
              const Text('Registration data saved successfully!'),
            ],
          ),
          backgroundColor: AppTheme.getSuccessColor(true),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
        ),
      );

      // Navigate to dashboard after a short delay, post-frame safe.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          }
        });
      });
    } else {
      _scrollToError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Farmer Registration'),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Registration Help'),
                  content: const Text(
                    'Fill in your personal details, agricultural information, and location to get personalized crop recommendations and access to government schemes.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            ProgressIndicatorWidget(
              currentStep: _currentStepNumber,
              totalSteps: 3,
              stepLabels: const ['Registration', 'Land Details', 'Verification'],
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // Welcome Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightTheme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            AppTheme.lightTheme.primaryColor.withValues(
                              alpha: 0.05,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.lightTheme.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'agriculture',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 48,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Welcome to CropWise',
                            style: AppTheme.lightTheme.textTheme.headlineSmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Let\'s set up your farmer profile to provide personalized crop recommendations and connect you with relevant government schemes.',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Personal Details Section
                    PersonalDetailsSection(
                      onDataChanged: _updatePersonalDetails,
                      initialData: (_registrationData['personalDetails']
                      as Map<String, dynamic>?) ??
                          <String, dynamic>{},
                    ),

                    // Agricultural Details Section
                    AgriculturalDetailsSection(
                      onDataChanged: _updateAgriculturalDetails,
                      initialData: (_registrationData['agriculturalDetails']
                      as Map<String, dynamic>?) ??
                          <String, dynamic>{},
                    ),

                    // Location Section
                    LocationSection(
                      onDataChanged: _updateLocationDetails,
                      initialData: (_registrationData['locationDetails']
                      as Map<String, dynamic>?) ??
                          <String, dynamic>{},
                    ),

                    SizedBox(height: 10.h), // Space for sticky button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Sticky Continue Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress Summary
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Complete all required fields to continue',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _continueToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                    foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to Land Details',
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'arrow_forward',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
