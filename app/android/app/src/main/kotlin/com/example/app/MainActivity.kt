package com.example.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app/timezone"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getLocalTimezone") {
                val tzId = TimeZone.getDefault().id
                result.success(tzId)
            } else {
                result.notImplemented()
            }
        }
    }
}
