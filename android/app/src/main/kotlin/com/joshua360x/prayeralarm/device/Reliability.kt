package com.joshua360x.prayeralarm.device

import android.Manifest
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import com.joshua360x.prayeralarm.alarm.AlarmScheduler

/**
 * Everything that can stop an alarm from ringing on time, audibly, on
 * screen. Item names are shared with lib/alarms/alarm_engine.dart.
 */
object Reliability {
    const val NOTIFICATIONS = "notifications"
    const val EXACT_ALARMS = "exactAlarms"
    const val FULL_SCREEN = "fullScreen"
    const val BATTERY = "batteryOptimization"
    const val LOCATION = "location"
    const val ALARM_VOLUME = "alarmVolume"

    fun missing(context: Context): List<String> = buildList {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            !granted(context, Manifest.permission.POST_NOTIFICATIONS)
        ) add(NOTIFICATIONS)
        if (!AlarmScheduler.canScheduleExact(context)) add(EXACT_ALARMS)
        if (Build.VERSION.SDK_INT >= 34 &&
            !context.getSystemService(NotificationManager::class.java).canUseFullScreenIntent()
        ) add(FULL_SCREEN)
        if (!context.getSystemService(PowerManager::class.java)
                .isIgnoringBatteryOptimizations(context.packageName)
        ) add(BATTERY)
        if (!granted(context, Manifest.permission.ACCESS_COARSE_LOCATION)) add(LOCATION)
        if (context.getSystemService(AudioManager::class.java)
                .getStreamVolume(AudioManager.STREAM_ALARM) == 0
        ) add(ALARM_VOLUME)
    }

    fun granted(context: Context, permission: String): Boolean =
        context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    /** Runtime permission for an item, if it is one. */
    fun runtimePermission(item: String): String? = when (item) {
        NOTIFICATIONS ->
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) Manifest.permission.POST_NOTIFICATIONS else null
        LOCATION -> Manifest.permission.ACCESS_COARSE_LOCATION
        else -> null
    }

    /** The system screen that fixes a non-runtime item. */
    fun settingsIntent(context: Context, item: String): Intent? {
        val pkg = Uri.parse("package:${context.packageName}")
        return when (item) {
            EXACT_ALARMS ->
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, pkg)
                } else null
            FULL_SCREEN ->
                if (Build.VERSION.SDK_INT >= 34) {
                    Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, pkg)
                } else null
            BATTERY -> Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, pkg)
            ALARM_VOLUME -> Intent(Settings.ACTION_SOUND_SETTINGS)
            // Runtime permissions refused twice can only be changed here.
            NOTIFICATIONS, LOCATION -> appDetails(context)
            else -> null
        }
    }

    fun appDetails(context: Context): Intent =
        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${context.packageName}"))
}
