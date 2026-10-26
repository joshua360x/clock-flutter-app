package com.joshua360x.prayeralarm.ring

import android.os.Handler
import android.os.Looper

/** The alarm ringing right now, if any. */
data class Ringing(
    val alarmId: Int,
    val key: String,
    val label: String,
    /** Scheduled time, epoch millis. */
    val at: Long,
    val kind: String,
) {
    fun toMap(): Map<String, Any> =
        mapOf("alarmId" to alarmId, "key" to key, "label" to label, "at" to at, "kind" to kind)
}

/**
 * In-process ringing state shared by RingService and the Flutter bridge.
 * The service and the activity live in the same process, so a ringing
 * alarm is always visible here while it rings.
 */
object RingState {
    @Volatile
    var current: Ringing? = null
        private set

    /** Called on the main thread with every change. */
    var listener: ((Ringing?) -> Unit)? = null

    private val main = Handler(Looper.getMainLooper())

    fun update(ringing: Ringing?) {
        current = ringing
        main.post { listener?.invoke(ringing) }
    }
}
