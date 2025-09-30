import 'dart:async';

import 'package:enrollease_web/states_management/statistics_model_data_controller.dart';
import 'package:enrollease_web/model/statistics_model.dart';
import 'package:enrollease_web/model/faculty_activity_model.dart';
import 'package:enrollease_web/services/faculty_activity_service.dart';
import 'package:enrollease_web/utils/app_size.dart';
import 'package:enrollease_web/utils/bottom_credits.dart';

import 'package:enrollease_web/utils/theme_colors.dart';
import 'package:enrollease_web/states_management/theme_provider.dart';
import 'package:enrollease_web/widgets/custom_appbar.dart';
import 'package:enrollease_web/widgets/custom_body.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    this.userId,
    this.userName,
  });
  final String? userId;
  final String? userName;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late StreamSubscription<List<StatisticsModel>> _statsStreamSubscription;
  int _totalFacultyStaff = 0;
  int _activeFacultyStaff = 0;
  int _totalStudents = 0;
  int _enrolledStudents = 0;
  bool _isLoading = true;

  // Activity monitoring data
  Map<String, dynamic> _activityStats = {};
  List<FacultyActivityModel> _recentActivities = [];
  bool _activityLoading = true;

  @override
  void initState() {
    super.initState();
    _statsStreamSubscription = Provider.of<StatisticsModelDataController>(
      context,
      listen: false,
    ).statsStream.listen((updatedData) {
      setState(() {});
    });
    _loadAdminStatistics();
    _loadActivityData();
  }

  @override
  void dispose() {
    _statsStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadAdminStatistics() async {
    setState(() => _isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;

      // Get faculty/staff statistics
      final facultyStaffSnapshot =
          await firestore.collection('faculty_staff').get();
      _totalFacultyStaff = facultyStaffSnapshot.docs.length;
      _activeFacultyStaff = facultyStaffSnapshot.docs
          .where((doc) => doc.data()['status'] == 'Active')
          .length;

      // Get student statistics
      final studentsSnapshot = await firestore.collection('students').get();
      _totalStudents = studentsSnapshot.docs.length;
      _enrolledStudents = studentsSnapshot.docs
          .where((doc) => doc.data()['enrollmentStatus'] == 'Enrolled')
          .length;
    } catch (e) {
      debugPrint('Error loading admin statistics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadActivityData() async {
    setState(() => _activityLoading = true);

    try {
      // Load activity statistics
      final activityStats =
          await FacultyActivityService.getActivityStatistics(days: 30);

      // Load recent activities
      final recentActivities =
          await FacultyActivityService.getAllRecentActivities(limit: 20);

      setState(() {
        _activityStats = activityStats;
        _recentActivities = recentActivities;
      });
    } catch (e) {
      debugPrint('Error loading activity data: $e');
    } finally {
      setState(() => _activityLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);

    final isSmallOrMediumScreen = ResponsiveWidget.isMediumScreen(context) ||
        ResponsiveWidget.isLargeScreen(context);

    return Scaffold(
      backgroundColor: Provider.of<ThemeProvider>(context, listen: false)
              .currentColors['background'] ??
          ThemeColors.background(context),
      appBar: CustomAppBar(
        title: 'Admin Dashboard',
        userId: widget.userId,
        userName: widget.userName,
      ),
      body: CustomBody(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Admin View Header
                Animate(
                  effects: [
                    FadeEffect(duration: 600.ms),
                    const SlideEffect(begin: Offset(0, 0.2), end: Offset.zero),
                  ],
                  child: _buildAdminHeader(),
                ),
                const SizedBox(height: 30),

                // System Overview Statistics
                Animate(
                  effects: [
                    FadeEffect(delay: 200.ms, duration: 600.ms),
                    const SlideEffect(begin: Offset(0, 0.2), end: Offset.zero),
                  ],
                  child: _buildSystemOverview(),
                ),
                const SizedBox(height: 30),

                // Faculty/Staff Statistics
                Animate(
                  effects: [
                    FadeEffect(delay: 400.ms, duration: 600.ms),
                    const SlideEffect(begin: Offset(0, 0.2), end: Offset.zero),
                  ],
                  child: _buildFacultyStaffStats(),
                ),
                const SizedBox(height: 30),

                // Regular Statistics (from existing system)
                Consumer<StatisticsModelDataController>(
                  builder: (context, statsData, child) {
                    if (statsData.data.isEmpty) {
                      return _buildLoadingShimmer();
                    }
                    return Animate(
                      effects: [
                        FadeEffect(delay: 600.ms, duration: 600.ms),
                        const SlideEffect(
                            begin: Offset(0, 0.2), end: Offset.zero),
                      ],
                      child: buildStatistics(statsData.data),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isSmallOrMediumScreen
          ? bottomCredits(context)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const FaIcon(
              FontAwesomeIcons.shield,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Comprehensive system overview and monitoring',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
            ),
            child: Text(
              'ADMIN VIEW',
              style: GoogleFonts.poppins(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemOverview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.chartLine,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'System Overview',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            _buildLoadingShimmer()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 1000;

                if (isSmallScreen) {
                  // Stack cards vertically on small screens
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildOverviewCard(
                              'Total Faculty/Staff',
                              _totalFacultyStaff.toString(),
                              FontAwesomeIcons.users,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildOverviewCard(
                              'Active Faculty/Staff',
                              _activeFacultyStaff.toString(),
                              FontAwesomeIcons.userCheck,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOverviewCard(
                              'Total Students',
                              _totalStudents.toString(),
                              FontAwesomeIcons.graduationCap,
                              Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildOverviewCard(
                              'Enrolled Students',
                              _enrolledStudents.toString(),
                              FontAwesomeIcons.school,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Horizontal layout for larger screens
                  return Row(
                    children: [
                      Expanded(
                        child: _buildOverviewCard(
                          'Total Faculty/Staff',
                          _totalFacultyStaff.toString(),
                          FontAwesomeIcons.users,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewCard(
                          'Active Faculty/Staff',
                          _activeFacultyStaff.toString(),
                          FontAwesomeIcons.userCheck,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewCard(
                          'Total Students',
                          _totalStudents.toString(),
                          FontAwesomeIcons.graduationCap,
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewCard(
                          'Enrolled Students',
                          _enrolledStudents.toString(),
                          FontAwesomeIcons.school,
                          Colors.orange,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          FaIcon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyStaffStats() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.chartLine,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Faculty & Staff Activity (Last 30 Days)',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_activityLoading)
            _buildActivityLoadingShimmer()
          else
            _buildActivityContent(),
        ],
      ),
    );
  }

  Widget _buildActivityContent() {
    final totalActivities = _activityStats['totalActivities'] ?? 0;
    final uniqueFaculty = _activityStats['uniqueFaculty'] ?? 0;
    final recentActivities = _activityStats['recentActivities'] ?? 0;
    final activityTypeCounts =
        _activityStats['activityTypeCounts'] as Map<String, int>? ?? {};

    return Column(
      children: [
        // Activity Statistics Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 800;

            if (isSmallScreen) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActivityCard(
                          'Total Activities',
                          totalActivities.toString(),
                          FontAwesomeIcons.chartBar,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActivityCard(
                          'Active Faculty',
                          uniqueFaculty.toString(),
                          FontAwesomeIcons.users,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildActivityCard(
                    'Recent (24h)',
                    recentActivities.toString(),
                    FontAwesomeIcons.clock,
                    Colors.orange,
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: _buildActivityCard(
                      'Total Activities',
                      totalActivities.toString(),
                      FontAwesomeIcons.chartBar,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActivityCard(
                      'Active Faculty',
                      uniqueFaculty.toString(),
                      FontAwesomeIcons.users,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActivityCard(
                      'Recent (24h)',
                      recentActivities.toString(),
                      FontAwesomeIcons.clock,
                      Colors.orange,
                    ),
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 20),

        // Activity Type Breakdown
        if (activityTypeCounts.isNotEmpty) ...[
          Text(
            'Activity Breakdown',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityTypeBreakdown(activityTypeCounts),
          const SizedBox(height: 20),
        ],

        // Recent Activities
        Text(
          'Recent Activities',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildRecentActivitiesList(),
      ],
    );
  }

  Widget _buildActivityCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          FaIcon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTypeBreakdown(Map<String, int> activityTypeCounts) {
    final sortedTypes = activityTypeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: sortedTypes.take(5).map((entry) {
          final activityType = entry.key;
          final count = entry.value;
          final percentage = activityTypeCounts.values.isNotEmpty
              ? (count /
                  activityTypeCounts.values.reduce((a, b) => a + b) *
                  100)
              : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  FacultyActivityModel.getActivityIcon(activityType),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    FacultyActivityModel.getActivityDisplayName(activityType),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  '$count (${percentage.toStringAsFixed(1)}%)',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivitiesList() {
    if (_recentActivities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Text(
            'No recent activities found',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _recentActivities.take(10).length,
        itemBuilder: (context, index) {
          final activity = _recentActivities[index];
          return _buildActivityItem(activity);
        },
      ),
    );
  }

  Widget _buildActivityItem(FacultyActivityModel activity) {
    final timeAgo = _getTimeAgo(activity.timestamp);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              FacultyActivityModel.getActivityIcon(activity.activityType),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${activity.facultyName} • $timeAgo',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Row(
            children: List.generate(
                3,
                (index) => Expanded(
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          4,
          (index) => Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  buildStatistics(List<StatisticsModel> statisticsData) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isSmallScreen = constraints.maxWidth < 800;
      final double cardWidth = isSmallScreen ? 280.0 : 350.0;
      final double horizontalSpacing =
          isSmallScreen ? 12.0 : AppSizes.blockSizeHorizontal * 3;

      final children = statisticsData.asMap().entries.map((entry) {
        final int index = entry.key;
        final stat = entry.value;
        return Padding(
          padding: EdgeInsets.only(
              right:
                  index == statisticsData.length - 1 ? 0 : horizontalSpacing),
          child: SizedBox(
            width: cardWidth,
            child: _buildStatCard(stat, cardWidth),
          ),
        );
      }).toList();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      );
    });
  }

  Widget _buildStatCard(StatisticsModel stat, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              _getIconForStat(stat.title),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            stat.count,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Provider.of<ThemeProvider>(context, listen: false)
                      .currentColors['appBar'] ??
                  Provider.of<ThemeProvider>(context, listen: false)
                      .currentColors['appBar'] ??
                  ThemeColors.appBarPrimary(context),
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
            duration: 2.seconds, color: Colors.white.withValues(alpha: 0.2))
        .then()
        .shimmer(
            duration: 2.seconds, color: Colors.white.withValues(alpha: 0.2));
  }

  Widget _getIconForStat(String title) {
    IconData iconData;
    switch (title) {
      case 'Pending Approvals':
        iconData = FontAwesomeIcons.clock;
        break;
      case 'Total Users':
        iconData = FontAwesomeIcons.users;
        break;
      case 'Total Enrolled':
        iconData = FontAwesomeIcons.graduationCap;
        break;
      default:
        iconData = FontAwesomeIcons.chartBar;
    }
    return FaIcon(
      iconData,
      color: Provider.of<ThemeProvider>(context, listen: false)
              .currentColors['appBar'] ??
          ThemeColors.appBarPrimary(context),
      size: 24,
    );
  }
}
