package com.joshua360x.prayeralarm.device

import android.Manifest
import android.content.Context
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper

/**
 * One coarse position for prayer times (a few km is plenty: times move about
 * a minute per 15 km). Uses a recent cached fix when there is one, otherwise
 * asks for a single fresh fix, and gives up after [TIMEOUT_MS].
 */
object DeviceLocation {
    private const val TIMEOUT_MS = 15_000L
    private const val FRESH_ENOUGH_MS = 6 * 60 * 60_000L

    fun current(context: Context, callback: (Location?) -> Unit) {
        if (!Reliability.granted(context, Manifest.permission.ACCESS_COARSE_LOCATION)) {
            callback(null)
            return
        }
        val manager = context.getSystemService(LocationManager::class.java)
        val cached = lastKnown(manager)
        if (cached != null && System.currentTimeMillis() - cached.time < FRESH_ENOUGH_MS) {
            callback(cached)
            return
        }
        val provider = provider(manager)
        if (provider == null) {
            callback(cached)
            return
        }

        val main = Handler(Looper.getMainLooper())
        var done = false
        fun finish(location: Location?) {
            if (done) return
            done = true
            callback(location ?: cached)
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val cancel = CancellationSignal()
                manager.getCurrentLocation(provider, cancel, context.mainExecutor) { finish(it) }
                main.postDelayed({ cancel.cancel(); finish(null) }, TIMEOUT_MS)
            } else {
                val listener = LocationListener { finish(it) }
                @Suppress("DEPRECATION")
                manager.requestSingleUpdate(provider, listener, Looper.getMainLooper())
                main.postDelayed({ manager.removeUpdates(listener); finish(null) }, TIMEOUT_MS)
            }
        } catch (e: SecurityException) {
            finish(null)
        }
    }

    private fun provider(manager: LocationManager): String? = when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            manager.isProviderEnabled(LocationManager.FUSED_PROVIDER) -> LocationManager.FUSED_PROVIDER
        manager.isProviderEnabled(LocationManager.NETWORK_PROVIDER) -> LocationManager.NETWORK_PROVIDER
        manager.isProviderEnabled(LocationManager.GPS_PROVIDER) -> LocationManager.GPS_PROVIDER
        else -> null
    }

    private fun lastKnown(manager: LocationManager): Location? = try {
        manager.getProviders(true)
            .mapNotNull { manager.getLastKnownLocation(it) }
            .maxByOrNull { it.time }
    } catch (e: SecurityException) {
        null
    }
}
