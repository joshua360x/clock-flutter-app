package com.joshua360x.prayeralarm.alarm

import java.time.Instant
import java.time.LocalTime
import java.time.ZoneId
import java.time.ZonedDateTime

/**
 * When one prayer alarm rings next. Mirrors nextRingFrom in
 * lib/prayer_times/prayer_schedule.dart; both run
 * test/fixtures/next_ring_cases.json.
 *
 * The first fetched AlAdhan time strictly after [after]; otherwise the next
 * occurrence of [fallback] on [zone]'s wall clock, stepping by calendar day.
 * ZonedDateTime.of shifts a time inside a DST gap forward by the gap and
 * picks the earlier offset in an overlap, which is what the Dart side does.
 */
object NextRing {
    fun next(fetched: List<Long>, fallback: LocalTime, zone: ZoneId, after: Instant): Instant {
        val afterMillis = after.toEpochMilli()
        fetched.filter { it > afterMillis }.minOrNull()?.let { return Instant.ofEpochMilli(it) }

        val today = after.atZone(zone).toLocalDate()
        val candidate = ZonedDateTime.of(today, fallback, zone).toInstant()
        if (candidate.isAfter(after)) return candidate
        return ZonedDateTime.of(today.plusDays(1), fallback, zone).toInstant()
    }
}
