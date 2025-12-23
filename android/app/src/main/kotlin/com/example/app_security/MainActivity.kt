package com.example.app_security

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Device security channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "security/device")
            .setMethodCallHandler { call, result ->
                if (call.method == "isDeviceCompromised") {
                    val isRooted = checkRoot()
                    result.success(isRooted)
                }
            }
        
        // Screen security channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "security/screen")
            .setMethodCallHandler { call, result ->
                if (call.method == "secureScreen") {
                    // Prevent screenshots and screen recording
                    window.addFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
            }
    }

    private fun checkRoot(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/system/xbin/su",
            "/system/bin/su"
        )
        return paths.any { File(it).exists() }
    }
}