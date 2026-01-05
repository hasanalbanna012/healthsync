# Hive to Firestore Migration Guide

This guide explains how to move the legacy BMI history that was stored in local Hive boxes into the Firestore collections now used by HealthSync. The same pattern works for any other Hive boxes you may still have access to.

## Data model refresher

Each signed-in user owns the following Firestore subcollections under `users/{uid}`:

| Collection | Purpose | Key fields |
|------------|---------|------------|
| `bmi_records` | Health index entries | `weight`, `height`, `bmi`, `category`, `dateRecorded`, `notes` |
| `alarms` | Alarm definitions | `title`, `description`, `dateTime`, `type`, `repeatDays`, `isActive`, `prescriptionId` |
| `savedMedicines` | Favorite medicines | `name`, `genericName`, `imageUrl` |
| `savedDoctors` | Favorite doctors | `name`, `specialty`, `address`, `contactNumber`, `imageUrl` |
| `prescriptions` | Uploaded prescription files | `downloadUrl`, `storagePath`, `dateAdded`, `fileName` |
| `test_reports` | Uploaded test reports | same as prescriptions |

The migration described below focuses on `bmi_records`, but you can adjust the scripts for the other collections by changing the JSON keys.

## Overview of the migration workflow

1. **Export the legacy Hive box** from a backup of the old app (or from the device/emulator) into a JSON file.
2. **Import the JSON file into Firestore** using the Firebase Admin SDK with a one-off script.
3. **Verify the imported documents** inside the Firebase console and inside the latest copy of the app.

> ⚠️ Keep the migration scripts out of your production app. Run them locally from a secure environment and delete credential files afterwards.

## 1. Export the Hive box

1. Check out the last commit that still contained the Hive dependency, or add Hive temporarily to your local clone (do **not** commit the dependency re-introduction).
2. Create `tool/export_bmi_box.dart` with the following contents:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

class BMIRecordAdapter extends TypeAdapter<Map<String, dynamic>> {
  @override
  int get typeId => 0;

  @override
  Map<String, dynamic> read(BinaryReader reader) {
    final data = <String, dynamic>{};
    final numOfFields = reader.readByte();
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      data['field$key'] = reader.read();
    }
    return data;
  }

  @override
  void write(BinaryWriter writer, Map<String, dynamic> obj) {
    throw UnimplementedError('Only reading is supported in this export script');
  }
}

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run tool/export_bmi_box.dart <box_path> <output_json>');
    exit(1);
  }

  final boxPath = p.normalize(args[0]);
  final outputPath = args[1];

  Hive.init(p.dirname(boxPath));
  Hive.registerAdapter(BMIRecordAdapter());
  final box = await Hive.openBox(boxPath.split(Platform.pathSeparator).last);

  final records = box.values.cast<Map>().map((entry) {
    return {
      'id': entry['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'weight': entry['weight'],
      'height': entry['height'],
      'bmi': entry['bmi'],
      'category': entry['category'],
      'dateRecorded': entry['dateRecorded'],
      'notes': entry['notes'],
    };
  }).toList();

  final file = File(outputPath)..createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(records));
  print('Exported ${records.length} records to $outputPath');
}
```

3. Run the exporter:

```bash
flutter pub get
dart run tool/export_bmi_box.dart \
  "C:/path/to/app/data/bmi_records.hive" \
  migration/bmi_records.json
```

> Replace the Hive file path with the actual file on your emulator/device. On Android emulators it usually lives under `Android/data/<package>/files/bmi_records.hive`.

## 2. Import the JSON file into Firestore

1. Install Node.js 18+ and the Firebase CLI (`npm install -g firebase-tools`).
2. Create a service account from the Firebase console (Project Settings ▶ Service Accounts ▶ Generate new private key) and store the JSON as `serviceAccount.json` **outside** version control.
3. Create `scripts/import_bmi_records.js` with the snippet below:

```js
const fs = require('fs');
const admin = require('firebase-admin');

if (process.argv.length < 4) {
  console.error('Usage: node import_bmi_records.js <serviceAccount.json> <uid> [jsonPath]');
  process.exit(1);
}

const serviceAccount = require(process.argv[2]);
const uid = process.argv[3];
const jsonPath = process.argv[4] || 'migration/bmi_records.json';

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const firestore = admin.firestore();
const records = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

async function run() {
  const batch = firestore.batch();
  const collectionRef = firestore
    .collection('users')
    .doc(uid)
    .collection('bmi_records');

  records.forEach((record) => {
    const docRef = collectionRef.doc(record.id.toString());
    batch.set(docRef, {
      ...record,
      dateRecorded: new Date(record.dateRecorded).toISOString(),
    });
  });

  await batch.commit();
  console.log(`Imported ${records.length} records for ${uid}`);
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
```

4. Run the importer for each affected user:

```bash
node scripts/import_bmi_records.js serviceAccount.json <firebase-uid> migration/bmi_records.json
```

5. Spot-check the newly created documents in the Firebase console.

## 3. Validate in the app

1. Launch the latest HealthSync build and sign in with the migrated account.
2. Open **Health Index** and **Notifications** to ensure BMI history renders and the totals match your exported file.
3. Repeat for other accounts if needed.

## Adjusting for other collections

- **Alarms:** Replace `bmi_records` with `alarms` and keep fields consistent with `lib/models/alarm.dart`.
- **Saved doctors/medicines:** Use `Doctor.toMap()` / `Medicine.toMap()` schemas.
- **Documents:** Besides Firestore documents, you must also upload the actual files to Firebase Storage. Use the `DocumentService` upload logic as reference or manually place files under `users/{uid}/prescriptions/` and `users/{uid}/test_reports/`.

## Rollback plan

If something goes wrong, delete the newly inserted documents from Firestore (filter by `dateAdded`/`createdAt`) and rerun the import after fixing the data. Always keep an untouched copy of the original Hive files until you have verified every migrated account.
