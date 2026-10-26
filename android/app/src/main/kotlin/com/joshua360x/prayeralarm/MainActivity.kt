package com.joshua360x.prayeralarm

import android.app.KeyguardManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import com.joshua360x.prayeralarm.ring.RingState
import com.joshua360x.prayeralarm.ring.Ringing
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Single activity. Shows over the lock screen and keeps the screen on only
 * while an alarm rings; afterwards a locked phone returns to the lock screen.
 */
class MainActivity : FlutterActivity() {
    private var bridge: NativeBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        showOverLockScreen(isRinging(intent))
    }

    override fun onResume() {
        super.onResume()
        showOverLockScreen(RingState.current != null)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        showOverLockScreen(isRinging(intent))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        bridge = NativeBridge(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        bridge?.dispose()
        bridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        bridge?.onPermissionResult(requestCode, grantResults)
    }

    fun onRingingChanged(ringing: Ringing?) {
        showOverLockScreen(ringing != null)
        if (ringing == null && getSystemService(KeyguardManager::class.java).isKeyguardLocked) {
            moveTaskToBack(true)
        }
    }

    private fun isRinging(intent: Intent?): Boolean =
        RingState.current != null || intent?.getBooleanExtra(EXTRA_FROM_ALARM, false) == true

    private fun showOverLockScreen(on: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(on)
            setTurnScreenOn(on)
        } else {
            @Suppress("DEPRECATION")
            val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (on) window.addFlags(flags) else window.clearFlags(flags)
        }
        if (on) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }

    companion object {
        const val EXTRA_FROM_ALARM = "fromAlarm"
    }
}
