import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/alarm.dart';

class AlarmRepository {
  AlarmRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _alarmsCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    return _firestore.collection('users').doc(uid).collection('alarms');
  }

  Future<List<Alarm>> getAllAlarms() async {
    final snapshot = await _alarmsCollection.orderBy('dateTime').get();
    return snapshot.docs
        .map((doc) => Alarm.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  Future<List<Alarm>> getActiveAlarms() async {
    final snapshot =
        await _alarmsCollection.where('isActive', isEqualTo: true).get();
    final alarms = snapshot.docs
        .map((doc) => Alarm.fromMap(doc.data(), id: doc.id))
        .toList();
    alarms.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return alarms;
  }

  Future<List<Alarm>> getUpcomingAlarms({int days = 7}) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    final activeAlarms = await getActiveAlarms();

    return activeAlarms.where((alarm) {
      final nextTime = alarm.nextAlarmTime;
      return nextTime != null &&
          nextTime.isAfter(now) &&
          nextTime.isBefore(endDate);
    }).toList();
  }

  Future<List<Alarm>> getAlarmsByType(AlarmType type) async {
    final snapshot =
        await _alarmsCollection.where('type', isEqualTo: type.name).get();
    final alarms = snapshot.docs
        .map((doc) => Alarm.fromMap(doc.data(), id: doc.id))
        .toList();
    alarms.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return alarms;
  }

  Future<List<Alarm>> getMedicationAlarms() async {
    return getAlarmsByType(AlarmType.medication);
  }

  Future<Alarm?> getAlarmById(String id) async {
    final doc = await _alarmsCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return Alarm.fromMap(doc.data()!, id: doc.id);
  }

  Future<void> saveAlarm(Alarm alarm) async {
    await _alarmsCollection.doc(alarm.id).set(alarm.toMap());
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await _alarmsCollection.doc(alarm.id).set(alarm.toMap());
  }

  Future<void> deleteAlarm(String id) async {
    await _alarmsCollection.doc(id).delete();
  }

  Future<void> toggleAlarmStatus(String id) async {
    final alarm = await getAlarmById(id);
    if (alarm == null) return;

    await updateAlarm(alarm.copyWith(isActive: !alarm.isActive));
  }

  Future<void> deleteAllAlarms() async {
    final snapshot = await _alarmsCollection.get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<int> getAlarmCount() async {
    final snapshot = await _alarmsCollection.get();
    return snapshot.size;
  }

  Future<int> getActiveAlarmCount() async {
    final snapshot =
        await _alarmsCollection.where('isActive', isEqualTo: true).get();
    return snapshot.size;
  }

  Stream<List<Alarm>> watchAlarms() {
    return _alarmsCollection.orderBy('dateTime').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Alarm.fromMap(doc.data(), id: doc.id))
            .toList());
  }

  Stream<List<Alarm>> watchActiveAlarms() {
    return _alarmsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final alarms = snapshot.docs
          .map((doc) => Alarm.fromMap(doc.data(), id: doc.id))
          .toList();
      alarms.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return alarms;
    });
  }
}
