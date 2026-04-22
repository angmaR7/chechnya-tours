class BookingModel {
  final int id;
  final int? user;
  final int excursion;
  final String excursionTitle;
  final String placeName;
  final String fullName;
  final String phoneNumber;
  final String email;
  final int peopleCount;
  final String totalPrice;
  final String comment;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.user,
    required this.excursion,
    required this.excursionTitle,
    required this.placeName,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.peopleCount,
    required this.totalPrice,
    required this.comment,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      user: json['user'] as int?,
      excursion: json['excursion'] as int,
      excursionTitle: (json['excursion_title'] ?? '') as String,
      placeName: (json['place_name'] ?? '') as String,
      fullName: (json['full_name'] ?? '') as String,
      phoneNumber: (json['phone_number'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      peopleCount: json['people_count'] as int,
      totalPrice: json['total_price'].toString(),
      comment: (json['comment'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}