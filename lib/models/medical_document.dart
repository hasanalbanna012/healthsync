import 'package:cloud_firestore/cloud_firestore.dart';

enum MedicalDocumentType { prescription, testReport }

extension MedicalDocumentTypeX on MedicalDocumentType {
  String get collectionName => switch (this) {
        MedicalDocumentType.prescription => 'prescriptions',
        MedicalDocumentType.testReport => 'test_reports',
      };

  String get storageFolder => switch (this) {
        MedicalDocumentType.prescription => 'prescriptions',
        MedicalDocumentType.testReport => 'test_reports',
      };

  String get title => switch (this) {
        MedicalDocumentType.prescription => 'Prescriptions',
        MedicalDocumentType.testReport => 'Test Reports',
      };

  String get singularLabel => switch (this) {
        MedicalDocumentType.prescription => 'Prescription',
        MedicalDocumentType.testReport => 'Test Report',
      };

  bool get enableTextDetection => true;
}

class MedicalDocument {
  final String id;
  final String downloadUrl;
  final String storagePath;
  final DateTime dateAdded;
  final String? fileName;

  const MedicalDocument({
    required this.id,
    required this.downloadUrl,
    required this.storagePath,
    required this.dateAdded,
    this.fileName,
  });

  factory MedicalDocument.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data['dateAdded'];
    DateTime date = DateTime.now();
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is int) {
      date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      date = DateTime.tryParse(timestamp) ?? DateTime.now();
    }

    return MedicalDocument(
      id: doc.id,
      downloadUrl: data['downloadUrl'] as String? ?? '',
      storagePath: data['storagePath'] as String? ?? '',
      dateAdded: date,
      fileName: data['fileName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'downloadUrl': downloadUrl,
      'storagePath': storagePath,
      'dateAdded': Timestamp.fromDate(dateAdded),
      'fileName': fileName,
    };
  }
}
