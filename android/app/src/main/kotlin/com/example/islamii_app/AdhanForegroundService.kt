package com.example.islamii_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat

class AdhanForegroundService : Service() {

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null

    companion object {
        const val CHANNEL_ID = "adhan_native_service_channel"
        const val CHANNEL_NAME = "مواقيت الصلاة والأذان"
        const val NOTIFICATION_ID = 888

        const val ACTION_START_ADHAN = "com.example.islamii_app.ACTION_START_ADHAN"
        const val ACTION_STOP_ADHAN = "com.example.islamii_app.ACTION_STOP_ADHAN"

        const val EXTRA_PRAYER_NAME = "extra_prayer_name"
        const val EXTRA_PRAYER_ID = "extra_prayer_id"

        @Volatile
        var isServiceRunning = false
            private set
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        Log.d("AdhanService", "AdhanForegroundService created")
        createNotificationChannel()
        acquireWakeLock()
        requestAudioFocus()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action

        if (action == ACTION_STOP_ADHAN) {
            Log.d("AdhanService", "Received stop action")
            stopAdhanPlayback()
            return START_NOT_STICKY
        }

        val prayerName = intent?.getStringExtra(EXTRA_PRAYER_NAME) ?: "الصلاة"
        Log.d("AdhanService", "Starting Adhan foreground service for: $prayerName")

        isServiceRunning = true

        val notification = buildForegroundNotification(prayerName)
        startForeground(NOTIFICATION_ID, notification)

        startMediaPlayer()

        return START_NOT_STICKY
    }

    private fun startMediaPlayer() {
        try {
            stopMediaPlayer()

            mediaPlayer = MediaPlayer.create(this, R.raw.a4ab138564ce)
            mediaPlayer?.run {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .build()
                )
                isLooping = false
                setOnCompletionListener {
                    Log.d("AdhanService", "Adhan playback completed natively")
                    stopAdhanPlayback()
                }
                setOnErrorListener { _, what, extra ->
                    Log.e("AdhanService", "MediaPlayer error: what=$what, extra=$extra")
                    stopAdhanPlayback()
                    true
                }
                start()
                Log.d("AdhanService", "Adhan MediaPlayer started successfully")
            }
        } catch (e: Exception) {
            Log.e("AdhanService", "Error starting Adhan MediaPlayer: ${e.message}", e)
            stopAdhanPlayback()
        }
    }

    private fun stopAdhanPlayback() {
        isServiceRunning = false
        stopMediaPlayer()
        releaseWakeLock()
        abandonAudioFocus()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    private fun stopMediaPlayer() {
        try {
            mediaPlayer?.run {
                if (isPlaying) {
                    stop()
                }
                release()
            }
        } catch (e: Exception) {
            Log.e("AdhanService", "Error stopping MediaPlayer: ${e.message}")
        } finally {
            mediaPlayer = null
        }
    }

    private fun acquireWakeLock() {
        try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "IslamiApp::AdhanServiceWakeLock"
            ).apply {
                acquire(4 * 60 * 1000L) // 4 minutes timeout safety
            }
        } catch (e: Exception) {
            Log.e("AdhanService", "Error acquiring WakeLock: ${e.message}")
        }
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
            }
        } catch (e: Exception) {
            Log.e("AdhanService", "Error releasing WakeLock: ${e.message}")
        } finally {
            wakeLock = null
        }
    }

    private fun requestAudioFocus() {
        try {
            audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .build()
                    )
                    .setAcceptsDelayedFocusGain(false)
                    .build()
                audioFocusRequest?.let { audioManager?.requestAudioFocus(it) }
            } else {
                @Suppress("DEPRECATION")
                audioManager?.requestAudioFocus(
                    null,
                    AudioManager.STREAM_MUSIC,
                    AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK
                )
            }
        } catch (e: Exception) {
            Log.e("AdhanService", "Error requesting AudioFocus: ${e.message}")
        }
    }

    private fun abandonAudioFocus() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                audioFocusRequest?.let { audioManager?.abandonAudioFocusRequest(it) }
            } else {
                @Suppress("DEPRECATION")
                audioManager?.abandonAudioFocus(null)
            }
        } catch (e: Exception) {
            Log.e("AdhanService", "Error abandoning AudioFocus: ${e.message}")
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "الأذان التلقائي لمواقيت الصلاة"
                setSound(null, null) // Silent channel so MediaPlayer controls full volume
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun buildForegroundNotification(prayerName: String): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val contentPendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val stopIntent = Intent(this, AdhanForegroundService::class.java).apply {
            action = ACTION_STOP_ADHAN
        }
        val stopPendingIntent = PendingIntent.getService(
            this,
            1,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("حان الآن موعد صلاة $prayerName")
            .setContentText("حي على الصلاة .. حي على الفلاح")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(contentPendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .addAction(
                R.mipmap.ic_launcher,
                "إيقاف الأذان",
                stopPendingIntent
            )
            .build()
    }

    override fun onDestroy() {

        stopAdhanPlayback()
        super.onDestroy()
    }
}
