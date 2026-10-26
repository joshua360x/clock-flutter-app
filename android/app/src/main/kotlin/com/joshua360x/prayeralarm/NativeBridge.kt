package com.joshua360x.prayeralarm

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.pm.PackageManager
import com.joshua360x.prayeralarm.alarm.AlarmScheduler
import com.joshua360x.prayeralarm.alarm.Schedule
import com.joshua360x.prayeralarm.alarm.ScheduleStore
import com.joshua360x.prayeralarm.device.DeviceLocation
import com.joshua360x.prayeralarm.device.DeviceRegion
import com.joshua360x.prayeralarm.device.Reliability
import com.joshua360x.prayeralarm.ring.RingService
import com.joshua360x.prayeralarm.ring.RingState
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The single channel between Dart and the native engine. Method names and
 * argument shapes match lib/alarms/native_alarm_engine.dart.
 */
class NativeBridge(
    private val activity: MainActivity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, CHANNEL)
    private val pendingPermissions = mutableMapOf<Int, MethodChannel.Result>()
    private val context: Context get() = activity.applicationContext

    init {
        channel.setMethodCallHandler(this)
        RingState.listener = { ringing ->
            activity.onRingingChanged(ringing)
            channel.invokeMethod("ringingChanged", ringing?.toMap())
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        RingState.listener = null
        pendingPermissions.values.forEach { it.success(false) }
        pendingPermissions.clear()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "syncSchedule" -> {
                val json = call.argument<String>("json")
                if (json == null || runCatching { Schedule.parse(json) }.isFailure) {
                    result.error("bad_schedule", "Schedule JSON missing or invalid", null)
                    return
                }
                ScheduleStore(context).save(json)
                AlarmScheduler.armAll(context)
                result.success(null)
            }
            "ringing" -> result.success(RingState.current?.toMap())
            "dismiss" -> {
                RingService.command(context, RingService.ACTION_DISMISS)
                result.success(null)
            }
            "snooze" -> {
                RingService.command(context, RingService.ACTION_SNOOZE)
                result.success(null)
            }
            "testAlarm" -> {
                val alarmId = call.argument<Int>("alarmId") ?: 1
                val delaySeconds = call.argument<Int>("delaySeconds") ?: 5
                AlarmScheduler.test(context, alarmId, delaySeconds * 1_000L)
                result.success(null)
            }
            "missingReliability" -> result.success(Reliability.missing(context))
            "fix" -> fix(call.argument<String>("item"), result)
            "currentLocation" -> DeviceLocation.current(context) { location ->
                result.success(location?.let { mapOf("lat" to it.latitude, "lng" to it.longitude) })
            }
            "countryCode" -> result.success(DeviceRegion.countryCode(context))
            else -> result.notImplemented()
        }
    }

    /**
     * Runtime permissions are requested in place the first time; after a
     * refusal Android may not show the dialog again, so the app's settings
     * page opens instead. Everything else opens its system settings screen.
     * The result is whether the item is fixed now (settings screens report
     * false; the app re-checks when it resumes).
     */
    private fun fix(item: String?, result: MethodChannel.Result) {
        if (item == null) {
            result.error("bad_item", "Missing item", null)
            return
        }
        val permission = Reliability.runtimePermission(item)
        if (permission != null && !Reliability.granted(context, permission)) {
            val prefs = context.getSharedPreferences("prayer_alarm_permissions", Context.MODE_PRIVATE)
            val askedBefore = prefs.getBoolean(permission, false)
            if (!askedBefore || activity.shouldShowRequestPermissionRationale(permission)) {
                prefs.edit().putBoolean(permission, true).apply()
                val code = REQUEST_BASE + pendingPermissions.size
                pendingPermissions[code] = result
                activity.requestPermissions(arrayOf(permission), code)
                return
            }
        }
        if (permission != null && Reliability.granted(context, permission)) {
            result.success(true)
            return
        }
        val intent = Reliability.settingsIntent(context, item)
        if (intent != null) {
            try {
                activity.startActivity(intent)
            } catch (e: ActivityNotFoundException) {
                activity.startActivity(Reliability.appDetails(context))
            }
        }
        result.success(false)
    }

    fun onPermissionResult(requestCode: Int, grantResults: IntArray) {
        val result = pendingPermissions.remove(requestCode) ?: return
        result.success(grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
    }

    private companion object {
        const val CHANNEL = "prayer_alarm/native"
        const val REQUEST_BASE = 7100
    }
}
