package com.example.healthsync

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "com.example.healthsync/system_alarm"
        private const val NAVIGATION_CHANNEL = "com.example.healthsync/navigation"
    }

    private var navigationMethodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up navigation channel
        navigationMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NAVIGATION_CHANNEL)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleSystemAlarm" -> {
                    val alarmId = call.argument<String>("alarmId")
                    val alarmTitle = call.argument<String>("alarmTitle")
                    val alarmDescription = call.argument<String>("alarmDescription")
                    val triggerTime = call.argument<Long>("triggerTime")
                    
                    if (alarmId != null && triggerTime != null) {
                        scheduleSystemAlarm(alarmId, alarmTitle, alarmDescription, triggerTime)
                        result.success(true)
                    } else {
                        result.error("INVALID_PARAMS", "Missing required parameters", null)
                    }
                }
                "cancelSystemAlarm" -> {
                    val alarmId = call.argument<String>("alarmId")
                    if (alarmId != null) {
                        cancelSystemAlarm(alarmId)
                        result.success(true)
                    } else {
                        result.error("INVALID_PARAMS", "Missing alarmId", null)
                    }
                }
                "stopAlarmService" -> {
                    stopAlarmService()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleSystemAlarm(alarmId: String, title: String?, description: String?, triggerTime: Long) {
        Log.d(TAG, "Scheduling system alarm: $alarmId at $triggerTime")
        
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            action = "ALARM_ACTION"
            putExtra("alarmId", alarmId)
            putExtra("alarmTitle", title ?: "Health Alarm")
            putExtra("alarmDescription", description ?: "")
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            alarmId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTime,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerTime,
                    pendingIntent
                )
            }
            Log.d(TAG, "System alarm scheduled successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error scheduling system alarm", e)
        }
    }

    private fun cancelSystemAlarm(alarmId: String) {
        Log.d(TAG, "Cancelling system alarm: $alarmId")
        
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            action = "ALARM_ACTION"
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            alarmId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        alarmManager.cancel(pendingIntent)
        Log.d(TAG, "System alarm cancelled")
    }

    private fun stopAlarmService() {
        Log.d(TAG, "Stopping alarm service")
        val serviceIntent = Intent(this, AlarmService::class.java)
        stopService(serviceIntent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleAlarmIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        handleAlarmIntent(intent)
    }

    private fun handleAlarmIntent(intent: Intent?) {
        if (intent?.getBooleanExtra("showAlarmRing", false) == true) {
            val alarmId = intent.getStringExtra("alarmId")
            val alarmTitle = intent.getStringExtra("alarmTitle")
            val alarmDescription = intent.getStringExtra("alarmDescription")
            
            Log.d(TAG, "Received alarm intent for: $alarmId")
            
            // Notify Flutter to show alarm ring screen
            navigationMethodChannel?.invokeMethod("showAlarmRing", mapOf(
                "alarmId" to alarmId,
                "alarmTitle" to alarmTitle,
                "alarmDescription" to alarmDescription
            ))
        }
    }
}
