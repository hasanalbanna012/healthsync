package com.example.healthsync

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class AlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "AlarmReceiver"
        private const val CHANNEL = "com.example.healthsync/alarm"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return

        Log.d(TAG, "Alarm received: ${intent.action}")

        when (intent.action) {
            "ALARM_ACTION" -> {
                val alarmId = intent.getStringExtra("alarmId") ?: return
                val alarmTitle = intent.getStringExtra("alarmTitle") ?: "Health Alarm"
                val alarmDescription = intent.getStringExtra("alarmDescription") ?: ""
                
                Log.d(TAG, "Triggering alarm: $alarmId - $alarmTitle")
                
                // Wake up the device
                val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                val wakeLock = powerManager.newWakeLock(
                    PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                    "HealthSync:AlarmWakeLock"
                )
                wakeLock.acquire(10 * 60 * 1000L) // 10 minutes
                
                // Start the alarm service (this plays the sound)
                val serviceIntent = Intent(context, AlarmService::class.java).apply {
                    putExtra("alarmId", alarmId)
                    putExtra("alarmTitle", alarmTitle)
                    putExtra("alarmDescription", alarmDescription)
                }
                context.startForegroundService(serviceIntent)
                
                // Launch the main app and navigate to alarm ring screen
                val alarmIntent = Intent(context, MainActivity::class.java).apply {
                    putExtra("alarmId", alarmId)
                    putExtra("alarmTitle", alarmTitle)
                    putExtra("alarmDescription", alarmDescription)
                    putExtra("showAlarmRing", true)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                           Intent.FLAG_ACTIVITY_CLEAR_TOP or
                           Intent.FLAG_ACTIVITY_SINGLE_TOP
                }
                context.startActivity(alarmIntent)
                
                wakeLock.release()
            }
        }
    }
}
