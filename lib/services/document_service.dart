import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/medical_document.dart';

class DocumentService {
  DocumentService._internal();
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _collection(
    String uid,
    MedicalDocumentType type,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection(type.collectionName);
  }

  Future<MedicalDocument> uploadDocument({
    required MedicalDocumentType type,
    required XFile file,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to upload files.');
    }

    final uid = user.uid;
    final docId = DateTime.now().millisecondsSinceEpoch.toString();
    final storagePath =
        'users/$uid/${type.storageFolder}/${docId}_${file.name}';

    final ref = _storage.ref(storagePath);
    await ref.putFile(File(file.path));
    final downloadUrl = await ref.getDownloadURL();

    final document = MedicalDocument(
      id: docId,
      downloadUrl: downloadUrl,
      storagePath: storagePath,
      dateAdded: DateTime.now(),
      fileName: file.name,
    );

    await _collection(uid, type).doc(docId).set(document.toMap());
    return document;
  }

  Stream<List<MedicalDocument>> watchDocuments(
    String uid,
    MedicalDocumentType type,
  ) {
    return _collection(uid, type)
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(MedicalDocument.fromDoc).toList(growable: false));
  }

  Future<void> deleteDocument(
    String uid,
    MedicalDocumentType type,
    MedicalDocument document,
  ) async {
    await _collection(uid, type).doc(document.id).delete();
    if (document.storagePath.isNotEmpty) {
      await _storage.ref(document.storagePath).delete();
    }
  }
}
