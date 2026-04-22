import '../../../../core/storage/token_storage.dart';
import '../../../bookings/data/services/booking_service.dart';
import '../../../excursions/data/models/excursion_model.dart';
import '../../../excursions/data/services/excursion_service.dart';
import '../../../profile/data/services/profile_service.dart';
import '../models/dashboard_data_model.dart';

class DashboardService {
  final ExcursionService _excursionService = ExcursionService();
  final BookingService _bookingService = BookingService();
  final ProfileService _profileService = ProfileService();

  Future<DashboardDataModel> getDashboardData() async {
    final excursions = await _excursionService.getExcursions();

    final sortedExcursions = [...excursions]
      ..sort((a, b) => a.startDatetime.compareTo(b.startDatetime));

    final nearestExcursion = sortedExcursions.isNotEmpty
        ? sortedExcursions.first
        : null;

    final availableExcursions =
        excursions.where((item) => item.availablePlaces > 0).length;

    final accessToken = await TokenStorage.getAccessToken();

    String? userName;
    int myBookingsCount = 0;

    if (accessToken != null && accessToken.isNotEmpty) {
      try {
        final profile = await _profileService.getMe();
        final fullName = '${profile.firstName} ${profile.lastName}'.trim();
        userName = fullName.isEmpty ? profile.username : fullName;
      } catch (_) {}

      try {
        final bookings = await _bookingService.getMyBookings();
        myBookingsCount = bookings.length;
      } catch (_) {}
    }

    return DashboardDataModel(
      userName: userName,
      totalExcursions: excursions.length,
      availableExcursions: availableExcursions,
      myBookingsCount: myBookingsCount,
      nearestExcursion: nearestExcursion,
    );
  }
}