class BMIRecord {
  String id;
  double weight; // in kg
  double height; // in cm
  double bmi;
  String category;
  DateTime dateRecorded;
  String? notes;

  BMIRecord({
    required this.id,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.category,
    required this.dateRecorded,
    this.notes,
  });

  BMIRecord copyWith({
    String? id,
    double? weight,
    double? height,
    double? bmi,
    String? category,
    DateTime? dateRecorded,
    String? notes,
  }) {
    return BMIRecord(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      category: category ?? this.category,
      dateRecorded: dateRecorded ?? this.dateRecorded,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'category': category,
      'dateRecorded': dateRecorded.toIso8601String(),
      'notes': notes,
    };
  }

  factory BMIRecord.fromMap(Map<String, dynamic> data) {
    final dateValue = data['dateRecorded'];
    DateTime parsedDate;
    if (dateValue is DateTime) {
      parsedDate = dateValue;
    } else if (dateValue is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else if (dateValue is String) {
      parsedDate = DateTime.tryParse(dateValue) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return BMIRecord(
      id: (data['id'] as String?) ?? '',
      weight: (data['weight'] as num?)?.toDouble() ?? 0,
      height: (data['height'] as num?)?.toDouble() ?? 0,
      bmi: (data['bmi'] as num?)?.toDouble() ?? 0,
      category: (data['category'] as String?) ?? 'Unknown',
      dateRecorded: parsedDate,
      notes: data['notes'] as String?,
    );
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal weight';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  static double calculateBMI(double weight, double height) {
    // height in cm, weight in kg
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }
}
