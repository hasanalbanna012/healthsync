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
  late final Stream<List<Alarm>> _alarmStream;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _alarmStream = _alarmRepository.watchAlarms();
    _initializeAlarms();
  }

  Future<void> _initializeAlarms() async {
    try {
      await _alarmService.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing alarms: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _toggleAlarm(Alarm alarm, bool isActive) async {
    try {
      if (mounted) {
        setState(() {
          alarm.isActive = isActive;
        });
      }

      final updatedAlarm = alarm.copyWith(isActive: isActive);
      await _alarmRepository.updateAlarm(updatedAlarm);
      await _alarmService.updateAlarmStatus(updatedAlarm);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isActive ? 'Alarm activated' : 'Alarm deactivated',
            ),
            backgroundColor: isActive
                ? AppConstants.primaryColor
                : AppConstants.textDisabledColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          alarm.isActive = !isActive;
        });
      }
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Alarm deleted'),
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
    final messenger = ScaffoldMessenger.of(context);
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddAlarmPage(alarm: alarm),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Alarm updated'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
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
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Alarm>>(
              stream: _alarmStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingLarge),
                      child: Text(
                        'Failed to load alarms. Pull to refresh or try again later.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final alarms = snapshot.data!;
                if (alarms.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildAlarmList(alarms);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAlarmPage(),
            ),
          );
          if (!mounted) return;

          if (result == true) {
            messenger.showSnackBar(
              SnackBar(
                content: const Text('Alarm created'),
                backgroundColor: AppConstants.primaryColor,
              ),
            );
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
          Icon(
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

  Widget _buildAlarmList(List<Alarm> alarms) {
    final activeAlarms = alarms.where((alarm) => alarm.isActive).toList();
    final inactiveAlarms = alarms.where((alarm) => !alarm.isActive).toList();

    return RefreshIndicator(
      onRefresh: () async {
        // Force a one-time fetch to ensure sync completes when user pulls down.
        await _alarmRepository.getAllAlarms();
      },
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
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
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
                ? AppConstants.primaryColor.withValues(alpha: 0.1)
                : AppConstants.textDisabledColor.withValues(alpha: 0.1),
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
              onChanged: (value) => _toggleAlarm(alarm, value),
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
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: AppConstants.primaryColor),
                    title: const Text('Edit'),
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
