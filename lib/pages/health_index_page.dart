import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/bmi_record.dart';
import '../constants/app_constants.dart';

class HealthIndexPage extends StatefulWidget {
  const HealthIndexPage({super.key});

  @override
  State<HealthIndexPage> createState() => _HealthIndexPageState();
}

class _HealthIndexPageState extends State<HealthIndexPage> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double? _calculatedBMI;
  String? _bmiCategory;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    if (_formKey.currentState!.validate()) {
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);

      final bmi = BMIRecord.calculateBMI(weight, height);
      final category = BMIRecord.getBMICategory(bmi);

      setState(() {
        _calculatedBMI = bmi;
        _bmiCategory = category;
      });
    }
  }

  Future<void> _saveBMIRecord() async {
    if (_calculatedBMI == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please calculate BMI first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final record = BMIRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      bmi: _calculatedBMI!,
      category: _bmiCategory!,
      dateRecorded: DateTime.now(),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    await Hive.box<BMIRecord>('bmi_records').add(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BMI record saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
      _weightController.clear();
      _heightController.clear();
      _notesController.clear();
      setState(() {
        _calculatedBMI = null;
        _bmiCategory = null;
      });
    }
  }

  Color _getBMIColor(String category) {
    switch (category) {
      case 'Underweight':
        return Colors.blue;
      case 'Normal weight':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Health Index'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.health_and_safety,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'BMI Calculator',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Calculate and track your Body Mass Index',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // BMI Calculator Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter Your Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Weight Input
                      TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          prefixIcon: Icon(Icons.monitor_weight),
                          border: OutlineInputBorder(),
                          suffixText: 'kg',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          final weight = double.parse(value);
                          if (weight <= 0 || weight > 500) {
                            return 'Please enter a valid weight (1-500 kg)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Height Input
                      TextFormField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          prefixIcon: Icon(Icons.height),
                          border: OutlineInputBorder(),
                          suffixText: 'cm',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          final height = double.parse(value);
                          if (height <= 0 || height > 300) {
                            return 'Please enter a valid height (1-300 cm)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Notes Input
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          prefixIcon: Icon(Icons.note),
                          border: OutlineInputBorder(),
                          hintText: 'Add any notes about this measurement...',
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 20),

                      // Calculate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateBMI,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Calculate BMI',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // BMI Result
            if (_calculatedBMI != null) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Your BMI Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getBMIColor(_bmiCategory!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getBMIColor(_bmiCategory!),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _calculatedBMI!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _getBMIColor(_bmiCategory!),
                              ),
                            ),
                            Text(
                              _bmiCategory!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _getBMIColor(_bmiCategory!),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // BMI Categories Reference
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMI Categories:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.circle,
                                    color: Colors.blue, size: 12),
                                SizedBox(width: 8),
                                Text('Underweight: Below 18.5'),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.circle,
                                    color: Colors.green, size: 12),
                                SizedBox(width: 8),
                                Text('Normal: 18.5 - 24.9'),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.circle,
                                    color: Colors.orange, size: 12),
                                SizedBox(width: 8),
                                Text('Overweight: 25.0 - 29.9'),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.circle, color: Colors.red, size: 12),
                                SizedBox(width: 8),
                                Text('Obese: 30.0 and above'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveBMIRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Save to History'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // History Section
            const Text(
              'BMI History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ValueListenableBuilder(
              valueListenable: Hive.box<BMIRecord>('bmi_records').listenable(),
              builder: (context, Box<BMIRecord> box, _) {
                if (box.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No BMI records yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Calculate and save your first BMI to see history',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final records = box.values.toList().reversed.toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getBMIColor(record.category),
                          child: Text(
                            record.bmi.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          record.category,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _getBMIColor(record.category),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weight: ${record.weight}kg • Height: ${record.height}cm',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              _formatDate(record.dateRecorded),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (record.notes != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                record.notes!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await record.delete();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Record deleted'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
