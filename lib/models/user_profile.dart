class UserProfile {
  final String uid;
  final String fullName;
  final DateTime? dateOfBirth;
  final String phoneNumber;
  final List<String> healthIssues;
  final String bloodType;
  final String emergencyContact;
  final String profileImageUrl;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.healthIssues,
    required this.bloodType,
    required this.emergencyContact,
    required this.profileImageUrl,
  });

  UserProfile copyWith({
    String? fullName,
    DateTime? dateOfBirth,
    String? phoneNumber,
    List<String>? healthIssues,
    String? bloodType,
    String? emergencyContact,
    String? profileImageUrl,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      healthIssues: healthIssues ?? this.healthIssues,
      bloodType: bloodType ?? this.bloodType,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'healthIssues': healthIssues,
      'bloodType': bloodType,
      'emergencyContact': emergencyContact,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      fullName: (data['fullName'] as String?) ?? '',
      dateOfBirth: data['dateOfBirth'] != null
          ? DateTime.tryParse(data['dateOfBirth'] as String)
          : null,
      phoneNumber: (data['phoneNumber'] as String?) ?? '',
      healthIssues: (data['healthIssues'] as List<dynamic>? )
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      bloodType: (data['bloodType'] as String?) ?? '',
      emergencyContact: (data['emergencyContact'] as String?) ?? '',
      profileImageUrl: (data['profileImageUrl'] as String?) ?? '',
    );
  }

  static UserProfile empty(String uid) {
    return UserProfile(
      uid: uid,
      fullName: '',
      dateOfBirth: null,
      phoneNumber: '',
      healthIssues: const [],
      bloodType: '',
      emergencyContact: '',
      profileImageUrl: '',
    );
  }
}
