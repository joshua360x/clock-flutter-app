package com.joshua360x.prayeralarm.alarm

import org.json.JSONObject
import java.time.DateTimeException
import java.time.LocalTime
import java.time.ZoneId

/** What to play: a Flutter asset ("assets/...") or a file on the phone. */
data class SoundSpec(val kind: String, val path: String) {
    companion object {
        fun fromJson(json: JSONObject?): SoundSpec? {
            if (json == null) return null
            val kind = json.optString("kind")
            val path = json.optString("path")
            if (kind !in setOf(KIND_ASSET, KIND_FILE) || path.isEmpty()) return null
            return SoundSpec(kind, path)
        }

        const val KIND_ASSET = "asset"
        const val KIND_FILE = "file"
    }
}

/** One prayer alarm as synced from Dart (lib/alarms/schedule_payload.dart). */
data class AlarmSpec(
    val id: Int,
    val key: String,
    val label: String,
    val enabled: Boolean,
    /** Exact AlAdhan times, epoch millis. */
    val instants: List<Long>,
    /** Repeated daily once [instants] run out. */
    val fallback: LocalTime,
    val zone: ZoneId,
    val sound: SoundSpec?,
)

data class Schedule(
    val alarms: List<AlarmSpec>,
    val snoozeMinutes: Int,
    val ringTimeoutMinutes: Int,
    val fallbackSound: SoundSpec?,
) {
    fun alarm(id: Int): AlarmSpec? = alarms.firstOrNull { it.id == id }

    companion object {
        /**
         * Parses the payload. A missing or invalid zone means the phone's
         * current zone, resolved now (so a timezone change is picked up on
         * the next re-arm). Throws on anything structurally wrong.
         */
        fun parse(json: String): Schedule {
            val root = JSONObject(json)
            require(root.optInt("version") == 1) { "unsupported schedule version" }
            val alarms = root.getJSONArray("alarms")
            return Schedule(
                alarms = (0 until alarms.length()).map { i -> parseAlarm(alarms.getJSONObject(i)) },
                snoozeMinutes = root.optInt("snoozeMinutes", 10).coerceIn(1, 60),
                ringTimeoutMinutes = root.optInt("ringTimeoutMinutes", 10).coerceIn(1, 60),
                fallbackSound = SoundSpec.fromJson(root.optJSONObject("fallbackSound")),
            )
        }

        private fun parseAlarm(json: JSONObject): AlarmSpec {
            val instants = json.optJSONArray("instants")
            val (hour, minute) = json.getString("fallback").split(":").map { it.toInt() }
            return AlarmSpec(
                id = json.getInt("id"),
                key = json.getString("key"),
                label = json.getString("label"),
                enabled = json.getBoolean("enabled"),
                instants = if (instants == null) emptyList()
                else (0 until instants.length()).map { instants.getLong(it) },
                fallback = LocalTime.of(hour, minute),
                zone = zoneOrDefault(json.optString("zone")),
                sound = SoundSpec.fromJson(json.optJSONObject("sound")),
            )
        }

        private fun zoneOrDefault(name: String?): ZoneId =
            if (name.isNullOrEmpty() || name == "null") ZoneId.systemDefault()
            else try {
                ZoneId.of(name)
            } catch (e: DateTimeException) {
                ZoneId.systemDefault()
            }
    }
}
