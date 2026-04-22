class PlaceInExcursionModel {
  final int id;
  final String name;
  final String slug;
  final String shortDescription;
  final String description;
  final String city;
  final String district;
  final String address;
  final String? latitude;
  final String? longitude;
  final String imageUrl;

  const PlaceInExcursionModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.shortDescription,
    required this.description,
    required this.city,
    required this.district,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  factory PlaceInExcursionModel.fromJson(Map<String, dynamic> json) {
    return PlaceInExcursionModel(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      slug: (json['slug'] ?? '') as String,
      shortDescription: (json['short_description'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      district: (json['district'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      imageUrl: (json['image_url'] ?? '') as String,
    );
  }
}