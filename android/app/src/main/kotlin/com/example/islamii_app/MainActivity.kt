package com.example.islamii_app

import android.content.Intent
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : AudioServiceActivity() {

    companion object {
        private const val CHANNEL = "com.example.islamii_app/adhan"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleNativeAdhan" -> {
                    val prayersList = call.argument<List<Map<String, Any>>>("prayers")
                    val jsonArray = JSONArray()

                    if (prayersList != null) {
                        for (prayer in prayersList) {
                            val key = prayer["key"] as? String ?: continue
                            val name = prayer["name"] as? String ?: continue
                            val id = (prayer["id"] as? Number)?.toInt() ?: continue
                            val timeMillis = (prayer["timeMillis"] as? Number)?.toLong() ?: continue

                            AdhanNativeHelper.scheduleAlarm(context, key, name, id, timeMillis)

                            val jsonObj = org.json.JSONObject().apply {
                                put("key", key)
                                put("name", name)
                                put("id", id)
                                put("timeMillis", timeMillis)
                            }
                            jsonArray.put(jsonObj)
                        }
                        AdhanNativeHelper.saveScheduleJson(context, jsonArray.toString())
                    }
                    result.success(true)
                }

                "stopNativeAdhan" -> {
                    val stopIntent = Intent(context, AdhanForegroundService::class.java).apply {
                        action = AdhanForegroundService.ACTION_STOP_ADHAN
                    }
                    context.startService(stopIntent)
                    result.success(true)
                }

                "cancelAllNativeAdhan" -> {
                    AdhanNativeHelper.cancelAllAlarms(context)
                    result.success(true)
                }

                "scheduleTestAdhan" -> {
                    val delaySeconds = call.argument<Int>("delaySeconds") ?: 10
                    AdhanNativeHelper.scheduleTestAdhan(context, delaySeconds)
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }
}
