package com.joshua360x.prayeralarm.alarm

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Test
import java.io.File
import java.time.LocalTime
import java.time.ZoneId

/** Parses the payload sample the Dart builder is tested against. */
class ScheduleTest {
    private fun sample(): String =
        listOf("../../test/fixtures/schedule_payload_sample.json", "test/fixtures/schedule_payload_sample.json")
            .map(::File)
            .first { it.exists() }
            .readText()

    @Test
    fun parsesTheDartPayload() {
        val schedule = Schedule.parse(sample())

        assertEquals(5, schedule.alarms.size)
        assertEquals(10, schedule.snoozeMinutes)
        assertEquals(SoundSpec("asset", "assets/audio/bell.ogg"), schedule.fallbackSound)
        val fajr = schedule.alarm(1)!!
        assertEquals("fajr", fajr.key)
        assertEquals("Fajr", fajr.label)
        assertEquals(LocalTime.of(5, 43), fajr.fallback)
        assertEquals(ZoneId.of("America/New_York"), fajr.zone)
        assertEquals(listOf(1793007720000L, 1793094180000L), fajr.instants)
        assertEquals(SoundSpec("asset", "assets/audio/custom/default.mp3"), fajr.sound)
        assertFalse(schedule.alarm(2)!!.enabled)
    }

    @Test
    fun missingZoneMeansThePhonesZone() {
        val json = sample().replace("\"America/New_York\"", "null")

        assertEquals(ZoneId.systemDefault(), Schedule.parse(json).alarm(1)!!.zone)
    }

    @Test
    fun unknownSoundKindIsIgnoredNotFatal() {
        val json = sample().replace("\"kind\": \"asset\", \"path\": \"assets/audio/custom/default.mp3\"", "\"kind\": \"tape\", \"path\": \"x\"")

        assertNull(Schedule.parse(json).alarm(1)!!.sound)
    }
}
