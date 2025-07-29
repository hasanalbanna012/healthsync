import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/alarm.dart';
import '../repositories/alarm_repository.dart';
import '../services/alarm_service.dart';
import 'add_alarm_page.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final AlarmRepository _alarmRepository = AlarmRepository();
  final AlarmService _alarmService = AlarmService();
  List<Alarm> _alarms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAlarms();
  }

  Future<void> _initializeAlarms() async {
    await _alarmService.initialize();
    await _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    try {
      final alarms = await _alarmRepository.getAllAlarms();
      setState(() {
        _alarms = alarms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading alarms: $e')),
        );
      }
    }
  }

  Future<void> _toggleAlarm(Alarm alarm) async {
    try {
      alarm.isActive = !alarm.isActive;
      await _alarmRepository.updateAlarm(alarm);
      await _alarmService.updateAlarmStatus(alarm);
      await _loadAlarms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              alarm.isActive ? 'Alarm activated' : 'Alarm deactivated',
            ),
            backgroundColor: alarm.isActive
                ? AppConstants.primaryColor
                : AppConstants.textDisabledColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating alarm: $e')),
        );
      }
    }
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    try {
      await _alarmService.cancelAlarm(alarm.id);
      await _alarmRepository.deleteAlarm(alarm.id);
      await _loadAlarms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alarm deleted'),
            backgroundColor: AppConstants.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting alarm: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(Alarm alarm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: Text('Are you sure you want to delete "${alarm.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAlarm(alarm);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _editAlarm(Alarm alarm) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddAlarmPage(alarm: alarm),
      ),
    );

    if (result == true) {
      await _loadAlarms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Alarms'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alarms.isEmpty
              ? _buildEmptyState()
              : _buildAlarmList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAlarmPage(),
            ),
          );
          if (result == true) {
            await _loadAlarms();
          }
        },
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.alarm_off,
            size: 80,
            color: AppConstants.textDisabledColor,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'No Alarms Set',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppConstants.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'Tap the + button to create your first health alarm',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConstants.textDisabledColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmList() {
    final activeAlarms = _alarms.where((alarm) => alarm.isActive).toList();
    final inactiveAlarms = _alarms.where((alarm) => !alarm.isActive).toList();

    return RefreshIndicator(
      onRefresh: _loadAlarms,
      color: AppConstants.primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        children: [
          if (activeAlarms.isNotEmpty) ...[
            _buildSectionHeader('Active Alarms', activeAlarms.length),
            const SizedBox(height: AppConstants.spacingSmall),
            ...activeAlarms.map((alarm) => _buildAlarmCard(alarm)),
            const SizedBox(height: AppConstants.spacingLarge),
          ],
          if (inactiveAlarms.isNotEmpty) ...[
            _buildSectionHeader('Inactive Alarms', inactiveAlarms.length),
            const SizedBox(height: AppConstants.spacingSmall),
            ...inactiveAlarms.map((alarm) => _buildAlarmCard(alarm)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
        ),
        const SizedBox(width: AppConstants.spacingSmall),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingSmall,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmCard(Alarm alarm) {
    final nextAlarmTime = alarm.nextAlarmTime;
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.spacingMedium),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: alarm.isActive
                ? AppConstants.primaryColor.withOpacity(0.1)
                : AppConstants.textDisabledColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              alarm.type.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          alarm.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: alarm.isActive
                    ? AppConstants.textPrimaryColor
                    : AppConstants.textDisabledColor,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alarm.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                alarm.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: alarm.isActive
                          ? AppConstants.textSecondaryColor
                          : AppConstants.textDisabledColor,
                    ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '${timeFormat.format(alarm.dateTime)} • ${alarm.repeatDaysString}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: alarm.isActive
                        ? AppConstants.primaryColor
                        : AppConstants.textDisabledColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (nextAlarmTime != null) ...[
              const SizedBox(height: 2),
              Text(
                'Next: ${dateFormat.format(nextAlarmTime)} at ${timeFormat.format(nextAlarmTime)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: alarm.isActive,
              onChanged: (_) => _toggleAlarm(alarm),
              activeColor: AppConstants.primaryColor,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editAlarm(alarm);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(alarm);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: AppConstants.primaryColor),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
