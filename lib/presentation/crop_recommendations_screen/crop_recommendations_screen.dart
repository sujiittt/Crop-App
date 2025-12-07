import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/crop_card_widget.dart';
import './widgets/crop_detail_modal_widget.dart';
import './widgets/explanation_section_widget.dart';
import './widgets/filter_chips_widget.dart';
import 'package:cropwise/widgets/profile_action_icon.dart';
import 'package:cropwise/navigation/nav_helpers.dart'; // for goToMainTab(...)



class CropRecommendationsScreen extends StatefulWidget {
  const CropRecommendationsScreen({Key? key}) : super(key: key);

  @override
  State<CropRecommendationsScreen> createState() =>
      _CropRecommendationsScreenState();
}

class _CropRecommendationsScreenState extends State<CropRecommendationsScreen> {
  String _selectedFilter = 'yield';
  bool _isRefreshing = false;
  bool _isCompareMode = false;
  List<String> _selectedCropsForComparison = [];

  // Mock data for crop recommendations
  final List<Map<String, dynamic>> _cropRecommendations = [
    {
      "id": 1,
      "name": "Rice (Basmati)",
      "localName": "बासमती चावल",
      "suitabilityScore": 92,
      "expectedYield": "4.5 tons/hectare",
      "priceRange": "₹2,800 - ₹3,200/quintal",
      "image":
      "https://images.pexels.com/photos/33239/rice-field-vietnam-agriculture.jpg?auto=compress&cs=tinysrgb&w=800",
      "plantingCalendar": {
        "bestTime": "June - July (Kharif season)",
        "duration": "120-140 days",
        "harvestTime": "October - November",
      },
      "waterRequirements": {
        "frequency": "Daily flooding for first 60 days",
        "amount": "1200-1500 mm total water",
        "method": "Flood irrigation",
      },
      "fertilizerSchedule": [
        {
          "stage": "Pre-planting",
          "fertilizer": "NPK 10:26:26",
          "amount": "100 kg/hectare",
        },
        {
          "stage": "Tillering (30 days)",
          "fertilizer": "Urea",
          "amount": "87 kg/hectare",
        },
        {
          "stage": "Panicle initiation (60 days)",
          "fertilizer": "NPK 12:32:16",
          "amount": "50 kg/hectare",
        },
      ],
      "pestManagement": [
        {
          "pest": "Brown Plant Hopper",
          "symptoms": "Yellowing and drying of leaves",
          "treatment": "Imidacloprid 17.8% SL @ 100ml/acre",
        },
        {
          "pest": "Stem Borer",
          "symptoms": "Dead hearts in vegetative stage",
          "treatment": "Cartap hydrochloride 4G @ 18.5 kg/hectare",
        },
      ],
    },
    {
      "id": 2,
      "name": "Wheat (HD-2967)",
      "localName": "गेहूं",
      "suitabilityScore": 88,
      "expectedYield": "5.2 tons/hectare",
      "priceRange": "₹2,100 - ₹2,350/quintal",
      "image":
      "https://images.pexels.com/photos/326082/pexels-photo-326082.jpeg?auto=compress&cs=tinysrgb&w=800",
      "plantingCalendar": {
        "bestTime": "November - December (Rabi season)",
        "duration": "120-130 days",
        "harvestTime": "March - April",
      },
      "waterRequirements": {
        "frequency": "4-6 irrigations during crop cycle",
        "amount": "300-350 mm total water",
        "method": "Furrow irrigation",
      },
      "fertilizerSchedule": [
        {
          "stage": "Basal application",
          "fertilizer": "DAP",
          "amount": "100 kg/hectare",
        },
        {
          "stage": "First irrigation (21 days)",
          "fertilizer": "Urea",
          "amount": "87 kg/hectare",
        },
        {
          "stage": "Second irrigation (40 days)",
          "fertilizer": "Urea",
          "amount": "43 kg/hectare",
        },
      ],
      "pestManagement": [
        {
          "pest": "Aphids",
          "symptoms": "Yellowing and curling of leaves",
          "treatment": "Dimethoate 30% EC @ 1ml/liter",
        },
        {
          "pest": "Termites",
          "symptoms": "Wilting and drying of plants",
          "treatment": "Chlorpyrifos 20% EC @ 2.5ml/liter",
        },
      ],
    },
    {
      "id": 3,
      "name": "Sugarcane (Co-238)",
      "localName": "गन्ना",
      "suitabilityScore": 85,
      "expectedYield": "80-90 tons/hectare",
      "priceRange": "₹280 - ₹320/quintal",
      "image":
      "https://images.pexels.com/photos/8828597/pexels-photo-8828597.jpeg?auto=compress&cs=tinysrgb&w=800",
      "plantingCalendar": {
        "bestTime": "February - March (Spring planting)",
        "duration": "12-18 months",
        "harvestTime": "December - March (next year)",
      },
      "waterRequirements": {
        "frequency": "Weekly irrigation in summer",
        "amount": "1500-2000 mm total water",
        "method": "Furrow or drip irrigation",
      },
      "fertilizerSchedule": [
        {
          "stage": "Planting",
          "fertilizer": "NPK 12:32:16",
          "amount": "150 kg/hectare",
        },
        {
          "stage": "45 days after planting",
          "fertilizer": "Urea",
          "amount": "174 kg/hectare",
        },
        {
          "stage": "90 days after planting",
          "fertilizer": "Urea",
          "amount": "87 kg/hectare",
        },
      ],
      "pestManagement": [
        {
          "pest": "Early Shoot Borer",
          "symptoms": "Dead hearts in young shoots",
          "treatment": "Carbofuran 3G @ 33 kg/hectare",
        },
        {
          "pest": "White Grub",
          "symptoms": "Yellowing and wilting of plants",
          "treatment": "Phorate 10G @ 10 kg/hectare",
        },
      ],
    },
    {
      "id": 4,
      "name": "Cotton (Bt Cotton)",
      "localName": "कपास",
      "suitabilityScore": 78,
      "expectedYield": "15-18 quintals/hectare",
      "priceRange": "₹5,500 - ₹6,200/quintal",
      "image":
      "https://images.pexels.com/photos/6129507/pexels-photo-6129507.jpeg?auto=compress&cs=tinysrgb&w=800",
      "plantingCalendar": {
        "bestTime": "April - May (Kharif season)",
        "duration": "180-200 days",
        "harvestTime": "October - December",
      },
      "waterRequirements": {
        "frequency": "10-12 irrigations during crop cycle",
        "amount": "700-800 mm total water",
        "method": "Drip or furrow irrigation",
      },
      "fertilizerSchedule": [
        {
          "stage": "Basal application",
          "fertilizer": "NPK 10:26:26",
          "amount": "100 kg/hectare",
        },
        {
          "stage": "Square formation (45 days)",
          "fertilizer": "Urea",
          "amount": "87 kg/hectare",
        },
        {
          "stage": "Flowering (75 days)",
          "fertilizer": "NPK 19:19:19",
          "amount": "50 kg/hectare",
        },
      ],
      "pestManagement": [
        {
          "pest": "Bollworm",
          "symptoms": "Holes in bolls and leaves",
          "treatment": "Emamectin benzoate 5% SG @ 220g/hectare",
        },
        {
          "pest": "Whitefly",
          "symptoms": "Yellowing and honeydew on leaves",
          "treatment": "Thiamethoxam 25% WG @ 100g/hectare",
        },
      ],
    },
    {
      "id": 5,
      "name": "Maize (Hybrid)",
      "localName": "मक्का",
      "suitabilityScore": 82,
      "expectedYield": "6.5 tons/hectare",
      "priceRange": "₹1,800 - ₹2,100/quintal",
      "image":
      "https://images.pexels.com/photos/547263/pexels-photo-547263.jpeg?auto=compress&cs=tinysrgb&w=800",
      "plantingCalendar": {
        "bestTime": "June - July (Kharif season)",
        "duration": "90-110 days",
        "harvestTime": "September - October",
      },
      "waterRequirements": {
        "frequency": "5-7 irrigations during crop cycle",
        "amount": "500-600 mm total water",
        "method": "Furrow or sprinkler irrigation",
      },
      "fertilizerSchedule": [
        {"stage": "Sowing", "fertilizer": "DAP", "amount": "125 kg/hectare"},
        {
          "stage": "Knee high stage (30 days)",
          "fertilizer": "Urea",
          "amount": "130 kg/hectare",
        },
        {
          "stage": "Tasseling (60 days)",
          "fertilizer": "Urea",
          "amount": "65 kg/hectare",
        },
      ],
      "pestManagement": [
        {
          "pest": "Fall Armyworm",
          "symptoms": "Holes in leaves and growing points",
          "treatment": "Spinetoram 11.7% SC @ 450ml/hectare",
        },
        {
          "pest": "Stem Borer",
          "symptoms": "Dead hearts and holes in stem",
          "treatment": "Cartap hydrochloride 4G @ 18.5 kg/hectare",
        },
      ],
    },
  ];


