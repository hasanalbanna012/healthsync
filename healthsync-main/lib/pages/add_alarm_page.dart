import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/alarm.dart';
import '../repositories/alarm_repository.dart';
import '../services/alarm_service.dart';

class AddAlarmPage extends StatefulWidget {
  final Alarm? alarm; // For editing existing alarms

  const AddAlarmPage({super.key, this.alarm});

  @override
  State<AddAlarmPage> createState() => _AddAlarmPageState();
}

class _AddAlarmPageState extends State<AddAlarmPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AlarmRepository _alarmRepository = AlarmRepository();
  final AlarmService _alarmService = AlarmService();

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  AlarmType _selectedType = AlarmType.medication;
  final List<int> _selectedDays = [];
  bool _isLoading = false;

  final List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      // Initialize with existing alarm data for editing
      _initializeForEditing();
    }
  }

  void _initializeForEditing() {
    final alarm = widget.alarm!;
    _titleController.text = alarm.title;
    _descriptionController.text = alarm.description;
    _selectedDateTime = alarm.dateTime;
    _selectedType = alarm.type;
    _selectedDays.clear();
    _selectedDays.addAll(alarm.repeatDays);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    // Ensure initialDate is not before firstDate
    final initialDate =
        _selectedDateTime.isBefore(now) ? now : _selectedDateTime;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveAlarm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final alarm = Alarm(
        id: widget.alarm?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: _selectedDateTime,
        type: _selectedType,
        repeatDays: _selectedDays,
        createdAt: widget.alarm?.createdAt ?? DateTime.now(),
      );

      await _alarmRepository.saveAlarm(alarm);
      await _alarmService.scheduleAlarm(alarm);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.alarm != null
                ? 'Alarm updated successfully!'
                : 'Alarm created successfully!'),
            backgroundColor: AppConstants.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating alarm: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm != null ? 'Edit Alarm' : 'Add Alarm'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAlarm,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Alarm Title',
                        hintText: 'e.g., Take Morning Medicine',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an alarm title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Additional details about this alarm',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alarm Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    DropdownButtonFormField<AlarmType>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Type',
                      ),
                      items: AlarmType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Text(type.icon,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(type.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date & Time',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(DateFormat('MMM dd, yyyy - h:mm a')
                          .format(_selectedDateTime)),
                      subtitle: const Text('Tap to change'),
                      onTap: _selectDateTime,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Repeat Days',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Text(
                      'Select days to repeat this alarm (leave empty for one-time)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.textSecondaryColor,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Wrap(
                      spacing: 8,
                      children: List.generate(_dayNames.length, (index) {
                        final dayNumber = index + 1;
                        final isSelected = _selectedDays.contains(dayNumber);
                        return FilterChip(
                          label: Text(_dayNames[index].substring(0, 3)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedDays.add(dayNumber);
                              } else {
                                _selectedDays.remove(dayNumber);
                              }
                              _selectedDays.sort();
                            });
                          },
                          selectedColor:
                              AppConstants.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppConstants.primaryColor,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
