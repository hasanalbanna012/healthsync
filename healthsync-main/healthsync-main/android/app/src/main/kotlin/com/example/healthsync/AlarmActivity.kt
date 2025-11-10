package com.example.healthsync

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AlarmActivity : FlutterActivity() {
    companion object {
        private const val TAG = "AlarmActivity"
        private const val CHANNEL = "com.example.healthsync/alarm"
    }

    private lateinit var methodChannel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Log.d(TAG, "AlarmActivity created")
        
        // Show on lock screen and turn on screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        
        // Keep screen on
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        
        // Make it full screen
        window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getAlarmData" -> {
                    val alarmId = intent.getStringExtra("alarmId")
                    val alarmTitle = intent.getStringExtra("alarmTitle")
                    val alarmDescription = intent.getStringExtra("alarmDescription")
                    
                    val alarmData = mapOf(
                        "alarmId" to alarmId,
                        "alarmTitle" to alarmTitle,
                        "alarmDescription" to alarmDescription
                    )
                    result.success(alarmData)
                }
                "dismissAlarm" -> {
                    dismissAlarm()
                    result.success(null)
                }
                "snoozeAlarm" -> {
                    val minutes = call.argument<Int>("minutes") ?: 5
                    snoozeAlarm(minutes)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun dismissAlarm() {
        Log.d(TAG, "Dismissing alarm")
        
        // Stop the alarm service
        val serviceIntent = Intent(this, AlarmService::class.java)
        stopService(serviceIntent)
        
        // Close the activity
        finishAndRemoveTask()
    }

    private fun snoozeAlarm(minutes: Int) {
        Log.d(TAG, "Snoozing alarm for $minutes minutes")
        
        // Stop current alarm service
        val serviceIntent = Intent(this, AlarmService::class.java)
        stopService(serviceIntent)
        
        // Schedule snooze (this would need to be implemented in Flutter side)
        val mainIntent = Intent(this, MainActivity::class.java).apply {
            putExtra("action", "snooze_alarm")
            putExtra("alarmId", intent.getStringExtra("alarmId"))
            putExtra("minutes", minutes)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        startActivity(mainIntent)
        
        // Close the activity
        finishAndRemoveTask()
    }

    override fun onBackPressed() {
        // Prevent back button from closing alarm
        Log.d(TAG, "Back button pressed - ignored")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "AlarmActivity destroyed")
    }
}
