package com.example.verifipay_frontend

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class VerifiPayNotificationListener : NotificationListenerService() {

    companion object {
        private const val TAG = "VerifiPayListener"
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) {
            return
        }

        val packageName = sbn.packageName
        val extras = sbn.notification.extras

        val title = extras
            .getCharSequence(Notification.EXTRA_TITLE)
            ?.toString()

        val text = extras
            .getCharSequence(Notification.EXTRA_TEXT)
            ?.toString()

        val bigText = extras
            .getCharSequence(Notification.EXTRA_BIG_TEXT)
            ?.toString()

        Log.d(
            TAG,
            """
            Notification received:
            package=$packageName
            title=$title
            text=$text
            bigText=$bigText
            """.trimIndent()
        )
    }
}