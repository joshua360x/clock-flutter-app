package com.joshua360x.prayeralarm.alarm

import android.content.Context

/**
 * The engine's own copy of the schedule, written whenever Dart syncs, so
 * alarms can be re-armed after boot or a time change without the app.
 */
class ScheduleStore(context: Context) {
    private val prefs = context.applicationContext
        .getSharedPreferences("prayer_alarm_engine", Context.MODE_PRIVATE)

    fun save(json: String) {
        prefs.edit().putString(KEY_SCHEDULE, json).apply()
    }

    /** Null when nothing was synced yet or the stored copy is unreadable. */
    fun load(): Schedule? = prefs.getString(KEY_SCHEDULE, null)?.let {
        runCatching { Schedule.parse(it) }.getOrNull()
    }

    fun snoozeUntil(alarmId: Int): Long? =
        prefs.getLong(snoozeKey(alarmId), 0L).takeIf { it > 0L }

    fun setSnooze(alarmId: Int, at: Long) {
        prefs.edit().putLong(snoozeKey(alarmId), at).apply()
    }

    fun clearSnooze(alarmId: Int) {
        prefs.edit().remove(snoozeKey(alarmId)).apply()
    }

    private fun snoozeKey(alarmId: Int) = "snooze.$alarmId"

    private companion object {
        const val KEY_SCHEDULE = "schedule.v1"
    }
}
