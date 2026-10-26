package com.joshua360x.prayeralarm.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.joshua360x.prayeralarm.MainActivity
import java.time.Instant

/**
 * Arms one AlarmManager alarm per enabled prayer with setAlarmClock: never
 * deferred by Doze, App Standby, Battery Saver or the "Restricted" battery
 * setting, and shown as the system's next alarm.
 */
object AlarmScheduler {
    const val ACTION_FIRE = "com.joshua360x.prayeralarm.FIRE"
    const val EXTRA_ALARM_ID = "alarmId"
    const val EXTRA_AT = "at"
    const val EXTRA_KIND = "kind"

    const val KIND_SCHEDULED = "scheduled"
    const val KIND_SNOOZE = "snooze"
    const val KIND_TEST = "test"

    private const val SNOOZE_REQUEST_OFFSET = 100
    private const val TEST_REQUEST_CODE = 99

    /**
     * (Re-)arms every prayer for its next ring strictly after [after], and
     * any pending snooze. Idempotent: called on every Dart sync, after each
     * ring, on boot, and on time, timezone or permission changes.
     */
    fun armAll(context: Context, after: Long = System.currentTimeMillis()) {
        val store = ScheduleStore(context)
        val schedule = store.load() ?: return
        val alarmManager = context.getSystemService(AlarmManager::class.java)

        for (spec in schedule.alarms) {
            if (!spec.enabled) {
                alarmManager.cancel(operation(context, spec.id, spec.id, 0L, KIND_SCHEDULED))
                cancelSnooze(context, spec.id)
                continue
            }
            val at = NextRing.next(spec.instants, spec.fallback, spec.zone, Instant.ofEpochMilli(after))
            arm(context, alarmManager, spec.id, spec.id, at.toEpochMilli(), KIND_SCHEDULED)

            val snooze = store.snoozeUntil(spec.id)
            if (snooze != null && snooze > after) {
                arm(context, alarmManager, SNOOZE_REQUEST_OFFSET + spec.id, spec.id, snooze, KIND_SNOOZE)
            } else if (snooze != null) {
                store.clearSnooze(spec.id)
            }
        }
    }

    fun snooze(context: Context, alarmId: Int, minutes: Int) {
        val at = System.currentTimeMillis() + minutes * 60_000L
        ScheduleStore(context).setSnooze(alarmId, at)
        arm(
            context,
            context.getSystemService(AlarmManager::class.java),
            SNOOZE_REQUEST_OFFSET + alarmId,
            alarmId,
            at,
            KIND_SNOOZE,
        )
    }

    fun cancelSnooze(context: Context, alarmId: Int) {
        ScheduleStore(context).clearSnooze(alarmId)
        context.getSystemService(AlarmManager::class.java).cancel(
            operation(context, SNOOZE_REQUEST_OFFSET + alarmId, alarmId, 0L, KIND_SNOOZE),
        )
    }

    /** A one-off alarm for [alarmId]'s label and sound, [delayMillis] from now. */
    fun test(context: Context, alarmId: Int, delayMillis: Long) {
        arm(
            context,
            context.getSystemService(AlarmManager::class.java),
            TEST_REQUEST_CODE,
            alarmId,
            System.currentTimeMillis() + delayMillis,
            KIND_TEST,
        )
    }

    fun canScheduleExact(context: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            context.getSystemService(AlarmManager::class.java).canScheduleExactAlarms()

    private fun arm(
        context: Context,
        alarmManager: AlarmManager,
        requestCode: Int,
        alarmId: Int,
        at: Long,
        kind: String,
    ) {
        val op = operation(context, requestCode, alarmId, at, kind)
        if (canScheduleExact(context)) {
            alarmManager.setAlarmClock(AlarmManager.AlarmClockInfo(at, showIntent(context)), op)
        } else {
            // Exact permission revoked: still ring, possibly a few minutes
            // late. The app shows a notice asking to allow it again.
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, op)
        }
    }

    private fun operation(
        context: Context,
        requestCode: Int,
        alarmId: Int,
        at: Long,
        kind: String,
    ): PendingIntent = PendingIntent.getBroadcast(
        context,
        requestCode,
        Intent(context, AlarmReceiver::class.java)
            .setAction(ACTION_FIRE)
            .putExtra(EXTRA_ALARM_ID, alarmId)
            .putExtra(EXTRA_AT, at)
            .putExtra(EXTRA_KIND, kind),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    /** Tapping the system's "next alarm" indicator opens the app. */
    private fun showIntent(context: Context): PendingIntent = PendingIntent.getActivity(
        context,
        0,
        Intent(context, MainActivity::class.java),
        PendingIntent.FLAG_IMMUTABLE,
    )
}
