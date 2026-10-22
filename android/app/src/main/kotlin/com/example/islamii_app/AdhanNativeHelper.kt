package com.example.islamii_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

object AdhanNativeHelper {

    private const val PREFS_NAME = "FlutterSharedPreferences"
    private const val KEY_SCHEDULE_JSON = "flutter.adhan_native_schedule_json"

    private val PRAYER_IDS = intArrayOf(101, 102, 103, 104, 105, 999)

    fun scheduleAlarm(
        context: Context,
        prayerKey: String,
        prayerName: String,
        prayerId: Int,
        triggerTimeMillis: Long
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent = Intent(context, AdhanAlarmReceiver::class.java).apply {
            putExtra("prayer_key", prayerKey)
            putExtra("prayer_name", prayerName)
            putExtra("prayer_id", prayerId)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            prayerId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
            }
            Log.d("AdhanNativeHelper", "Scheduled exact alarm for $prayerKey ($prayerName) ID:$prayerId at $triggerTimeMillis")
        } catch (e: SecurityException) {
            Log.e("AdhanNativeHelper", "SecurityException scheduling exact alarm: ${e.message}")
            try {
                alarmManager.set(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
            } catch (ex: Exception) {
                Log.e("AdhanNativeHelper", "Fallback alarm scheduling failed: ${ex.message}")
            }
        } catch (e: Exception) {
            Log.e("AdhanNativeHelper", "Failed to schedule alarm: ${e.message}", e)
        }
    }

    fun cancelAlarm(context: Context, prayerId: Int) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, AdhanAlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                prayerId,
                intent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
                Log.d("AdhanNativeHelper", "Cancelled alarm for ID: $prayerId")
            }
        } catch (e: Exception) {
            Log.e("AdhanNativeHelper", "Error cancelling alarm $prayerId: ${e.message}")
        }
    }

    fun cancelAllAlarms(context: Context) {
        for (id in PRAYER_IDS) {
            cancelAlarm(context, id)
        }
    }

    fun saveScheduleJson(context: Context, jsonString: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_SCHEDULE_JSON, jsonString).apply()
    }

    fun rescheduleAlarmsFromPrefs(context: Context) {
        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val jsonString = prefs.getString(KEY_SCHEDULE_JSON, null) ?: return
            val now = System.currentTimeMillis()

            val jsonArray = JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                val key = obj.getString("key")
                val name = obj.getString("name")
                val id = obj.getInt("id")
                val timeMillis = obj.getLong("timeMillis")

                if (timeMillis > now) {
                    scheduleAlarm(context, key, name, id, timeMillis)
                }
            }
            Log.d("AdhanNativeHelper", "Successfully restored prayer alarms after reboot.")
        } catch (e: Exception) {
            Log.e("AdhanNativeHelper", "Error rescheduling alarms after reboot: ${e.message}", e)
        }
    }

    fun scheduleTestAdhan(context: Context, delaySeconds: Int) {
        val triggerTime = System.currentTimeMillis() + (delaySeconds * 1000L)
        scheduleAlarm(
            context = context,
            prayerKey = "Test",
            prayerName = "تجريبي",
            prayerId = 999,
            triggerTimeMillis = triggerTime
        )
        Log.d("AdhanNativeHelper", "Test Adhan scheduled in $delaySeconds seconds.")
    }
}
