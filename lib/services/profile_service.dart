import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class ProfileService {
  ProfileService._internal();
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProfile> fetchProfile(String uid) async {
    final snapshot = await _firestore.collection('user_profiles').doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return UserProfile.empty(uid);
    }
    return UserProfile.fromMap(uid, snapshot.data()!);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _firestore
        .collection('user_profiles')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

}
