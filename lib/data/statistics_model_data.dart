import 'package:enrollease_web/model/statistics_model.dart';
import 'package:enrollease_web/utils/logos.dart';

class StatisticsModelData {
  final data = const <StatisticsModel>[
    StatisticsModel(
        imageAssets: CustomLogos.newUsers, title: 'New Users', count: '100'),
    StatisticsModel(
        imageAssets: CustomLogos.pendingapproval,
        title: 'Pending Approvals',
        count: '80'),
    StatisticsModel(
        imageAssets: CustomLogos.totalEnrollment,
        title: 'Total Enrolled',
        count: '250'),
  ];
}
