import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bmi_record.dart';

class HealthIndexService {
  HealthIndexService._internal();
  static final HealthIndexService _instance = HealthIndexService._internal();
  factory HealthIndexService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _recordsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('bmi_records');
  }

  Future<void> saveRecord(String uid, BMIRecord record) async {
    final data = record.toMap();
    data['dateRecorded'] = Timestamp.fromDate(record.dateRecorded);
    await _recordsRef(uid).doc(record.id).set(data);
  }

  Future<void> deleteRecord(String uid, String recordId) {
    return _recordsRef(uid).doc(recordId).delete();
  }

  Stream<List<BMIRecord>> watchRecords(String uid) {
    return _recordsRef(uid)
        .orderBy('dateRecorded', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Normalize Firestore timestamp for BMIRecord factory.
        final normalized = {
          ...data,
          'id': doc.id,
          'dateRecorded':
              (data['dateRecorded'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
        return BMIRecord.fromMap(normalized);
      }).toList();
    });
  }
}
