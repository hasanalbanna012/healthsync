class Medicine {
  final String id;
  final String name;
  final String genericName;
  final String imageUrl;

  Medicine({
    required this.id,
    required this.name,
    required this.genericName,
    required this.imageUrl,
  });

  factory Medicine.fromMap(Map<String, dynamic> data, {required String id}) {
    return Medicine(
      id: id,
      name: (data['name'] as String?)?.trim() ?? '',
      genericName:
          (data['genericName'] as String?)?.trim() ?? 'Generic not specified',
      imageUrl: (data['imageUrl'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'genericName': genericName,
      'imageUrl': imageUrl,
    };
  }

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
