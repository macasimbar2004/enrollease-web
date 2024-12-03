import 'dart:async';

import 'package:enrollease_web/paginated_table/table/notifications_table.dart';
import 'package:enrollease_web/states_management/statistics_model_data_controller.dart';
import 'package:enrollease_web/model/statistics_model.dart';
import 'package:enrollease_web/utils/app_size.dart';
import 'package:enrollease_web/utils/bottom_credits.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/widgets/responsive_widget.dart';
import 'package:enrollease_web/utils/text_styles.dart';
import 'package:enrollease_web/widgets/custom_card.dart';
import 'package:enrollease_web/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, this.userId});
  final String? userId;

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
      setState(() {
        // Optionally handle state update here if needed
      });
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

    final isSmallOrMediumScreen = ResponsiveWidget.isMediumScreen(context) || ResponsiveWidget.isLargeScreen(context);

    return Scaffold(
      backgroundColor: CustomColors.appBarColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomDrawerHeader(
                headerName: 'dashboard',
                userId: widget.userId,
              ),
              Consumer<StatisticsModelDataController>(
                builder: (context, statsData, child) {
                  if (statsData.data.isEmpty) {
                    return const Center(
                      child: SpinKitFadingCircle(
                        color: CustomColors.contentColor,
                        size: 100.0,
                      ),
                    );
                  }
                  return buildStatistics(statsData.data);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    runAlignment: WrapAlignment.center, // Centering items
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 10, // Vertical space between rows of cards
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'Notifications',
                          style: CustomTextStyles.lusitanaFont(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // buildFilterTable(),
                      const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: NotificationsTable()
                          // selectedOption == 'Total Users'
                          //     ? const NewUsersTable()
                          //     : selectedOption == 'Pending Approvals'
                          //         ? const PendingApprovalsTable()
                          //         : const PendingApprovalsTable(),
                          ),
                    ],
                  ))
            ],
          ),
        ),
      ),
      bottomNavigationBar: isSmallOrMediumScreen ? bottomCredits(context) : const SizedBox.shrink(),
    );
  }

  // Widget buildFilterTable() {
  //   return Theme(
  //     data: Theme.of(context).copyWith(
  //       canvasColor: CustomColors.contentColor,
  //     ),
  //     child: DropdownButton<String>(
  //       value: selectedOption,
  //       icon: const Icon(Icons.arrow_drop_down),
  //       iconSize: 24,
  //       elevation: 16,
  //       padding: EdgeInsets.all(5),
  //       style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
  //       onChanged: (String? newValue) {
  //         setState(() {
  //           selectedOption = newValue!;
  //         });
  //       },
  //       items: options.map<DropdownMenuItem<String>>((String option) {
  //         return DropdownMenuItem<String>(
  //           value: option,
  //           child: Text(
  //             option,
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  Wrap buildStatistics(List<StatisticsModel> statisticsData) {
    return Wrap(
      runAlignment: WrapAlignment.center, // Centering items
      spacing: AppSizes.blockSizeHorizontal * 5, // Horizontal space between the cards
      runSpacing: 10, // Vertical space between rows of cards
      children: statisticsData.map((stat) {
        return SizedBox(
          width: 300,
          child: CustomCard(
            color: CustomColors.color1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centering content within the card
              children: [
                Image.asset(
                  stat.imageAssets,
                  width: 60,
                  height: 60,
                ),
                const SizedBox(width: 5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat.title,
                      style: CustomTextStyles.lusitanaFont(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      stat.count,
                      style: CustomTextStyles.lusitanaFont(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
