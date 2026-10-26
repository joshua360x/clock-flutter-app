package com.joshua360x.prayeralarm.device

import android.content.Context
import android.telephony.TelephonyManager
import java.util.Locale

/**
 * The phone's country (ISO 3166-1 alpha-2) for picking the calculation
 * method: the mobile network it is on, then its SIM, then its locale.
 */
object DeviceRegion {
    fun countryCode(context: Context): String? {
        val telephony = context.getSystemService(TelephonyManager::class.java)
        return listOf(
            runCatching { telephony?.networkCountryIso }.getOrNull(),
            runCatching { telephony?.simCountryIso }.getOrNull(),
            Locale.getDefault().country,
        ).firstOrNull { !it.isNullOrBlank() && it.length == 2 }?.uppercase(Locale.ROOT)
    }
}
