package com.joshua360x.prayeralarm.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.joshua360x.prayeralarm.ring.RingService

/**
 * An alarm fired: start ringing, then arm that prayer's next time natively,
 * so tomorrow's alarm never depends on the app being opened.
 */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != AlarmScheduler.ACTION_FIRE) return
        val now = System.currentTimeMillis()
        val alarmId = intent.getIntExtra(AlarmScheduler.EXTRA_ALARM_ID, -1)
        val at = intent.getLongExtra(AlarmScheduler.EXTRA_AT, now)
        val kind = intent.getStringExtra(AlarmScheduler.EXTRA_KIND) ?: AlarmScheduler.KIND_SCHEDULED

        if (kind == AlarmScheduler.KIND_SNOOZE) ScheduleStore(context).clearSnooze(alarmId)

        // A late delivery (e.g. the clock was moved forward past this alarm)
        // is not rung at the wrong time; it is only re-armed.
        if (kind == AlarmScheduler.KIND_TEST || now - at <= STALE_AFTER_MILLIS) {
            RingService.start(context, alarmId, at, kind)
        }

        if (kind != AlarmScheduler.KIND_TEST) {
            // Strictly after this ring, even if it was delivered a moment early.
            AlarmScheduler.armAll(context, after = maxOf(now, at) + 1_000L)
        }
    }

    private companion object {
        const val STALE_AFTER_MILLIS = 30 * 60_000L
    }
}
