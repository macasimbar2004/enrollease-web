import 'dart:async';

import 'package:enrollease_web/widgets/demographics_chart.dart';
import 'package:enrollease_web/states_management/statistics_model_data_controller.dart';
import 'package:enrollease_web/model/statistics_model.dart';
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

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    this.userId,
    this.userName,
  });
  final String? userId;
  final String? userName;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Define the options
  final List<String> options = [
    'Pending Approvals',
    'Total Users',
    'Total Enrolled',
  ];

  // Set the initial value
  String selectedOption = 'Pending Approvals';

  late StreamSubscription<List<StatisticsModel>> _statsStreamSubscription;

  @override
  void initState() {
    super.initState();
    _statsStreamSubscription = Provider.of<StatisticsModelDataController>(
      context,
      listen: false,
    ).statsStream.listen((updatedData) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _statsStreamSubscription.cancel();
    super.dispose();
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
        title: 'Dashboard',
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
                Consumer<StatisticsModelDataController>(
                  builder: (context, statsData, child) {
                    if (statsData.data.isEmpty) {
                      return _buildLoadingShimmer();
                    }
                    return Animate(
                      effects: [
                        FadeEffect(duration: 600.ms),
                        const SlideEffect(
                            begin: Offset(0, 0.2), end: Offset.zero),
                      ],
                      child: buildStatistics(statsData.data),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Animate(
                  effects: [
                    FadeEffect(delay: 200.ms, duration: 600.ms),
                    const SlideEffect(begin: Offset(0, 0.2), end: Offset.zero),
                  ],
                  child: const DemographicsChart(),
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

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (index) => Container(
            width: 300,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  // Audit Log section removed and replaced with demographics chart

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
                      .currentColors['content'] ??
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
    Color iconColor;

    switch (title.toLowerCase()) {
      case 'pending approvals':
        iconData = FontAwesomeIcons.clock;
        iconColor = Colors.orange;
        break;
      case 'total users':
        iconData = FontAwesomeIcons.users;
        iconColor = Colors.blue;
        break;
      case 'total enrolled':
        iconData = FontAwesomeIcons.graduationCap;
        iconColor = Colors.green;
        break;
      default:
        iconData = FontAwesomeIcons.chartLine;
        iconColor = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FaIcon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }
}
