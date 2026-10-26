package com.joshua360x.prayeralarm.ring

import android.app.ForegroundServiceStartNotAllowedException
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import com.joshua360x.prayeralarm.MainActivity
import com.joshua360x.prayeralarm.R
import com.joshua360x.prayeralarm.alarm.AlarmScheduler
import com.joshua360x.prayeralarm.alarm.ScheduleStore
import java.text.DateFormat
import java.util.Date

/**
 * Rings an alarm as a foreground service: audio, wake lock, and a
 * full-screen notification that opens the alarm screen over the lock
 * screen. Dismiss and Snooze work from the notification without Flutter.
 * Stops by itself after the schedule's ring timeout.
 */
class RingService : Service() {
    private var audio: AlarmAudio? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private val handler = Handler(Looper.getMainLooper())
    private val timeout = Runnable { stopRinging() }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_RING -> ring(intent)
            ACTION_DISMISS -> stopRinging()
            ACTION_SNOOZE -> snooze()
            else -> if (RingState.current == null) stopSelf()
        }
        return START_NOT_STICKY
    }

    private fun ring(intent: Intent) {
        val alarmId = intent.getIntExtra(AlarmScheduler.EXTRA_ALARM_ID, -1)
        val at = intent.getLongExtra(AlarmScheduler.EXTRA_AT, System.currentTimeMillis())
        val kind = intent.getStringExtra(AlarmScheduler.EXTRA_KIND) ?: AlarmScheduler.KIND_SCHEDULED
        val schedule = ScheduleStore(this).load()
        val spec = schedule?.alarm(alarmId)
        val ringing = Ringing(alarmId, spec?.key ?: "alarm", spec?.label ?: "Prayer", at, kind)

        if (schedule == null || spec == null ||
            (kind == AlarmScheduler.KIND_SCHEDULED && !spec.enabled)
        ) {
            // startForegroundService requires startForeground, even when the
            // alarm turns out to be stale.
            goForeground(notification(ringing))
            stopRinging()
            return
        }

        // State first: the full-screen notification may launch the activity
        // immediately, and it reads this to show over the lock screen.
        RingState.update(ringing)
        goForeground(notification(ringing))
        audio?.stop()
        audio = (audio ?: AlarmAudio(this)).also { it.play(listOf(spec.sound, schedule.fallbackSound)) }
        val timeoutMillis = schedule.ringTimeoutMinutes * 60_000L
        if (wakeLock?.isHeld != true) {
            wakeLock = getSystemService(PowerManager::class.java)
                .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "PrayerAlarm:ring")
                .apply { acquire(timeoutMillis + 5_000L) }
        }
        handler.removeCallbacks(timeout)
        handler.postDelayed(timeout, timeoutMillis)
    }

    private fun snooze() {
        val ringing = RingState.current
        stopRinging()
        if (ringing != null && ringing.kind != AlarmScheduler.KIND_TEST) {
            val minutes = ScheduleStore(this).load()?.snoozeMinutes ?: 10
            AlarmScheduler.snooze(this, ringing.alarmId, minutes)
        }
    }

    private fun stopRinging() {
        handler.removeCallbacks(timeout)
        audio?.stop()
        audio = null
        wakeLock?.takeIf { it.isHeld }?.release()
        wakeLock = null
        RingState.update(null)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        handler.removeCallbacks(timeout)
        audio?.stop()
        wakeLock?.takeIf { it.isHeld }?.release()
        if (RingState.current != null) RingState.update(null)
        super.onDestroy()
    }

    private fun goForeground(notification: Notification) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun notification(ringing: Ringing): Notification {
        ensureChannel(this)
        val open = PendingIntent.getActivity(
            this,
            REQUEST_OPEN,
            Intent(this, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                .putExtra(MainActivity.EXTRA_FROM_ALARM, true),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val time = DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(ringing.at))
        return Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_alarm)
            .setContentTitle(ringing.label)
            .setContentText("Time to pray · $time")
            .setCategory(Notification.CATEGORY_ALARM)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setShowWhen(false)
            .setContentIntent(open)
            .setFullScreenIntent(open, true)
            .addAction(Notification.Action.Builder(null, "Dismiss", command(ACTION_DISMISS, REQUEST_DISMISS)).build())
            .addAction(Notification.Action.Builder(null, "Snooze", command(ACTION_SNOOZE, REQUEST_SNOOZE)).build())
            .build()
    }

    private fun command(action: String, requestCode: Int): PendingIntent = PendingIntent.getService(
        this,
        requestCode,
        Intent(this, RingService::class.java).setAction(action),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    companion object {
        private const val TAG = "RingService"
        const val ACTION_RING = "com.joshua360x.prayeralarm.RING"
        const val ACTION_DISMISS = "com.joshua360x.prayeralarm.DISMISS"
        const val ACTION_SNOOZE = "com.joshua360x.prayeralarm.SNOOZE"
        const val CHANNEL_ID = "prayer_alarms"
        private const val NOTIFICATION_ID = 1
        private const val REQUEST_OPEN = 1
        private const val REQUEST_DISMISS = 2
        private const val REQUEST_SNOOZE = 3

        fun start(context: Context, alarmId: Int, at: Long, kind: String) {
            val intent = Intent(context, RingService::class.java)
                .setAction(ACTION_RING)
                .putExtra(AlarmScheduler.EXTRA_ALARM_ID, alarmId)
                .putExtra(AlarmScheduler.EXTRA_AT, at)
                .putExtra(AlarmScheduler.EXTRA_KIND, kind)
            try {
                context.startForegroundService(intent)
            } catch (e: Exception) {
                // Only possible if the alarm was not exact (permission revoked)
                // and Android refused a background start. Logged; the app's
                // notice asks the user to allow exact alarms again.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                    e is ForegroundServiceStartNotAllowedException
                ) {
                    Log.e(TAG, "Foreground start not allowed", e)
                } else {
                    throw e
                }
            }
        }

        /** Dismiss or snooze from the app (only acts if something is ringing). */
        fun command(context: Context, action: String) {
            if (RingState.current == null) return
            context.startService(Intent(context, RingService::class.java).setAction(action))
        }

        /** High importance so the full-screen intent can show; silent, since
         *  the service plays the audio itself on the alarm stream. */
        fun ensureChannel(context: Context) {
            val manager = context.getSystemService(NotificationManager::class.java)
            if (manager.getNotificationChannel(CHANNEL_ID) != null) return
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "Prayer alarms", NotificationManager.IMPORTANCE_HIGH).apply {
                    description = "Rings at each prayer time"
                    setSound(null, null)
                    enableVibration(false)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                },
            )
        }
    }
}
