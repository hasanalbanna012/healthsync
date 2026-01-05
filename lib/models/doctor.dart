class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String address;
  final String contactNumber;
  final String imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.address,
    required this.contactNumber,
    required this.imageUrl,
  });

  factory Doctor.fromMap(Map<String, dynamic> data, {required String id}) {
    return Doctor(
      id: id,
      name: (data['name'] as String?)?.trim() ?? '',
      specialty:
          (data['specialty'] as String?)?.trim() ?? 'General Practitioner',
      address: (data['address'] as String?)?.trim() ?? 'Address not provided',
      contactNumber: (data['contactNumber'] as String?)?.trim() ?? '',
      imageUrl: (data['imageUrl'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'address': address,
      'contactNumber': contactNumber,
      'imageUrl': imageUrl,
    };
  }

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
