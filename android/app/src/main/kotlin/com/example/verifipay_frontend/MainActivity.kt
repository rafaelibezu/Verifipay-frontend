package com.example.verifipay_frontend

import android.content.Intent
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL =
        "com.verifipay/notification_access"

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "openNotificationSettings" -> {
                    val intent = Intent(
                        Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS
                    )

                    startActivity(intent)

                    result.success(true)
                }

                "isNotificationAccessGranted" -> {
                    val enabledPackages =
                        NotificationManagerCompat
                            .getEnabledListenerPackages(this)

                    result.success(
                        enabledPackages.contains(packageName)
                    )
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}