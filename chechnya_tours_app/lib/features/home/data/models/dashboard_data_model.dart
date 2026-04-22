import '../../../excursions/data/models/excursion_model.dart';

class DashboardDataModel {
  final String? userName;
  final int totalExcursions;
  final int availableExcursions;
  final int myBookingsCount;
  final ExcursionModel? nearestExcursion;

  const DashboardDataModel({
    required this.userName,
    required this.totalExcursions,
    required this.availableExcursions,
    required this.myBookingsCount,
    required this.nearestExcursion,
  });
}