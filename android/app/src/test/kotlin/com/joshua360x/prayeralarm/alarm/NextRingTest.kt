package com.joshua360x.prayeralarm.alarm

import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File
import java.time.Instant
import java.time.LocalTime
import java.time.ZoneId

/**
 * Runs the cases shared with the Dart scheduler
 * (test/prayer_times/next_ring_cases_test.dart), so both sides agree on
 * when an alarm rings. Gradle runs unit tests from android/app.
 */
class NextRingTest {
    private fun fixture(): JSONObject {
        val file = listOf("../../test/fixtures/next_ring_cases.json", "test/fixtures/next_ring_cases.json")
            .map(::File)
            .first { it.exists() }
        return JSONObject(file.readText())
    }

    @Test
    fun sharedCases() {
        val cases = fixture().getJSONArray("cases")
        assertTrue(cases.length() >= 10)
        for (i in 0 until cases.length()) {
            val c = cases.getJSONObject(i)
            val fetched = c.getJSONArray("fetched").let { a ->
                (0 until a.length()).map { Instant.parse(a.getString(it)).toEpochMilli() }
            }
            val (hour, minute) = c.getString("fallback").split(":").map { it.toInt() }
            val actual = NextRing.next(
                fetched,
                LocalTime.of(hour, minute),
                ZoneId.of(c.getString("zone")),
                Instant.parse(c.getString("now")),
            )
            assertEquals(c.getString("name"), Instant.parse(c.getString("expected")), actual)
        }
    }
}
