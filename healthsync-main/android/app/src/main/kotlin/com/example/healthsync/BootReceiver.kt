package com.example.healthsync

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return

        Log.d(TAG, "Boot received: ${intent.action}")

        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_PACKAGE_REPLACED -> {
                Log.d(TAG, "Device booted or app updated - restoring alarms")
                
                // Launch the main app to restore alarms
                val appIntent = Intent(context, MainActivity::class.java).apply {
                    putExtra("action", "restore_alarms")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(appIntent)
            }
        }
    }
}
