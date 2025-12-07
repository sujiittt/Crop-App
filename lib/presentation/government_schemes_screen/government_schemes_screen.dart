import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/application_tracker_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/scheme_card_widget.dart';
import './widgets/search_bar_widget.dart';
import 'package:cropwise/widgets/profile_action_icon.dart';


class GovernmentSchemesScreen extends StatefulWidget {
  const GovernmentSchemesScreen({Key? key}) : super(key: key);

  @override
  State<GovernmentSchemesScreen> createState() =>
      _GovernmentSchemesScreenState();
}

class _GovernmentSchemesScreenState extends State<GovernmentSchemesScreen>
     {
  String _searchQuery = '';
  String _selectedFilter = 'All Schemes';
  bool _isLoading = false;

  final List<String> _filterOptions = [
    'All Schemes',
    'Eligible for Me',
    'Highest Benefits',
    'Ending Soon',
    'Recently Added',
  ];

  final List<String> _searchSuggestions = [
    'Crop Insurance',
    'Fertilizer Subsidy',
    'Kisan Credit Card',
    'PM-KISAN',
    'Soil Health Card',
    'Organic Farming',
    'Drip Irrigation',
    'Farm Mechanization',
    'Seed Subsidy',
    'Weather Insurance',
    'Training Programs',
    'Agricultural Loans',
  ];

  final List<Map<String, dynamic>> _allSchemes = [
    {
      "id": 1,
      "name": "Pradhan Mantri Kisan Samman Nidhi",
      "nameLocal": "प्रधानमंत्री किसान सम्मान निधि",
      "category": "Subsidies",
      "description":
      "Direct income support to small and marginal farmers with landholding up to 2 hectares",
      "maxBenefit": "₹6,000/year",
      "deadline": "31/03/2025",
      "eligibilityStatus": "Eligible",
      "requirements": [
        "Land ownership documents",
        "Aadhaar card",
        "Bank account details"
      ],
      "applicationProcess":
      "Online application through PM-KISAN portal or visit nearest CSC",
      "successStories":
      "Over 12 crore farmers have benefited with direct cash transfer",
    },
    {
      "id": 2,
      "name": "Kisan Credit Card Scheme",
      "nameLocal": "किसान क्रेडिट कार्ड योजना",
      "category": "Loans",
      "description":
      "Flexible credit facility for farmers to meet their agricultural and allied activities",
      "maxBenefit": "₹3,00,000",
      "deadline": "Open",
      "eligibilityStatus": "Eligible",
      "requirements": [
        "Land documents",
        "Identity proof",
        "Address proof",
        "Income certificate"
      ],
      "applicationProcess":
      "Apply at nearest bank branch or through online banking",
      "successStories":
      "7 crore farmers have access to timely and adequate credit",
    },
    {
      "id": 3,
      "name": "Pradhan Mantri Fasal Bima Yojana",
      "nameLocal": "प्रधानमंत्री फसल बीमा योजना",
      "category": "Insurance",
      "description":
      "Comprehensive crop insurance scheme covering pre-sowing to post-harvest losses",
      "maxBenefit": "₹2,00,000",
      "deadline": "15/12/2024",
      "eligibilityStatus": "Pending Review",
      "requirements": [
        "Land records",
        "Sowing certificate",
        "Bank account",
        "Aadhaar card"
      ],
      "applicationProcess":
      "Apply through insurance companies or banks during crop season",
      "successStories": "5.5 crore farmers enrolled with 90% premium subsidy",
    },
    {
      "id": 4,
      "name": "Soil Health Management Scheme",
      "nameLocal": "मृदा स्वास्थ्य प्रबंधन योजना",
      "category": "Subsidies",
      "description":
      "Free soil testing and health card distribution to promote balanced fertilizer use",
      "maxBenefit": "₹15,000",
      "deadline": "28/02/2025",
      "eligibilityStatus": "Eligible",
      "requirements": [
        "Land ownership proof",
        "Farmer registration",
        "Soil samples"
      ],
      "applicationProcess":
      "Visit nearest soil testing laboratory or agriculture office",
      "successStories": "24 crore soil health cards distributed across India",
    },
    {
      "id": 5,
      "name": "National Mission for Sustainable Agriculture",
      "nameLocal": "राष्ट्रीय सतत कृषि मिशन",
      "category": "Training Programs",
      "description":
      "Capacity building and training programs for climate-resilient agriculture practices",
      "maxBenefit": "₹50,000",
      "deadline": "30/06/2025",
      "eligibilityStatus": "Not Eligible",
      "requirements": [
        "Farmer certificate",
        "Training completion",
        "Project proposal"
      ],
      "applicationProcess":
      "Apply through state agriculture departments or KVKs",
      "successStories":
      "2 lakh farmers trained in sustainable farming practices",
    },
    {
      "id": 6,
      "name": "Micro Irrigation Fund",
      "nameLocal": "सूक्ष्म सिंचाई कोष",
      "category": "Subsidies",
      "description":
      "Financial assistance for drip and sprinkler irrigation systems installation",
      "maxBenefit": "₹1,00,000",
      "deadline": "20/01/2025",
      "eligibilityStatus": "Eligible",
      "requirements": [
        "Water source proof",
        "Land documents",
        "Technical feasibility report"
      ],
      "applicationProcess":
      "Apply through state irrigation departments or online portal",
      "successStories": "69 lakh hectares covered under micro irrigation",
    },
  ];

  final List<Map<String, dynamic>> _applications = [
    {
      "id": 1,
      "applicationId": "APP001234",
      "schemeName": "PM-KISAN Scheme",
      "status": "Approved",
      "appliedDate": "15/11/2024",
      "nextStep": "Amount will be credited in next installment",
    },
    {
      "id": 2,
      "applicationId": "APP005678",
      "schemeName": "Crop Insurance",
      "status": "Under Review",
      "appliedDate": "28/10/2024",
      "nextStep": "Field verification in progress",
    },
    {
      "id": 3,
      "applicationId": "APP009012",
      "schemeName": "Soil Health Card",
      "status": "Documents Required",
      "appliedDate": "05/11/2024",
      "nextStep": "Submit updated land documents",
    },
  ];


  List<Map<String, dynamic>> get _filteredSchemes {
    List<Map<String, dynamic>> schemes = _allSchemes;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      schemes = schemes.where((scheme) {
        return (scheme['name'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
            (scheme['nameLocal'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (scheme['description'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (scheme['category'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'Eligible for Me':
        schemes = schemes
            .where((scheme) => scheme['eligibilityStatus'] == 'Eligible')
            .toList();
        break;
      case 'Highest Benefits':
        schemes.sort((a, b) {
          final aAmount = _extractAmount(a['maxBenefit'] as String);
          final bAmount = _extractAmount(b['maxBenefit'] as String);
          return bAmount.compareTo(aAmount);
        });
        break;
      case 'Ending Soon':
        schemes = schemes.where((scheme) {
          final deadline = scheme['deadline'] as String;
          return deadline != 'Open' && _isDeadlineNear(deadline);
        }).toList();
        schemes.sort((a, b) =>
            _compareDates(a['deadline'] as String, b['deadline'] as String));
        break;
      case 'Recently Added':
      // For demo purposes, reverse the list to simulate recently added
        schemes = schemes.reversed.toList();
        break;
    }

    return schemes;
  }

  int _extractAmount(String amountStr) {
    final regex = RegExp(r'₹([\d,]+)');
    final match = regex.firstMatch(amountStr);
    if (match != null) {
      return int.parse(match.group(1)!.replaceAll(',', ''));
    }
    return 0;
  }

  bool _isDeadlineNear(String deadline) {
    try {
      final parts = deadline.split('/');
      if (parts.length == 3) {
        final deadlineDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final now = DateTime.now();
        final difference = deadlineDate.difference(now).inDays;
        return difference <= 30 && difference >= 0;
      }
    } catch (e) {
      // Handle parsing error
    }
    return false;
  }

  int _compareDates(String date1, String date2) {
    try {
      final parts1 = date1.split('/');
      final parts2 = date2.split('/');

      if (parts1.length == 3 && parts2.length == 3) {
        final dateTime1 = DateTime(
          int.parse(parts1[2]),
          int.parse(parts1[1]),
          int.parse(parts1[0]),
        );
        final dateTime2 = DateTime(
          int.parse(parts2[2]),
          int.parse(parts2[1]),
          int.parse(parts2[0]),
        );
        return dateTime1.compareTo(dateTime2);
      }
    } catch (e) {
      // Handle parsing error
    }
    return 0;
  }

  Future<void> _refreshSchemes() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    Fluttertoast.showToast(
      msg: "Schemes updated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showSchemeDetails(Map<String, dynamic> scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSchemeDetailsSheet(scheme),
    );
  }

  Widget _buildSchemeDetailsSheet(Map<String, dynamic> scheme) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme['name'] as String,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        scheme['nameLocal'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(
                      'Description', scheme['description'] as String),
                  SizedBox(height: 2.h),
                  _buildDetailSection(
                      'Maximum Benefit', scheme['maxBenefit'] as String),
                  SizedBox(height: 2.h),
                  _buildDetailSection(
                      'Application Deadline', scheme['deadline'] as String),
                  SizedBox(height: 2.h),
                  _buildDetailSection('Requirements',
                      (scheme['requirements'] as List).join('\n• ')),
                  SizedBox(height: 2.h),
                  _buildDetailSection('Application Process',
                      scheme['applicationProcess'] as String),
                  SizedBox(height: 2.h),
                  _buildDetailSection(
                      'Success Stories', scheme['successStories'] as String),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _checkEligibility(scheme),
                          child: Text('Check Eligibility'),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _startApplication(scheme),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.getSuccessColor(true),
                          ),
                          child: Text('Apply Now'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            content.startsWith('•') ? '• $content' : content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  void _checkEligibility(Map<String, dynamic> scheme) {
    Navigator.pop(context);
    Fluttertoast.showToast(
      msg: "Checking eligibility for ${scheme['name']}...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _startApplication(Map<String, dynamic> scheme) {
    Navigator.pop(context);
    Fluttertoast.showToast(
      msg: "Starting application for ${scheme['name']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _setReminder(Map<String, dynamic> scheme) {
    Fluttertoast.showToast(
      msg: "Reminder set for ${scheme['name']} deadline",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _shareScheme(Map<String, dynamic> scheme) {
    Fluttertoast.showToast(
      msg: "Sharing ${scheme['name']} with family",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Text(
                    'Filter Schemes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            ..._filterOptions.map((option) => ListTile(
              title: Text(option),
              trailing: _selectedFilter == option
                  ? CustomIconWidget(
                iconName: 'check',
                size: 20,
                color: AppTheme.lightTheme.primaryColor,
              )
                  : null,
              onTap: () {
                setState(() {
                  _selectedFilter = option;
                });
                Navigator.pop(context);
              },
            )),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _onApplicationTap(Map<String, dynamic> application) {
    Fluttertoast.showToast(
      msg: "Opening application ${application['applicationId']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Government Schemes'),
        centerTitle: true,
        actions: const [
          ProfileActionIcon(), // ✅ add this
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshSchemes,
          child: Column(
            children: [
              SearchBarWidget(
                hintText: 'Search schemes in English or Hindi...',
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                onFilterTap: _showFilterOptions,
                suggestions: _searchSuggestions,
              ),
              Container(
                height: 6.h,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filterOptions.length,
                  itemBuilder: (context, index) {
                    final filter = _filterOptions[index];
                    return FilterChipWidget(
                      label: filter,
                      isSelected: _selectedFilter == filter,
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      iconName: _getFilterIcon(filter),
                    );
                  },
                ),
              ),
              if (_applications.isNotEmpty) ...[
                ApplicationTrackerWidget(
                  applications: _applications,
                  onApplicationTap: _onApplicationTap,
                ),
                SizedBox(height: 1.h),
              ],
              Expanded(
                child: _isLoading
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 2.h),
                      Text(
                        'Updating schemes...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
                    : _filteredSchemes.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'search_off',
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No schemes found',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Try adjusting your search or filters',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.only(bottom: 2.h),
                  itemCount: _filteredSchemes.length,
                  itemBuilder: (context, index) {
                    final scheme = _filteredSchemes[index];
                    return SchemeCardWidget(
                      scheme: scheme,
                      onTap: () => _showSchemeDetails(scheme),
                      onCheckEligibility: () =>
                          _checkEligibility(scheme),
                      onStartApplication: () =>
                          _startApplication(scheme),
                      onSetReminder: () => _setReminder(scheme),
                      onShare: () => _shareScheme(scheme),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getFilterIcon(String filter) {
    switch (filter) {
      case 'Eligible for Me':
        return 'check_circle';
      case 'Highest Benefits':
        return 'trending_up';
      case 'Ending Soon':
        return 'schedule';
      case 'Recently Added':
        return 'new_releases';
      default:
        return null;
    }
  }
}
