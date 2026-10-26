package com.joshua360x.prayeralarm.ring

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log
import com.joshua360x.prayeralarm.alarm.SoundSpec
import java.io.File
import java.io.IOException

/**
 * Plays an alarm on the alarm volume stream, looping until stopped, fading
 * up from 20% over 20 s. Never silent: each source is tried in order, then
 * the phone's default alarm tone, then vibration.
 */
class AlarmAudio(private val context: Context) {
    private var player: MediaPlayer? = null
    private var vibrating = false
    private val handler = Handler(Looper.getMainLooper())
    private var volume = START_VOLUME

    private val attributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_ALARM)
        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
        .build()

    private val ramp = object : Runnable {
        override fun run() {
            volume = (volume + RAMP_STEP).coerceAtMost(1f)
            player?.setVolume(volume, volume)
            if (volume < 1f) handler.postDelayed(this, RAMP_INTERVAL_MS)
        }
    }

    /** Plays the first of [sources] that works (nulls are skipped). */
    fun play(sources: List<SoundSpec?>) {
        stop()
        for (source in sources.filterNotNull()) {
            if (tryPlay(source.toString()) { setSource(it, source) }) return
        }
        val tone = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        if (tone != null && tryPlay("default alarm tone") { it.setDataSource(context, tone) }) return
        vibrate()
    }

    fun stop() {
        handler.removeCallbacks(ramp)
        player?.run {
            runCatching { stop() }
            release()
        }
        player = null
        if (vibrating) {
            context.getSystemService(Vibrator::class.java)?.cancel()
            vibrating = false
        }
    }

    private fun tryPlay(name: String, configure: (MediaPlayer) -> Unit): Boolean {
        val mp = MediaPlayer()
        return try {
            mp.setAudioAttributes(attributes)
            configure(mp)
            mp.isLooping = true
            mp.prepare()
            volume = START_VOLUME
            mp.setVolume(volume, volume)
            mp.start()
            player = mp
            handler.postDelayed(ramp, RAMP_INTERVAL_MS)
            true
        } catch (e: Exception) {
            Log.w(TAG, "Cannot play $name", e)
            mp.release()
            false
        }
    }

    private fun setSource(mp: MediaPlayer, source: SoundSpec) {
        when (source.kind) {
            SoundSpec.KIND_FILE -> mp.setDataSource(source.path)
            SoundSpec.KIND_ASSET -> setAssetSource(mp, source.path)
            else -> throw IllegalArgumentException("Unknown sound kind ${source.kind}")
        }
    }

    /**
     * Flutter assets live under flutter_assets/ in the APK. Media files are
     * stored uncompressed and open directly; anything compressed is copied
     * to the cache once and played from there.
     */
    private fun setAssetSource(mp: MediaPlayer, path: String) {
        val key = "flutter_assets/$path"
        try {
            context.assets.openFd(key).use { mp.setDataSource(it.fileDescriptor, it.startOffset, it.length) }
        } catch (e: IOException) {
            val cached = File(context.cacheDir, "alarm-audio-${key.hashCode()}-${File(path).name}")
            if (!cached.exists()) {
                context.assets.open(key).use { input -> cached.outputStream().use { input.copyTo(it) } }
            }
            mp.setDataSource(cached.path)
        }
    }

    private fun vibrate() {
        val vibrator = context.getSystemService(Vibrator::class.java) ?: return
        @Suppress("DEPRECATION")
        vibrator.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 800, 600), 0), attributes)
        vibrating = true
    }

    private companion object {
        const val TAG = "AlarmAudio"
        const val START_VOLUME = 0.2f
        const val RAMP_STEP = 0.04f
        const val RAMP_INTERVAL_MS = 1_000L
    }
}
