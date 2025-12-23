class Restroom {
  final int id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String country;
  final double latitude;
  final double longitude;
  final bool ada;
  final bool unisex;
  final String directions;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int upvote;
  final int downvote;
  final String changingTable;

  Restroom({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.ada,
    required this.unisex,
    required this.directions,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.upvote,
    required this.downvote,
    required this.changingTable,
  });

  factory Restroom.fromJson(Map<String, dynamic> json) {
    return Restroom(
      id: json['id']?.toInt() ?? 0,
      name: json['name'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() : 0.0,
      longitude: (json['longitude'] is num) ? (json['longitude'] as num).toDouble() : 0.0,
      ada: json['ada'] ?? false,
      unisex: json['unisex'] ?? false,
      directions: json['directions'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      upvote: json['upvote']?.toInt() ?? 0,
      downvote: json['downvote']?.toInt() ?? 0,
      changingTable: json['changing_table'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'ada': ada,
      'unisex': unisex,
      'directions': directions,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'upvote': upvote,
      'downvote': downvote,
      'changing_table': changingTable,
    };
  }
}

extension ToInt on num? {
  int toInt() => (this ?? 0).toInt();
}