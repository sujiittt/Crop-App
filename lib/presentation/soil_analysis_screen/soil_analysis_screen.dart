import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/analysis_loading_widget.dart';
import './widgets/camera_capture_widget.dart';
import './widgets/location_section_widget.dart';
import './widgets/manual_input_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/soil_testing_options_widget.dart';
import './widgets/visual_assessment_widget.dart';
import 'package:cropwise/widgets/profile_action_icon.dart';

class SoilAnalysisScreen extends StatefulWidget {
  const SoilAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<SoilAnalysisScreen> createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  int _currentStep = 1;
  final int _totalSteps = 4;
  String _selectedAnalysisMethod = '';
  Map<String, dynamic> _soilData = {};
  bool _isAnalyzing = false;
  XFile? _capturedSoilImage;

  // ===== Voice placeholders (no plugin dependency) =====
  // We keep these flags so the UI looks the same, but there is no speech engine behind it.
  bool _isListening = false;
  String _lastTranscript = '';
  bool get _speechAvailable => false; // force disabled until plugin is added back

  // Mock location data
  final Map<String, dynamic> _locationData = {
    'coordinates': '28.6139° N, 77.2090° E',
    'address': 'Sector 15, Gurugram, Haryana, India',
    'accuracy': '±5 meters',
  };

  // ---- SAFE setState: schedule after current frame to avoid mid-build updates
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  @override
  void initState() {
    super.initState();
    // No speech plugin to initialize
  }

  @override
  void dispose() {
    // No speech engine to stop
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: _isAnalyzing ? _buildAnalyzingView() : _buildMainContent(),
      bottomNavigationBar: _isAnalyzing ? null : _buildBottomButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Analyze Soil'),
      centerTitle: true,
      automaticallyImplyLeading: false, // hides the back arrow
      actions: [
        Container(
          margin: EdgeInsets.only(right: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.getSuccessColor(true),
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                'GPS Active',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.getSuccessColor(true),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const ProfileActionIcon(),
      ],
    );
  }

  Widget _buildMainContent() {
    // Wrap content in a Stack so we can float the voice mic button
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProgressIndicatorWidget(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                ),
                SizedBox(height: 3.h),
                _buildStepContent(),
                SizedBox(height: 10.h), // breathing room under the mic FAB
              ],
            ),
          ),

          // Mic button visible on step 2 & 3, but disabled (no plugin)
          if (!_isAnalyzing && (_currentStep == 2 || _currentStep == 3))
            Positioned(
              right: 16,
              bottom: 16,
              child: _VoiceMicButton(
                isListening: _isListening,
                lastTranscript: _lastTranscript,
                enabled: _speechAvailable, // always false now
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voice input not available. Add speech_to_text to enable.'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildLocationStep();
      case 2:
        return _buildAnalysisMethodStep();
      case 3:
        return _buildDataInputStep();
      case 4:
        return _buildCameraStep();
      default:
        return _buildLocationStep();
    }
  }

  Widget _buildLocationStep() {
    return LocationSectionWidget(
      currentLocation: _locationData['address'],
      accuracy: _locationData['accuracy'],
      onUseCurrentLocation: () {
        _safeSetState(() => _currentStep = 2);
      },
      onUseDifferentLocation: () {
        _showLocationPicker();
      },
    );
  }

  Widget _buildAnalysisMethodStep() {
    return SoilTestingOptionsWidget(
      onManualInput: () {
        _safeSetState(() {
          _selectedAnalysisMethod = 'manual';
          _currentStep = 3;
        });
      },
      onVisualAssessment: () {
        _safeSetState(() {
          _selectedAnalysisMethod = 'visual';
          _currentStep = 3;
        });
      },
    );
  }

  Widget _buildDataInputStep() {
    if (_selectedAnalysisMethod == 'manual') {
      return ManualInputWidget(
        onValuesChanged: (values) {
          _safeSetState(() => _soilData = values);
        },
      );
    } else {
      return VisualAssessmentWidget(
        onAssessmentChanged: (assessment) {
          _safeSetState(() => _soilData = assessment);
        },
      );
    }
  }

  Widget _buildCameraStep() {
    return CameraCaptureWidget(
      onImageCaptured: (image) {
        _safeSetState(() => _capturedSoilImage = image);
      },
    );
  }

  Widget _buildAnalyzingView() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: AnalysisLoadingWidget(
            onComplete: _onAnalysisComplete,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _currentStep < _totalSteps
            ? Row(
          children: [
            if (_currentStep > 1)
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    _safeSetState(() => _currentStep--);
                  },
                  child: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                ),
              ),
            if (_currentStep > 1) SizedBox(width: 3.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _canProceed()
                    ? () => _safeSetState(() {
                  if (_currentStep < _totalSteps) _currentStep++;
                })
                    : null,
                child: Text(_getButtonText()),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          ],
        )
            : ElevatedButton(
          onPressed: _canAnalyze() ? _startAnalysis : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'analytics',
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 2.w),
              const Text('Analyze Soil'),
            ],
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 2.h),
          ),
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 1:
        return true;
      case 2:
        return _selectedAnalysisMethod.isNotEmpty;
      case 3:
        return _soilData.isNotEmpty;
      default:
        return false;
    }
  }

  bool _canAnalyze() {
    return _soilData.isNotEmpty;
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 1:
        return 'Continue';
      case 2:
        return 'Next Step';
      case 3:
        return 'Add Photo (Optional)';
      default:
        return 'Next';
    }
  }

  void _startAnalysis() {
    setState(() => _isAnalyzing = true);
  }

  void _onAnalysisComplete() {
    Navigator.pushNamed(context, '/crop-recommendations-screen');
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 2.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Location',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'map',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 48,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Interactive Map',
                            style: AppTheme.lightTheme.textTheme.titleMedium,
                          ),
                          Text(
                            'Tap to select your field location',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _safeSetState(() => _currentStep = 2);
                    },
                    child: const Text('Use Selected Location'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 6.h),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Small reusable mic FAB (kept for UI parity; disabled until speech plugin added)
class _VoiceMicButton extends StatelessWidget {
  final bool isListening;
  final String lastTranscript;
  final bool enabled;
  final VoidCallback onTap;

  const _VoiceMicButton({
    required this.isListening,
    required this.lastTranscript,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'soil-voice-mic',
      onPressed: enabled ? onTap : null,
      backgroundColor:
      isListening ? Colors.redAccent : Theme.of(context).colorScheme.tertiary,
      foregroundColor: Colors.black,
      icon: Icon(isListening ? Icons.stop : Icons.mic_none),
      label: Text(
        isListening ? 'Stop' : (enabled ? 'Voice' : 'Voice N/A'),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
