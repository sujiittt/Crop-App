import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PersonalDetailsSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> initialData;

  const PersonalDetailsSection({
    Key? key,
    required this.onDataChanged,
    required this.initialData,
  }) : super(key: key);

  @override
  State<PersonalDetailsSection> createState() => _PersonalDetailsSectionState();
}

class _PersonalDetailsSectionState extends State<PersonalDetailsSection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  XFile? _capturedImage;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isCameraInitialized = false;
  bool _showCamera = false;

  // ✅ Normalize any dynamic/LinkedMap into a typed Map<String,dynamic>
  Map<String, dynamic> _norm(dynamic raw) =>
      raw == null ? <String, dynamic>{} : Map<String, dynamic>.from(raw as Map);

  @override
  void initState() {
    super.initState();

    // ✅ Normalize once; prevents "LinkedMap ... is not a subtype of Map<String, dynamic>" crashes
    final init = _norm(widget.initialData);

    _nameController.text = (init['name'] as String?) ?? '';
    _phoneController.text = (init['phone'] as String?) ?? '';
    _isOtpVerified = (init['phoneVerified'] as bool?) ?? false;

    // If a previously saved image path exists, keep it (optional, harmless if absent)
    final imgPath = init['profileImage'] as String?;
    if (imgPath != null && imgPath.isNotEmpty) {
      _capturedImage = XFile(imgPath);
    }

    _initializeCamera();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) return;

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      )
          : _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      debugPrint('Focus mode error: $e');
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        debugPrint('Flash mode error: $e');
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
        _showCamera = false;
      });
      _updateData();
    } catch (e) {
      debugPrint('Photo capture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        _updateData();
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  void _sendOtp() {
    if (_phoneController.text.length == 10) {
      setState(() {
        _isOtpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to ${_phoneController.text}'),
          backgroundColor: AppTheme.getSuccessColor(true),
        ),
      );
    }
  }

  void _verifyOtp() {
    if (_otpController.text == '123456') {
      setState(() {
        _isOtpVerified = true;
      });
      _updateData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Phone number verified successfully'),
          backgroundColor: AppTheme.getSuccessColor(true),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid OTP. Please try again.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _updateData() {
    final data = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'phoneVerified': _isOtpVerified,
      'profileImage': _capturedImage?.path,
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
                  iconName: 'person',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Personal Details',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Full Name',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => _updateData(),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Phone + Send OTP
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Phone Number',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          hintText: 'Enter 10-digit number',
                          prefixIcon: Icon(Icons.phone_outlined),
                          prefixText: '+91 ',
                        ),
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        onChanged: (_) {
                          _updateData();
                          if (_phoneController.text.length == 10 && !_isOtpSent) {
                            setState(() {}); // enables the Send OTP button
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      flex: 1,
                      child: _isOtpVerified
                          ? Container(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.getSuccessColor(true)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified,
                              color: AppTheme.getSuccessColor(true),
                              size: 20,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: AppTheme.getSuccessColor(true),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                          : ElevatedButton(
                        onPressed: _phoneController.text.length == 10
                            ? _sendOtp
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                        child: Text(
                          _isOtpSent ? 'Sent' : 'Send OTP',
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // OTP
            if (_isOtpSent && !_isOtpVerified) ...[
              SizedBox(height: 2.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter OTP',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _otpController,
                          decoration: const InputDecoration(
                            hintText: 'Enter 6-digit OTP',
                            prefixIcon: Icon(Icons.security),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: _otpController.text.length == 6
                              ? _verifyOtp
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          ),
                          child: Text('Verify', style: TextStyle(fontSize: 10.sp)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],

            SizedBox(height: 3.h),

            // Profile Photo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Photo',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                SizedBox(height: 1.h),
                if (_showCamera && _isCameraInitialized) ...[
                  Container(
                    height: 40.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.lightTheme.dividerColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _capturePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Capture'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _showCamera = false),
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    height: 20.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.dividerColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _capturedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.network(
                        _capturedImage!.path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                          : CustomImageWidget(
                        imageUrl: _capturedImage!.path,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'add_a_photo',
                          color: AppTheme.lightTheme.colorScheme
                              .onSurfaceVariant,
                          size: 48,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Add Profile Photo',
                          style: AppTheme
                              .lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isCameraInitialized
                              ? () => setState(() => _showCamera = true)
                              : null,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