  // Mock soil analysis data
  final Map<String, dynamic> _analysisData = {
    "analysisDate": "2025-09-20",
    "soilType": "Alluvial",
    "phLevel": 6.8,
    "nitrogen": "Medium",
    "phosphorus": "High",
    "potassium": "Medium",
    "region": "Punjab",
    "regionalSuccessRate": 87,
  };

  List<Map<String, dynamic>> get _filteredCrops {
    List<Map<String, dynamic>> crops = List.from(_cropRecommendations);

    switch (_selectedFilter) {
      case 'yield':
        crops.sort(
              (a, b) => (b['suitabilityScore'] as num).compareTo(
            a['suitabilityScore'] as num,
          ),
        );
        break;
      case 'price':
        crops.sort((a, b) {
          final aPrice = _extractPrice(a['priceRange'] as String);
          final bPrice = _extractPrice(b['priceRange'] as String);
          return bPrice.compareTo(aPrice);
        });
        break;
      case 'water':
        crops =
            crops.where((crop) {
              final waterAmount = crop['waterRequirements']['amount'] as String;
              return waterAmount.contains('500') ||
                  waterAmount.contains('600') ||
                  waterAmount.contains('700');
            }).toList();
        break;
      case 'season':
        crops.sort(
              (a, b) => (b['suitabilityScore'] as num).compareTo(
            a['suitabilityScore'] as num,
          ),
        );
        break;
    }

    return crops;
  }

