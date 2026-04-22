import 'place_in_excursion_model.dart';

class ExcursionDetailModel {
  final int id;
  final PlaceInExcursionModel place;
  final String title;
  final String description;
  final String guideName;
  final DateTime startDatetime;
  final int durationMinutes;
  final String price;
  final int maxPeople;
  final int bookedPeople;
  final int availablePlaces;
  final bool isBookable;
  final String status;
  final bool isActive;

  const ExcursionDetailModel({
    required this.id,
    required this.place,
    required this.title,
    required this.description,
    required this.guideName,
    required this.startDatetime,
    required this.durationMinutes,
    required this.price,
    required this.maxPeople,
    required this.bookedPeople,
    required this.availablePlaces,
    required this.isBookable,
    required this.status,
    required this.isActive,
  });

  factory ExcursionDetailModel.fromJson(Map<String, dynamic> json) {
    return ExcursionDetailModel(
      id: json['id'] as int,
      place: PlaceInExcursionModel.fromJson(
        Map<String, dynamic>.from(json['place'] as Map),
      ),
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      guideName: (json['guide_name'] ?? '') as String,
      startDatetime: DateTime.parse(json['start_datetime'] as String),
      durationMinutes: json['duration_minutes'] as int,
      price: json['price'].toString(),
      maxPeople: json['max_people'] as int,
      bookedPeople: json['booked_people'] as int,
      availablePlaces: json['available_places'] as int,
      isBookable: json['is_bookable'] as bool,
      status: (json['status'] ?? '') as String,
      isActive: json['is_active'] as bool,
    );
  }
}