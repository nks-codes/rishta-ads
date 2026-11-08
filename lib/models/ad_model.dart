/// A public advertisement as returned by GET ads.php.
/// The phone number is never part of this model.
class Ad {
  const Ad({
    required this.id,
    required this.text,
    required this.city,
    required this.gender,
    required this.age,
    required this.maritalStatus,
    this.daysLeft,
  });

  /// Display ID such as "RCA-000123". Also accepted by reveal-phone.php.
  final String id;
  final String text;
  final String city;
  final String gender;
  final int age;
  final String maritalStatus;
  final int? daysLeft;

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: _asString(json['id']),
      text: _asString(json['text']),
      city: _asString(json['city']),
      gender: _asString(json['gender']),
      age: _asInt(json['age']) ?? 0,
      maritalStatus: _asString(json['marital_status']),
      daysLeft: _asInt(json['days_left']),
    );
  }
}

String _asString(Object? value) => value == null ? '' : value.toString().trim();

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
