package com.example.verifipay_frontend

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import java.security.MessageDigest

class VerifiPayNotificationListener : NotificationListenerService() {

    companion object {
        private const val TAG = "VerifiPayListener"
        private const val YAPE_PACKAGE = "com.bcp.innovacxion.yapeapp"
    }

    private lateinit var eventSender: YapeEventSender

    override fun onCreate() {
        super.onCreate()
        eventSender = YapeEventSender(applicationContext)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null || sbn.packageName != YAPE_PACKAGE) {
            return
        }

        val extras = sbn.notification.extras
        val text =
            extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()?.trim()
                ?: extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()?.trim()

        if (text.isNullOrBlank()) {
            Log.d(TAG, "Notificacion Yape sin texto")
            return
        }

        Log.d(TAG, "Notificacion Yape recibida")

        val parsed = YapeNotificationParser.parse(text)

        if (parsed == null) {
            Log.d(TAG, "No se pudo interpretar la notificacion Yape")
            return
        }

        Log.d(TAG, "Notificacion Yape interpretada")

        val sourceEventId = createSourceEventId(sbn, parsed)
        val pendingEvent =
            PendingYapeEvent(
                sourceEventId = sourceEventId,
                sender = parsed.sender,
                amount = parsed.amount,
                securityCode = parsed.securityCode,
                occurredAt = sbn.postTime,
            )

        eventSender.enqueueAndSend(pendingEvent)
    }

    private fun createSourceEventId(
        sbn: StatusBarNotification,
        parsed: YapeNotificationData,
    ): String {
        val raw =
            buildString {
                append(sbn.packageName)
                append("|")
                append(sbn.key)
                append("|")
                append(sbn.postTime)
                append("|")
                append(parsed.amount.toPlainString())
                append("|")
                append(parsed.securityCode ?: "")
            }

        val digest =
            MessageDigest
                .getInstance("SHA-256")
                .digest(raw.toByteArray(Charsets.UTF_8))

        return digest.joinToString("") {
            "%02x".format(it)
        }
    }
}
