import 'package:enrollease_web/data/statistics_model_data.dart';
import 'package:enrollease_web/model/statistics_model.dart';
import 'package:enrollease_web/paginated_table/table/new_users_table.dart';
import 'package:enrollease_web/utils/app_size.dart';
import 'package:enrollease_web/utils/bottom_credits.dart';
import 'package:enrollease_web/utils/colors.dart';
import 'package:enrollease_web/utils/responsive_widget.dart';
import 'package:enrollease_web/utils/text_styles.dart';
import 'package:enrollease_web/widgets/custom_card.dart';
import 'package:enrollease_web/widgets/custom_header.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, this.userId});
  final String? userId;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Define the options
  final List<String> options = [
    'New Users',
    'Pending Approvals',
    'Total Enrolled',
  ];

  // Set the initial value
  String selectedOption = 'New Users';

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);

    final statisticsData =
        StatisticsModelData().data; // Access the statistics data

    final isSmallOrMediumScreen = ResponsiveWidget.isMediumScreen(context) ||
        ResponsiveWidget.isLargeScreen(context);

    return Scaffold(
      backgroundColor: CustomColors.appBarColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: CustomDrawerHeader(
                  headerName: 'dashboard',
                  userId: widget.userId,
                ),
              ),
              buildStatistics(statisticsData),
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
                      Text(
                        'FILTER TABLE BY:    ',
                        style: CustomTextStyles.lusitanaFont(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      buildFilterTable(),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: NewUsersTable(),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          isSmallOrMediumScreen ? bottomCredits() : const SizedBox.shrink(),
    );
  }

  DropdownButton<String> buildFilterTable() {
    return DropdownButton<String>(
      value: selectedOption,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
      underline: Container(
        height: 2,
        color: Colors.blueAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          selectedOption = newValue!;
        });
      },
      items: options.map<DropdownMenuItem<String>>((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
          ),
        );
      }).toList(),
    );
  }

  Wrap buildStatistics(List<StatisticsModel> statisticsData) {
    return Wrap(
      runAlignment: WrapAlignment.center, // Centering items

      spacing: AppSizes.blockSizeHorizontal *
          10, // Horizontal space between the cards
      runSpacing: 10, // Vertical space between rows of cards
      children: statisticsData.map((stat) {
        return SizedBox(
          width: 300,
          child: CustomCard(
            color: CustomColors.color1,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centering content within the card
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