  double _extractPrice(String priceRange) {
    final regex = RegExp(r'₹([\d,]+)');
    final matches = regex.allMatches(priceRange);
    if (matches.isNotEmpty) {
      final priceStr = matches.first.group(1)?.replaceAll(',', '') ?? '0';
      return double.tryParse(priceStr) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Crops',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
            Text(
              'Analysis: ${_analysisData['analysisDate']}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary.withValues(
                  alpha: 0.8,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Fallback navigation to dashboard if no previous route
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            }
          },
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            size: 24,
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
        actions: [
          if (_isCompareMode) ...[
            Container(
              margin: EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onPrimary.withValues(
                  alpha: 0.2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedCropsForComparison.length}/3',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          IconButton(
            onPressed: _toggleCompareMode,
            icon: CustomIconWidget(
              iconName: _isCompareMode ? 'close' : 'compare',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
          ),
          ProfileActionIcon(), // ✅ add this
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRecommendations,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  FilterChipsWidget(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: _onFilterChanged,
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final crop = _filteredCrops[index];
                final isSelected = _selectedCropsForComparison.contains(
                  crop['id'].toString(),
                );

                return Stack(
                  children: [
                    CropCardWidget(
                      cropData: crop,
                      onTap: () => _onCropTap(crop),
                      onAddToFarmPlan: () => _addToFarmPlan(crop),
                      onSetReminder: () => _setPlantingReminder(crop),
                      onShare: () => _shareWithExtensionWorker(crop),
                    ),
                    if (_isCompareMode)
                      Positioned(
                        top: 2.h,
                        right: 6.w,
                        child: GestureDetector(
                          onTap:
                              () => _toggleCropSelection(crop['id'].toString()),
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color:
                              isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.surface,
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            child:
                            isSelected
                                ? CustomIconWidget(
                              iconName: 'check',
                              size: 16,
                              color:
                              AppTheme
                                  .lightTheme
                                  .colorScheme
                                  .onPrimary,
                            )
                                : null,
                          ),
                        ),
                      ),
                  ],
                );
              }, childCount: _filteredCrops.length),
            ),
            SliverToBoxAdapter(
              child: ExplanationSectionWidget(analysisData: _analysisData),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10.h)),
          ],
        ),
      ),
      floatingActionButton:
      _isCompareMode && _selectedCropsForComparison.length >= 2
          ? FloatingActionButton.extended(
        onPressed: _compareCrops,
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        foregroundColor: Colors.black,
        icon: CustomIconWidget(
          iconName: 'compare_arrows',
          size: 20,
          color: Colors.black,
        ),
        label: Text(
          'Compare (${_selectedCropsForComparison.length})',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : !_isCompareMode
          ? FloatingActionButton(
        onPressed: _toggleCompareMode,
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        foregroundColor: Colors.black,
        child: CustomIconWidget(
          iconName: 'compare',
          size: 24,
          color: Colors.black,
        ),
      )
          : null,
      bottomNavigationBar: const _ApplySchemesBar(),
    );
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _refreshRecommendations() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    Fluttertoast.showToast(
      msg: "Recommendations updated with latest market prices",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onCropTap(Map<String, dynamic> crop) {
    if (_isCompareMode) {
      _toggleCropSelection(crop['id'].toString());
    } else {
      _showCropDetails(crop);
    }
  }

  void _showCropDetails(Map<String, dynamic> crop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CropDetailModalWidget(cropData: crop),
    );
  }

  void _toggleCompareMode() {
    setState(() {
      _isCompareMode = !_isCompareMode;
      if (!_isCompareMode) {
        _selectedCropsForComparison.clear();
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _toggleCropSelection(String cropId) {
    setState(() {
      if (_selectedCropsForComparison.contains(cropId)) {
        _selectedCropsForComparison.remove(cropId);
      } else if (_selectedCropsForComparison.length < 3) {
        _selectedCropsForComparison.add(cropId);
      } else {
        Fluttertoast.showToast(
          msg: "You can compare maximum 3 crops at a time",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    });
    HapticFeedback.selectionClick();
  }

  void _compareCrops() {
    final selectedCrops =
    _cropRecommendations
        .where(
          (crop) =>
          _selectedCropsForComparison.contains(crop['id'].toString()),
    )
        .toList();

    // Navigate to comparison screen (would be implemented separately)
    Fluttertoast.showToast(
      msg: "Comparing ${selectedCrops.length} crops",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _addToFarmPlan(Map<String, dynamic> crop) {
    Fluttertoast.showToast(
      msg: "${crop['name']} added to your farm plan",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    HapticFeedback.lightImpact();
  }

  void _setPlantingReminder(Map<String, dynamic> crop) {
    final plantingTime =
        crop['plantingCalendar']['bestTime'] as String? ?? 'Unknown';
    Fluttertoast.showToast(
      msg: "Reminder set for ${crop['name']} planting in $plantingTime",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    HapticFeedback.lightImpact();
  }

  void _shareWithExtensionWorker(Map<String, dynamic> crop) {
    Fluttertoast.showToast(
      msg: "Sharing ${crop['name']} details with extension worker",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    HapticFeedback.lightImpact();
  }
}
class _ApplySchemesBar extends StatelessWidget {
  const _ApplySchemesBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                goToMainTab(3);
              });
            },

            icon: const Icon(Icons.account_balance),
            label: const Text('Apply for schemes'),
          ),
        ),
      ),
    );
  }
}

