package com.example.healthsync

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmService : Service() {
    companion object {
        private const val TAG = "AlarmService"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "alarm_service_channel"
    }

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var tempAlarmFile: java.io.File? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        Log.d(TAG, "AlarmService created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val alarmId = intent?.getStringExtra("alarmId") ?: ""
        val alarmTitle = intent?.getStringExtra("alarmTitle") ?: "Health Alarm"
        val alarmDescription = intent?.getStringExtra("alarmDescription") ?: ""

        Log.d(TAG, "Starting alarm service for: $alarmTitle")

        // Start foreground service
        startForeground(NOTIFICATION_ID, createNotification(alarmTitle, alarmDescription))

        // Start playing alarm sound
        startAlarmSound()
        
        // Start vibration
        startVibration()

        return START_NOT_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Alarm Service",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Background service for health alarms"
                setSound(null, null) // We handle sound separately
                enableVibration(false) // We handle vibration separately
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(title: String, description: String): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("🚨 $title")
            .setContentText(description)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentIntent(pendingIntent)
            .setAutoCancel(false)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .build()
    }

    private fun startAlarmSound() {
        Log.d(TAG, "Starting alarm sound...")
        
        try {
            // Try to use custom alarm sound from assets folder
            Log.d(TAG, "Attempting to load custom alarm from assets")
            val assetManager = assets
            
            // Check if the file exists
            val assetFiles = assetManager.list("sounds")
            Log.d(TAG, "Files in sounds folder: ${assetFiles?.joinToString(", ")}")
            
            val inputStream = assetManager.open("sounds/alarm.mp3")
            Log.d(TAG, "Successfully opened alarm.mp3 from assets")
            
            // Create a temporary file
            tempAlarmFile = java.io.File.createTempFile("alarm", ".mp3", cacheDir)
            Log.d(TAG, "Created temp file: ${tempAlarmFile!!.absolutePath}")
            
            // Copy asset to temp file
            inputStream.use { input ->
                tempAlarmFile!!.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
            
            Log.d(TAG, "Copied asset to temp file, size: ${tempAlarmFile!!.length()} bytes")
            
            mediaPlayer = MediaPlayer().apply {
                setDataSource(tempAlarmFile!!.absolutePath)
                
                // Set audio stream to alarm
                setAudioStreamType(AudioManager.STREAM_ALARM)
                
                // Set looping
                isLooping = true
                
                // Set volume to maximum
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_ALARM)
                val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
                Log.d(TAG, "Alarm volume: $currentVolume/$maxVolume")
                audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxVolume, 0)
                
                prepareAsync()
                setOnPreparedListener { player ->
                    Log.d(TAG, "MediaPlayer prepared, starting playback")
                    player.start()
                    Log.d(TAG, "Custom alarm sound started from assets - isPlaying: ${player.isPlaying}")
                }
                
                setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer error: what=$what, extra=$extra")
                    startFallbackAlarmSound()
                    false
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting custom alarm sound from assets: ${e.message}")
            Log.e(TAG, "Exception details: ", e)
            startFallbackAlarmSound()
        }
    }
    
    private fun startFallbackAlarmSound() {
        Log.d(TAG, "Starting fallback alarm sound...")
        try {
            val systemAlarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            
            Log.d(TAG, "System alarm URI: $systemAlarmUri")
            
            if (systemAlarmUri != null) {
                mediaPlayer = MediaPlayer().apply {
                    setDataSource(this@AlarmService, systemAlarmUri)
                    setAudioStreamType(AudioManager.STREAM_ALARM)
                    isLooping = true
                    
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
                    audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxVolume, 0)
                    Log.d(TAG, "Set alarm volume to maximum: $maxVolume")
                    
                    prepareAsync()
                    setOnPreparedListener { player ->
                        Log.d(TAG, "Fallback MediaPlayer prepared, starting playback")
                        player.start()
                        Log.d(TAG, "Fallback alarm sound started - isPlaying: ${player.isPlaying}")
                    }
                    
                    setOnErrorListener { _, what, extra ->
                        Log.e(TAG, "Fallback MediaPlayer error: what=$what, extra=$extra")
                        false
                    }
                }
            } else {
                Log.e(TAG, "No system alarm URI available")
            }
        } catch (fallbackException: Exception) {
            Log.e(TAG, "Fallback alarm sound failed", fallbackException)
        }
    }

    private fun startVibration() {
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        // Create vibration pattern: vibrate for 1000ms, pause for 500ms, repeat
        val pattern = longArrayOf(0, 1000, 500)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val vibrationEffect = VibrationEffect.createWaveform(pattern, 0)
            vibrator?.vibrate(vibrationEffect)
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(pattern, 0)
        }
        
        Log.d(TAG, "Vibration started")
    }

    fun stopAlarm() {
        Log.d(TAG, "Stopping alarm")
        
        // Stop sound
        mediaPlayer?.let {
            if (it.isPlaying) {
                it.stop()
            }
            it.release()
        }
        mediaPlayer = null

        // Clean up temporary file
        tempAlarmFile?.let {
            if (it.exists()) {
                it.delete()
                Log.d(TAG, "Cleaned up temporary alarm file")
            }
        }
        tempAlarmFile = null

        // Stop vibration
        vibrator?.cancel()
        vibrator = null

        // Stop foreground service
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopAlarm()
        Log.d(TAG, "AlarmService destroyed")
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
