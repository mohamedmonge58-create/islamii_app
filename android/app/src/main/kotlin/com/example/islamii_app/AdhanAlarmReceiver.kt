package com.example.islamii_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat

class AdhanAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val prayerKey = intent.getStringExtra("prayer_key") ?: ""
        val prayerName = intent.getStringExtra("prayer_name") ?: "الصلاة"
        val prayerId = intent.getIntExtra("prayer_id", 0)

        Log.d("AdhanAlarmReceiver", "Received alarm trigger for prayer: $prayerKey ($prayerName), ID: $prayerId")

        // Read SharedPreferences to check user preferences
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val adhanEnabled = prefs.getBoolean("flutter.adhan_enabled", true)
        val prayerEnabled = prefs.getBoolean("flutter.adhan_${prayerKey.lowercase()}", true)

        if (!adhanEnabled) {
            Log.d("AdhanAlarmReceiver", "Adhan is disabled globally by user preference.")
            return
        }

        if (!prayerEnabled) {
            Log.d("AdhanAlarmReceiver", "Adhan for $prayerKey is disabled by user preference.")
            return
        }

        // Start Foreground Service for full-length Adhan playback
        val serviceIntent = Intent(context, AdhanForegroundService::class.java).apply {
            action = AdhanForegroundService.ACTION_START_ADHAN
            putExtra(AdhanForegroundService.EXTRA_PRAYER_NAME, prayerName)
            putExtra(AdhanForegroundService.EXTRA_PRAYER_ID, prayerId)
        }

        try {
            ContextCompat.startForegroundService(context, serviceIntent)
            Log.d("AdhanAlarmReceiver", "Successfully started AdhanForegroundService for $prayerName")
        } catch (e: Exception) {
            Log.e("AdhanAlarmReceiver", "Failed to start AdhanForegroundService: ${e.message}", e)
        }
    }
}
