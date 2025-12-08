import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 6)
class Medicine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String genericName;

  @HiveField(3)
  final String imageUrl;

  Medicine({
    required this.id,
    required this.name,
    required this.genericName,
    required this.imageUrl,
  });

  static String buildId(String name, String generic, int index) {
    final base = '$name-$generic-$index'.toLowerCase();
    return base.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? genericName,
    String? imageUrl,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
