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

        super.configureFlutterEngine(
            flutterEngine
        )

        MethodChannel(
            flutterEngine
                .dartExecutor
                .binaryMessenger,
            CHANNEL
        ).setMethodCallHandler {
            call,
            result ->

            when (
                call.method
            ) {

                "openNotificationSettings" -> {

                    val intent =
                        Intent(
                            Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS
                        )

                    startActivity(
                        intent
                    )

                    result.success(
                        true
                    )
                }

                "isNotificationAccessGranted" -> {

                    val enabledPackages =
                        NotificationManagerCompat
                            .getEnabledListenerPackages(
                                this
                            )

                    result.success(
                        enabledPackages.contains(
                            packageName
                        )
                    )
                }

                "saveDeviceToken" -> {

                    val token =
                        call.argument<String>(
                            "token"
                        )

                    if (
                        token.isNullOrBlank()
                    ) {

                        result.error(
                            "INVALID_TOKEN",
                            "El token no puede estar vacío",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    try {

                        DeviceTokenStorage(
                            applicationContext
                        ).saveToken(
                            token
                        )

                        result.success(
                            true
                        )

                    } catch (
                        exception: Exception
                    ) {

                        result.error(
                            "TOKEN_SAVE_ERROR",
                            exception.message,
                            null
                        )
                    }
                }

                "hasDeviceToken" -> {

                    val hasToken =
                        DeviceTokenStorage(
                            applicationContext
                        ).hasToken()

                    result.success(
                        hasToken
                    )
                }

                "clearDeviceToken" -> {

                    DeviceTokenStorage(
                        applicationContext
                    ).clearToken()

                    result.success(
                        true
                    )
                }

                "getPendingYapeEventCount" -> {

                    val count =
                        YapeQueueDbHelper(
                            applicationContext
                        ).countPending()

                    result.success(
                        count
                    )
                }

                else -> {

                    result.notImplemented()
                }
            }
        }
    }
}
