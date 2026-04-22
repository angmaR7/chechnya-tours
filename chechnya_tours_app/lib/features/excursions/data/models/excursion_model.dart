class ExcursionModel {
  final int id;
  final int place;
  final String placeName;
  final String title;
  final String description;
  final String guideName;
  final DateTime startDatetime;
  final int durationMinutes;
  final String price;
  final int maxPeople;
  final int bookedPeople;
  final int availablePlaces;
  final String status;
  final bool isActive;
  final String imageUrl;

  const ExcursionModel({
    required this.id,
    required this.place,
    required this.placeName,
    required this.title,
    required this.description,
    required this.guideName,
    required this.startDatetime,
    required this.durationMinutes,
    required this.price,
    required this.maxPeople,
    required this.bookedPeople,
    required this.availablePlaces,
    required this.status,
    required this.isActive,
    required this.imageUrl,
  });

  factory ExcursionModel.fromJson(Map<String, dynamic> json) {
    return ExcursionModel(
      id: json['id'] as int,
      place: json['place'] as int,
      placeName: (json['place_name'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      guideName: (json['guide_name'] ?? '') as String,
      startDatetime: DateTime.parse(json['start_datetime'] as String),
      durationMinutes: json['duration_minutes'] as int,
      price: json['price'].toString(),
      maxPeople: json['max_people'] as int,
      bookedPeople: json['booked_people'] as int,
      availablePlaces: json['available_places'] as int,
      status: (json['status'] ?? '') as String,
      isActive: json['is_active'] as bool,
      imageUrl: (json['place_image_url'] ?? '') as String,
    );
  }
}