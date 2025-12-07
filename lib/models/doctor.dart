import 'package:hive/hive.dart';

part 'doctor.g.dart';

@HiveType(typeId: 5)
class Doctor extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String specialty;

  @HiveField(3)
  final String address;

  @HiveField(4)
  final String contactNumber;

  @HiveField(5)
  final String imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.address,
    required this.contactNumber,
    required this.imageUrl,
  });

  static String buildId(String name, String specialty, int index) {
    final base = '$name-$specialty-$index'.toLowerCase();
    return base.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  }

  Doctor copyWith({
    String? id,
    String? name,
    String? specialty,
    String? address,
    String? contactNumber,
    String? imageUrl,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
